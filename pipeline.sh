#!/bin/bash
#check if hisat2, stringtie, and samtools available
echo "Checking required packages..."
hisat2_loaded=$(which hisat2)
stringtie_loaded=$(which stringtie)
samtools_loaded=$(which samtools)
if [ "$hisat2_loaded" == "" ]; then
	echo "Required package hisat2 not found!"
	exit 1
elif [ "$stringtie_loaded" == "" ]; then
	echo "Required package stringtie not found!"
	exit 1
elif [ "$samtools_loaded" == "" ]; then
	echo "required package samtools not found!"
	exit 1
fi
usage="Usage: $(basename $0) ref_genome ref_gtf output_basename input_directory"
#echo $usage
if [ "$#" -ne 4 ]; then
	echo $usage
	exit 1
fi 
ref_genome=$1
ref_gtf=$2
output_basename=$3
input_dir=$4
echo "Building hisat2 index..."
mkdir ./hisat2_index
hisat2-build $ref_genome ./hisat2_index/$output_basename
echo "Index built"
echo "Retriving file list from ${input_dir}..."
declare -a list
BD342_R1_list=$(find $input_dir | grep ".gz" | grep "BD342" | grep "R1")
BD342_R2_list=$(find $input_dir | grep ".gz" | grep "BD342" | grep "R2")
BD410_R1_list=$(find $input_dir | grep ".gz" | grep "BD410" | grep "R1")
BD410_R2_list=$(find $input_dir | grep ".gz" | grep "BD410" | grep "R2")
n=0
for i in "BD342_R1" "BD342_R2" "BD410_R1" "BD410_R2"
do
	j=${i}_list
	temp=""
	for k in ${!j}
	do
#		echo $k
		temp="$temp$k," 
	done
	temp=${temp%?}
	list[n++]=$temp
done
BD342_R1=${list[0]}
BD342_R2=${list[1]}
BD410_R1=${list[2]}
BD410_R2=${list[3]}
#echo $BD410_R1
echo "Assembling reads using reference genome: ${ref_genome}"
mkdir ./hisat2_assemble
hisat2 --summary-file BD342.summary -p 20 -x ./hisat2_index/$output_basename -1 ${BD342_R1} -2 ${BD342_R2} -S ./hisat2_assemble/BD342.sam &
hisat2 --summary-file BD410.summary -p 20 -x ./hisat2_index/$output_basename -1 ${BD410_R1} -2 ${BD410_R2} -S ./hisat2_assemble/BD410.sam &
wait
echo "Assemble successful!"
echo "Converting sam files..."
samtools view -b -o ./hisat2_assemble/BD410.bam ./hisat2_assemble/BD410.sam &
samtools view -b -o ./hisat2_assemble/BD342.bam ./hisat2_assemble/BD342.sam &
wait
echo "Conversion completed"
echo "Sorting bam files..."
samtools sort ./hisat2_assemble/BD410.bam > ./hisat2_assemble/BD410_sorted.bam &
samtools sort ./hisat2_assemble/BD342.bam > ./hisat2_assemble/BD342_sorted.bam &
wait
echo "Sorting completed"
mkdir stringtie_annotation
echo "Annotation guided by ${ref_gtf}..."
stringtie -G $ref_gtf -o ./stringtie_annotation/BD342.gtf ./hisat2_assemble/BD342_sorted.bam &
stringtie -G $ref_gtf -o ./stringtie_annotation/BD410.gtf ./hisat2_assemble/BD410_sorted.bam &
wait
echo "Annotation completed"
echo "Comparing annotation files with reference"
gffcompare -r $ref_gtf ./stringtie_annotation/BD410.gtf ./stringtie_annotation/BD342.gtf
echo "Comparison completed"
