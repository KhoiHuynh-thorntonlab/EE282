#!/bin/bash

module load jje/kent/2014.02.19
module load jje/jjeutils/0.1a


#mkdir /bio/khoih/ee282/
mkdir /bio/khoih/ee282/fasta/
mkdir /bio/khoih/ee282/gtf/

cd /bio/khoih/ee282/fasta/
wget ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.24_FB2018_05/fasta/*chromosome* .  
wget ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.24_FB2018_05/fasta/*sum* .  
cd /bio/khoih/ee282/gtf/
wget ftp://ftp.flybase.net/genomes/Drosophila_melanogaster/dmel_r6.24_FB2018_05/gtf/*

echo "download done"

#homework question 1:
cd /bio/khoih/ee282/fasta/

grep -e "chromosome" ./md5sum.txt > ./chromosomemd5.txt

#if then so that script only run if file intergrity is ok:
if md5sum -c ./chromosomemd5.txt;
then
echo "gz is ok"> ./filestat.txt
#get nucleotides total count, total count of N, and total number of sequence
#using faSize
faSize <(zcat ./*fasta.gz) > ./qccount.txt 
# count all nucleotide with grep
grep -v "^>" <(zcat ./*.fasta.gz) | wc | awk '{print $3-$1}' > ./totalnucleotidecount.txt
# count all N with grep
grep -v "^>" <(zcat ./*.fasta.gz) | tr -cd N | wc -c > ./Ncount.txt
# sequence count with grep 
grep -c "^>" <(zcat ./*.fasta.gz) > ./sequencecount.txt

else
echo "gz is corrupted" > ./filestat.txt
fi

echo "question 1 done"

#homework question 2:

cd /bio/khoih/ee282/gtf/

#if then so that script only run if file intergrity is ok:

if md5sum -c ./md5sum.txt;
then
echo "gz is ok"> ./filestat.txt

#feature count for all chromosome:
zcat ./*.gtf.gz | awk '{print $3}' | sort | uniq -c > ./featurecount.txt

# gene count by chromosome:
zcat ./*.gtf.gz | awk '$1 == "X" {print $3}' | sort | uniq -c | grep -e "gene" > ./Xcount.txt
zcat ./*.gtf.gz | awk '$1 == "Y" {print $3}' | sort | uniq -c | grep -e "gene" > ./Ycount.txt
zcat ./*.gtf.gz | awk '$1 == "2L" {print $3}' | sort | uniq -c | grep -e "gene" > ./2Lcount.txt
zcat ./*.gtf.gz | awk '$1 == "3L" {print $3}' | sort | uniq -c | grep -e "gene" > ./3Lcount.txt
zcat ./*.gtf.gz | awk '$1 == "2R" {print $3}' | sort | uniq -c | grep -e "gene" > ./2Rcount.txt
zcat ./*.gtf.gz | awk '$1 == "3R" {print $3}' | sort | uniq -c | grep -e "gene" > ./3Rcount.txt
zcat ./*.gtf.gz | awk '$1 == "4" {print $3}' | sort | uniq -c | grep -e "gene" > ./4count.txt


else
echo "gz is corrupted" > ./filestat.txt
fi

echo "question 2 done"
