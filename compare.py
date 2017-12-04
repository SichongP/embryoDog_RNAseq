#!/usr/bin/python3
#above line for running on unix
#use sys.argv before implementing
import re
import sys
#file_list = ["ann.txt", "unref.txt","output.txt"]
sys.argv.pop(0)
if len(sys.argv) != 3:
	print(sys.argv)
	print("usage: compare file1 file2 output")
	sys.exit()
file_list=sys.argv
unref = open(file_list[1], 'r')
ann = open(file_list[0], 'r')
output = open(file_list[2], 'w')
ids=set()
for line in unref:
	if "ref_gene_id" in line:
		continue
	values = line.split('\t')
	transcript_id = values[4]
	ids.add(transcript_id)
for line in ann:
	if "#" in line:
		continue
	values = line.split('\t')
	if values[2] != "transcript":
		continue
	match = re.search("transcript_id \"(.*?)\";",values[8])
	if match:
		transcript_id=match.group(1)
	if transcript_id in ids:
		output.write(line)