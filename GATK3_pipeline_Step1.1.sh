#!/bin/sh
#PBS -V
#PBS -j oe
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=120:00:00
#PBS -q batch
#./scripts/GATK3_pipeline_Step1.1.sh

sample=$1
config_path=$2
source ${config_path}/config.sh
# Environment

bwa mem -t ${bwa_threads} \
-R "@RG\tID:${sample}\tPL:illumina\tPU:${sample}_LCB_WGS\tSM:${sample}" \
${seq_ref}/GRCh37.fa ${trim_fastq_path}/${sample}_R1_trim.fq.gz ${trim_fastq_path}/${sample}_R2_trim.fq.gz \
| ${samblaster} --excludeDups --addMateTags --maxSplitCount 2 --minNonOverlap 20 \
| samtools view -S -b - \
1> ${bam_path}/${sample}-org.bam \
2> ${log_path}/${sample}-org.log
	
sambamba sort \
-t ${bwa_threads} \
-m 15G \
--tmpdir ${tmp_path} \
-o ${bam_path}/${sample}-sort.bam \
${bam_path}/${sample}-org.bam \
2> ${log_path}/${sample}-sort.log
	
sambamba index \
-t ${bwa_threads} \
${bam_path}/${sample}-sort.bam \
2> ${log_path}/${sample}-index.log

# END