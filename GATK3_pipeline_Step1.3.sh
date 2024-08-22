#!/bin/sh
#PBS -V
#PBS -j oe
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=120:00:00
#PBS -q batch
#./scripts/GATK3_pipeline_Step1.3.sh

sample=$1
config_path=$2
source ${config_path}/config.sh
# Environment

java -Xmx10g -Djava.io.tmpdir=${tmp_path} -jar ${picard} CollectAlignmentSummaryMetrics \
	R=${seq_ref}/GRCh37.fa \
	I=${bam_path}/${sample}-recal.bam \
	O=${bam_path}/${sample}-recal.alignment.metrics
	
java -Xmx10g -Djava.io.tmpdir=${tmp_path} -jar ${picard} CollectOxoGMetrics \
	R=${seq_ref}/GRCh37.fa \
	I=${bam_path}/${sample}-recal.bam \
	O=${bam_path}/${sample}-recal.OxoG.metrics

java -Xmx10g -Djava.io.tmpdir=${tmp_path} -jar ${picard} CollectInsertSizeMetrics  \
	R=${seq_ref}/GRCh37.fa \
	I=${bam_path}/${sample}-recal.bam \
	O=${bam_path}/${sample}-recal.insertsize.metrics \
	H=${bam_path}/${sample}-recal.insertsize.pdf
