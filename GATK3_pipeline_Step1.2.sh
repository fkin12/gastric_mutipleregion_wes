#!/bin/sh
#PBS -V
#PBS -j oe
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=120:00:00
#PBS -q batch
#./scripts/GATK3_pipeline_Step1.2.sh

sample=$1
config_path=$2
source ${config_path}/config.sh
# Environment

if [[ $WGS != "TRUE" ]]
then
capture_bed="-L ${target_bed}"
else
capture_bed=""
fi


java -Xmx5g -Djava.io.tmpdir=${tmp_path} -jar ${gatk} -T BaseRecalibrator \
	-I ${bam_path}/${sample}-sort.bam \
	-o ${bam_path}/${sample}-sort.grp \
	-R ${seq_ref}/GRCh37.fa \
	${capture_bed} \
	--knownSites ${variants_ref}/dbsnp-147.vcf.gz \
	--knownSites ${variants_ref}/Mills_and_1000G_gold_standard.indels.vcf.gz \
	-nct ${gatk_threads} \
	--read_filter BadCigar --read_filter NotPrimaryAlignment \
	2> ${log_path}/${sample}-BQSR.log

java -Xmx5g -Djava.io.tmpdir=${tmp_path} -jar ${gatk} -T PrintReads \
	-I ${bam_path}/${sample}-sort.bam \
	-o ${bam_path}/${sample}-recal.bam \
	-BQSR ${bam_path}/${sample}-sort.grp \
	-R ${seq_ref}/GRCh37.fa \
	${capture_bed} \
	-nct ${gatk_threads} \
	2> ${log_path}/${sample}-recal.log

# END
