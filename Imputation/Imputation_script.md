# Imputation Scripts

This script reports the workflow and commands used for the imputation of SNPs performed using the Michigan Imputation Server. Many of the commands here displayed come from the Michigan Imputation Server user manual.

 ## Get all required data and tools  
 In your computer you must also have installed plink and perl with the module [Term::ReadLine::Gnu](https://coderwall.com/p/kk0hqw/perl-install-term-readline-gnu-on-osx).  
 
     # Download reference panel
     wget http://www.well.ox.ac.uk/~wrayner/tools/HRC-1000G-check-bim-v4.2.7.zip
     unzip HRC-1000G-check-bim-v4.2.7.zip
     wget ftp://ngs.sanger.ac.uk/production/hrc/HRC.r1-1/HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz
     
     # Download tools
     wget https://github.com/seppinho/scripts/blob/master/imputation/bin/vcfCooker
     wget http://data.broadinstitute.org/alkesgroup/Eagle/downloads/ 


 ## Create a frequency files
     ./plink --freq --bfile <filtered_control_files> --out <frq_control>
     ./plink --freq --bfile <filtered_case_files> --allow-no-sex --out <frq_cases>

 ## Execute script
 The perl script creates the Run-plink.sh that requires that all files used for the perl command are in the same directory, and plink must also be in that same directory unless it has already been added to the PATH.
 
     perl HRC-1000G-check-bim.pl -b <filtered_control_files.bim> -f <frq_control> -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h
     sh Run-plink.sh
     
     perl HRC-1000G-check-bim.pl -b <filtered_case_files.bim> -f <frq_cases> -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h
     sh Run-plink.sh # IMPORTANT: edit this file to add --allow-no-sex to the plink commands, otherwise phenotypes of missing-sex samples are ignored

 ## Create VCF file for each chromosome and sort it (Linux machine)
     # Execute the vcfCooker command line over all the files preiously created for each cromosome:
     for path in perl/ctr_chr*.bed; \
     do filename="${path%.*}"; \
     echo ""; \
     echo "input: $filename"; \ #print input file name
     echo "output: out/ctrl_${filename: -5}-vcf"; \ #print output file name
     ./vcfCooker --in-bfile "$filename" --ref hs37d5.fa --out "out/ctrl_${filename: -5}-vcf" --write-vcf;\ #vcfCooker command
     done
     
     or path in perl/cases_chr*.bed; \
     do filename="${path%.*}"; \
     echo ""; \
     echo "input: $filename"; \
     echo "output: out/case_${filename: -5}-vcf"; \
     ./vcfCooker --in-bfile "$filename" --ref hs37d5.fa --out "out/case_${filename: -5}-vcf" --write-vcf;\
     done

 ## Chech VCF files
     checkVCF.py -r human_g1k_v37.fasta -o out mystudy_chr1.vcf.gz

 ## Phasing with Eagle
     ./eagle --vcfRef HRC.r1-1.GRCh37.chr20.shapeit3.mac5.aa.genotypes.bcf
     --vcfTarget chunk_20_0000000001_0020000000.vcf.gz  --geneticMapFile genetic_map_chr20_combined_b37.txt
     --outPrefix chunk_20_0000000001_0020000000.phased --bpStart 1 --bpEnd 25000000 -allowRefAltSwap
     --vcfOutFormat z

# Upload results to the Michigan Imputation server
https://imputationserver.sph.umich.edu/index.html#!run/minimac4
