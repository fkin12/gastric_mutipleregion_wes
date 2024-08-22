#!/bin/sh
#PBS -V
#PBS -j oe
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=120:00:00
#PBS -q batch

Tumor=$1
Normal=$2
config_path=$3
source ${config_path}/config.sh
echo $Tumor

Raw_snp=`cat ${vcf_path}/${Tumor}_${Normal}_PASS.vcf | grep -v "#" | wc -l`
#############################################################################################################################QC
## SimpleRepeats Region Delete
bedtools intersect -a ${vcf_path}/${Tumor}_${Normal}_PASS.vcf -b ${ref}/SimpleRepeats/GRCh37_SimpleRepeats.bed -v -header \
> ${tmp_path}/${Tumor}_${Normal}_QC1.vcf
SimpleRepeats_QC_num=`cat ${tmp_path}/${Tumor}_${Normal}_QC1.vcf | grep -v "#" | wc -l`


#############################################################################################################################QC
## INDEL突变，Alt和Ref的长度差超过50,认为是SV
cat ${tmp_path}/${Tumor}_${Normal}_QC1.vcf | \
awk -F'\t' '{if($0~"##"){print};if((length($4)-length($5))^2<=(length_limit^2)){print}}' length_limit=50 \
> ${tmp_path}/${Tumor}_${Normal}_QC2.vcf
SV_QC_num=`cat ${tmp_path}/${Tumor}_${Normal}_QC2.vcf | grep -v "#" | wc -l`


#############################################################################################################################QC
## 去除XY染色体
cat ${tmp_path}/${Tumor}_${Normal}_QC2.vcf | awk -F'\t' '{if($0~"##" || ($1!~"X" && $1!~"Y")){print}}'  \
> ${tmp_path}/${Tumor}_${Normal}_QC3.vcf

sex_chr_QC_num=`cat ${tmp_path}/${Tumor}_${Normal}_QC3.vcf | grep -v "#" | wc -l`

#############################################################################################################################QC
## summary
echo $Tumor","$Raw_snp","$SimpleRepeats_QC_num","$SV_QC_num","$sex_chr_QC_num  >> ${vcf_path}/Vcf_QC.list
cp ${tmp_path}/${Tumor}_${Normal}_QC3.vcf ${vcf_path}/${Tumor}_${Normal}_QC.vcf
