#!/bin/bash -l


ulimit -s unlimited
module load intel/16.0.1
module load bowtie/2.3.2
module load samtools
module load jellyfish/2.2.6
module load trinityrnaseq/2.4.0

if [[ $# -lt 4 ]]; then
	echo "Usage: $0 <read1> <read2> <output> <contig_size_cut>"
	exit
fi

time Trinity --seqType fq --max_memory 50G --left $1 --right $2 --output $3 --full_cleanup --min_contig_length $4 --CPU 24


exit

##fix unfinished command
cd $3
echo "current position: $3"
fix.sh

##collect assembly
if [[ !-e *Trinity.fasta ]]; then
	time find ./chrysalis -name "*allProbPaths.fasta" -exec cat {} \; > Trinity.fasta
fi

<<comment
##postprocess assembly
chomp_fasta Trinity.fasta
str=`tr '[A-Z]' '[a-z]' <<< "$3"`
str=`tr -d _f <<< "$str"`
cp Trinity.fasta $WORK/proportiondata/dna/$str.fna
cd $WORK/proportiondata/dna
clusterdna $str.fna $str\c.fna
