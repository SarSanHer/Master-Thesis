# Imputation Scripts

This script reports the workflow and commands used for the imputation of SNPs performed using the Michigan Imputation Server. MMany of the commands here displayed come from the Michigan Imputation Server user manual.

## Get all required data and tools  
     # Dwonload reference panel
     wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
     unzip HRC-1000G-check-bim-v4.2.7.zip
     wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
     
     # Download tools
     wget https://github.com/seppinho/scripts/blob/master/imputation/bin/vcfCooker


## Create a frequency files
     ./plink --freq --bfile <filtered_control_files> --out <frq_control>
     ./plink --freq --bfile <filtered_case_files> --allow-no-sex --out <frq_cases>

## Execute script
     perl HRC-1000G-check-bim.pl -b <filtered_case_files.bim> -f <frq_cases> -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

## Create VCF with vcfCooker
     vcfCooker --in-bfile <filtered_control_files.bim> --ref <reference.fasta>  --out <control_output-vcf> --write-vcf
     bgzip <control_output-vcf>
     
     vcfCooker --in-bfile <filtered_case_files.bim> --ref <reference.fasta>  --out <case_output-vcf> --write-vcf
     bgzip <case_output-vcf>
