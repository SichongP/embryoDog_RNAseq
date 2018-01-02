#!/usr/bin/python3
#above line for running on unix
import re
import sys
sys.argv.pop(0)
#Make sure system arguments are correct or print usage info
if len(sys.argv) != 3:
	print(sys.argv)
	print("usage: compare annotation.gtf novel_transcript_file output.gtf")
	sys.exit()
file_list=sys.argv
unref = open(file_list[1], 'r')
ann = open(file_list[0], 'r')
output = open(file_list[2], 'w')
ids=set()
for line in unref:
	#skip header line if existed
	if "ref_gene_id" in line:
		continue
	values = line.split('\t')
	#skip lines with ref transcript id
	if values[0] != "-":
		continue
	transcript_id = values[4]
	ids.add(transcript_id)
for line in ann:
	#skip comments in gtf file
	if "#" in line:
		continue
	values = line.split('\t')
	#skip exon records
	if values[2] != "transcript":
		continue
	#get transcript_id of each transcript record
	match = re.search("transcript_id \"(.*?)\";",values[8])
	if match:
		transcript_id=match.group(1)
	if transcript_id in ids:
		output.write(line)
