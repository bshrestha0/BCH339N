# BCH339N Class Project

#De novo transcriptome assembly using Trinity

#Download Trinity from this link https://github.com/trinityrnaseq/trinityrnaseq/wiki

#Make sure to download tools/modules(Jellyfish, bowtie2, salmon) needed to run Trinity.

#Export the path to .bashrc or .profile to run the "Trinity" command

#Preprocessing transcriptome read files running fastqc (Details about fastqc: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

module load fastqc

fastqc  PBA_S37_L007_R1_001.fastq

fastqc  PBA_S37_L007_R2_001.fastq

#For trimming adapters or universal primers use Trim Galore (https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)

trim_galore --phred33 --fastqc --length 50 -o trimmed --paired PBA_S37_L007_R1_001.fastq PBA_S37_L007_R2_001.fastq

#Removing ribosomal RNAs from the reads using sortmerna (http://bioinfo.lifl.fr/RNA/sortmerna/)

#create a directory and bash variable for ribosomal rna databases

#Create a directory to hold database files

DBDIR=~/db/sortmerna #You can change this

mkdir -p ${DBDIR}

#Copy FASTA file to the database dir

cp rRNA_databases/*.fasta ${DBDIR}

#Index all the databases

for f in ${DBDIR}/*.fasta; do indexdb_rna --ref ${f},${f/.fasta/} & done
wait

#Create a bash variable for all databases

SORTMERNADB=$(for f in ${DBDIR}/*.fasta; do echo -n "${f},${f/.fasta/}:"; done)

#Remove incorrect final colon from the variable
SORTMERNADB=${SORTMERNADB/%:/}

#Add the variable to the ~/.profile file so that it's always available

echo "export SORTMERNADB=${SORTMERNADB/%:/}" >> ~/.profile

merge-paired-reads.sh PBA_S37_L007_R1_001.fastq PBA_S37_L007_R2_001.fastq PBA_merged.fq

#running sortmerna to blast against ribosomal RNA database

sortmerna --ref $SORTMERNADB --reads PBA_merged.fq --paired_in -a 32 --log --fastx --aligned PBA_rRNA --other PBA_sortmerna

#unmerge the reads into R1 and R2 files

unmerge-paired-reads.sh PBA_sortmerna.fq PBA_sortmerna_1.fq PBA_sortmerna_2.fq

#check the quality running fastqc again

#Running trinity

#Trinity can be run directly following the usages described in the Trinitywiki above.

#However if you want to run using TACC, I have wrote a bash script that loads all the modules needed to run Trinity. For this, download tryTrinity.sh and export in your path variable

tryTrinity.sh PBA_S37_L007_R1_001.fastq PBA_S37_L007_R2_001.fastq biflora.trinity.fasta 200

#Blast reference protein sequences to mine transcripts with plastid gene sequences

#For information about using Blast tool check: https://www.ncbi.nlm.nih.gov/books/NBK279690/

#making blast database for assembled transcriptome and reference protein sequences

module load blast

makeblastdb -in rpl22_protein.fasta -out rpl22_protein_db -dbtype prot

makeblastdb -in biflora.trinity.fasta -out biflora.trinity.db -dbtype nucl

#blastx

blastx -query ../biflora.trinity.fasta -db rpl22_protein.db -evalue 1e-3 -outfmt 6 -out biflora.blastx.out -num_threads 12

#reciprocal blast

#tblastn

tblastn -query rpl22_protein.fasta -db biflora.trinity -evalue 1e-3 -outfmt 7 -max_target_seqs 2 -out rpl22.tblastn.out -num_threads 12

#Alternative way of mining missing plastid genes using transcriptome data.

#Dr. Mikhail Matz has github repository on how to annotate transcriptome data using uniport database.

#Check the link:https://github.com/z0on/annotatingTranscriptomes







