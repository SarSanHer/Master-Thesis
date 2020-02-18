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
This option produces a detailed genotype count report in a .frqx file that consists in a tab separated file with the following columns:
| Header | Definition |
| ------------- | ------------- |
| CHR  | Chromosome code  |
| SNP  | Variant identifier  |
| A1  | Allele 1 (usually minor)  |
| A2  | Allele 2 (usually minor)  |
| C(HOM A1)  | A1 homozygote count  |
| C(HET)  | Heterozygote count  |
| C(HOM A2)  | A2 homozygote count  |
| C(HAP A1)  | Haploid A1 count (includes male X chromosome)  |
| C(HAP A2)  | Haploid A2 count  |
| C(MISSING)  | Missing genotype count |

With this file we can obtain information about the abundance of singletons in the data. Singletons are variants that appear once in the cohort and in a heterozygous genotype and, therefore, to know the % of SNPs that are singletons, we have to filter the SNPs that have a value of 1 in the 6th column (heterozygote count) and then check that the value is 0:
     
     # Singleton count
     awk '($6==1)' ctrl.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
     
#### b) maf 0.05
This option filters the SNPs with a minor allele frequency lower than 5% and gives you the filtering information in the -log file.

#### c) missing
This setting creates two files, one with sample missing data (.lmiss) and another with variant missing data (.imiss). The output file 
| lmiss | Definition | imiss | Definition |
| ------------- | ------------- | ------------- | ------------- |
| CHR  | Chromosome code  | FID | 	Family ID |
| SNP  | Variant identifier  | MISS_PHENO | Phenotype missing? (Y/N) |
| N_MISS  | Number of missing genotype call(s), not counting obligatory missings or het. haploids  | N_MISS | idem |
| N_GENO  | Number of potentially valid call(s)  | N_GENO | idem |
| F_MISS | Missing call rate | F_MISS | idem |


#### d) het
It creates a list of the heterozygous haploid genotypes found in our samples. The output is a tab separated file in which the 6th column contains the Method-of-moments F coefficient estimate. This estimate predicts the likehood of the observed homozygosity given the expected  homozygosity for a random dataset. We can compurte the average heterozygosity of the population in the control samples and compare it to the case samples to detect inbreeding in the sample population.

     awk '{ total += $6 } END { print total/NR }' ctrl.het
     awk '{ total += $6 } END { print total/NR }' case.het
