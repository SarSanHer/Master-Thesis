# Data analysis script

This script details the commands used in order to get information about the data used for this project. The goal was to assess allele frequencies, polymorphisms...

## Download and install tools
     wget http://s3.amazonaws.com/plink1-assets/plink_mac_20200121.zip
  
  
 ## Pipeline 
 
 ### 1. Prepare files for PLINK (--make-bed)
 To execute plink yu must, either add plink to the PATH, or work from the directory where PLINK is located. The input is the name of the .bim, .bed and .fam file (same for the three files) without the extension. The same applies for the output.
 
      ./plink --bfile <ctrl_filename> --make-bed --allow-no-sex --out <ctrl_plink>
      ./plink --bfile <case_filename> --make-bed --allow-no-sex --out <case_plink>
      
* In our samples "--allow-no-sex" is required for the case files because there are ambiguous-sex samples, and with this command those are ignored.


### 2. Get basic statistics
With PLINK we can obtain statistics of the input files, which creates a set of output files with counts and frequencies that we will later on analyse.

    ./plink --bfile <ctrl_plink> --freqx --maf 0.05 --missing --het --make-bed --allow-no-sex --out <ctrl_analysis>
    ./plink --bfile <case_plink> --freqx --maf 0.05 --missing --het --make-bed --allow-no-sex --out <case_analysis>

#### a) freqx
This option produces a detailed genotype count report in a .frqx file that consists in a tab separated file. By filtering the SNPs that have a value of 1 in the heterozygote count (6th column) and 0 for the homozygote count of both alleles (columns 5th and 7th), we can obtain the count of singletons since they are the variants that appear once in the cohort and in a heterozygous genotype. We can filter those SNPs with the following command:
     
     # Singleton count
     awk '($6==1)' ctrl.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
     awk '($6==1)' case.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
     
#### b) maf 0.05
This option filters the SNPs with a minor allele frequency lower than 5% and gives you the filtering information in the -log file.

#### c) missing
This setting creates two files, one with sample missing data (.lmiss) and another with variant missing data (.imiss). We will count the SNPs or genotypes that have a missing call rate over 2% using the following commands:

     # CONTROL
     awk '($6>0.02)' ctrl.imiss | wc -l # genotypes
     awk '($5>0.02)' ctrl.lmiss | wc -l # SNPs     
     
     # CASES
     awk '($6>0.02)' case.imiss | wc -l # genotypes
     awk '($5>0.02)' case.lmiss | wc -l # SNPs
     
#### d) het
It creates a list of the heterozygous haploid genotypes found in our samples. The output is a tab separated file in which the 6th column contains the Method-of-moments F coefficient estimate. This estimate predicts the likehood of the observed homozygosity given the expected  homozygosity for a random dataset. We can compurte the average heterozygosity of the population in the control samples and compare it to the case samples to detect inbreeding in the sample population.

     awk '{ total += $6 } END { print total/NR }' ctrl.het
     awk '{ total += $6 } END { print total/NR }' case.het
     
   
### 3. Missing data
The experimental genotyping of samples has an error rate of 0.1% to 0.6% [[reference](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4216915/)], so in order to get an idea of the percentage of our data inputs that are not correctly genotyped, we count the missing data in the files as:

          grep -v "^#" <filteredCases.vcf> | cut -f 10- | tr "\t" "\n" | cut -d ':' -f 1 | awk '/^\.\/\./ {NC++;} END{printf("%f\n",NC/(1.0*NR))}'
          
