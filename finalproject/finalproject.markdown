#-N -> process name
#-q to specify which compute core to use
#-pe to specify the number of thread
#-t to specify total number of task (total line of your name.txt file
#-R to specify if the job is rerunable with y mean yes.

```
#!/bin/bash
#$ -N ATACseq
#$ -q free64
#$ -pe openmp 2
#$ -R y
#$ -t 1-4
```

#loading all required softwares
```
module load enthought_python/7.3.2
module load R/3.4.1
module load samtools
module load bedtools/2.25.0
```

#name.txt is the file that contain all base name of files prior to any extension.
```
files="/bio/khoih/name.txt"
```
#reference fa for bwa alignment
```
ref="/bio/khoih/ref/dm6.fa"
```
#output base name for file base on task number
```
rawfix=`head -n $SGE_TASK_ID $files | tail -n 1`
```
#raw fastq folder
```
fqdir="/bio/khoih/fastq/"
```
#====================
# trimming nextera adapter, matching ref and output bam:
#=================
```
/bio/khoih/TrimGalore-0.4.5/trim_galore --paired --nextera $fqdir/$rawfix/*R1*.fastq.gz \
$fqdir/$rawfix/*R2*.fastq.gz -o $fqdir/$rawfix/

a=`ls $fqdir/$rawfix/*_R1*.fq.gz | tr 'n' ' '`
b=`ls $fqdir/$rawfix/*_R2*.fq.gz | tr 'n' ' '`

bwa mem -t $bwacore -M $ref <(zcat $a) <(zcat $b) | samtools view -bS - > $fqdir/$rawfix.bam
```
#=============================
# Remove unmapped, mate unmapped
# not primary alignment, reads failing platform
# Only keep properly paired reads
# Obtain name sorted BAM file
#==================
```
samtools view -F 524 -f 2 -u $fqdir/$rawfix.bam > $fqdir/$rawfix.2.bam
samtools sort -n $fqdir/$rawfix.2.bam -o $fqdir/$rawfix.sorted.bam
samtools index $fqdir/$rawfix.sorted.bam
echo "ready for fixmate"
```
#===================================
# Remove orphan reads (pair was removed)
# and read pairs mapping to different chromosomes
# Obtain position sorted BAM
#====================================
```
samtools fixmate -r $fqdir/$rawfix.sorted.bam $fqdir/$rawfix.fixmate.bam
samtools view -F 1804 -f 2 -u $fqdir/$rawfix.fixmate.bam > $fqdir/$rawfix.fixmate.temp.bam
samtools sort $fqdir/$rawfix.fixmate.temp.bam -o $fqdir/$rawfix.fixmate.sort.bam
samtools index $fqdir/$rawfix.fixmate.sort.bam
echo "fixmate done"
```
#=============
# Mark and remove duplicates
#=============
```
java -jar /bio/khoih/picard_2_18_7.jar MarkDuplicates I=$fqdir/$rawfix.fixmate.sort.bam \
O=$fqdir/$rawfix.dedup.bam M=$fqdir/$rawfix.dups.txt REMOVE_DUPLICATES=true
```
#===========
# REMOVE MITO
#=============
```
samtools sort $fqdir/$rawfix.dedup.bam -o $fqdir/$rawfix.dedup.sort.bam
samtools index $fqdir/$rawfix.dedup.sort.bam
samtools view -b $fqdir/$rawfix.dedup.sort.bam chrX chr2L chr2R chr3L chr3R > $fqdir/$rawfix.nomt.bam
samtools sort -n $fqdir/$rawfix.nomt.bam -o $fqdir/$rawfix.nomtsort.bam
```
#================
# convert bam to bedpe file
#================
```
bedtools bamtobed -bedpe -mate1 -i $fqdir/$rawfix.nomtsort.bam  \
| awk -F $'\t' 'BEGIN {OFS = FS}{ if ($9 == "+") {$2 = $2 + 4} else if ($9 == "-") {$3 = $3 - 5} print $0}'  \
| awk -F $'\t' 'BEGIN {OFS = FS}{ if ($10 == "+") {$5 = $5 + 4} else if ($10 == "-") {$6 = $6 - 5} print $0}' \
> $fqdir/$rawfix.bed

```
