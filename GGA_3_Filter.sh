#!/bin/sh
#PBS -V
#PBS -j oe
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=120:00:00
#PBS -q batch
Tumor=$1
Normal=$2
config_path=$3
source ${config_path}/config.sh


## bedtools 会取到当前区域的后一个,因此strat需要-1，保证只取区域里的
## 但是INS不对
#cat ${tmp_path}/Combine_${Normal}_GGA_site.bed | awk '{OFS="\t"}{$2=$2-1;print}' > ${tmp_path}/Combine_${Normal}_GGA_site_use.bed

sample=${Tumor}_${Normal}
SAMPLE2=$Normal

## 这里使用bcfools，直接提取vcf文件的共同
bcftools isec -n+2 -c all -p ${tmp_path}/${sample} ${vcf_path}/${sample}_GGA.vcf.gz ${vcf_path}/Combine_${SAMPLE2}_forGGA.vcf.gz
cat ${tmp_path}/${sample}/0000.vcf | bgzip > ${vcf_path}/${sample}_GGA_Filter.vcf.gz
tabix -f  ${vcf_path}/${sample}_GGA_Filter.vcf.gz

GGA_Abstract_Num=`cat ${tmp_path}/${sample}/0000.vcf | grep -v "#" | wc -l`
Raw_Num=`zcat ${vcf_path}/Combine_${SAMPLE2}_forGGA.vcf.gz | grep -v "#" | wc -l`
echo ${sample}","${Raw_Num}","$GGA_Abstract_Num >> ${vcf_path}/GGA_Filter.list




