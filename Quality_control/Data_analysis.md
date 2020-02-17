# Data analysis script

This script details the commands used in order to get information about the data used for this project. The goal was to assess allele frequencies, polymorphisms...

## Download and install tools
     wget http://s3.amazonaws.com/plink1-assets/plink_mac_20200121.zip
  
  
 ## Pipeline 
 
 ### 1. Prepare files for PLINK (--make-bed)
 To execute plink yu must, either add plink to the PATH, or work from the directory where PLINK is located. The input is the name of the .bim, .bed and .fam file (same for the three files) without the extension. The same applies for the output.
 
      ./plink --bfile <ctrl_filename> --make-bed --out <ctrl_plink>
      ./plink --bfile <case_filename> --make-bed --out <case_plink>
      
      
### 2. Get basic statistics
With PLINK we can obtain statistics of the input files, which creates a set of output files with counts and frequencies that we will later on analyse.

    ./plink --bfile <ctrl_plink> --freqx --missing --het --out <ctrl_analysis>
    ./plink --bfile <case_plink> --freqx --missing --het --out <case_analysis>

### 3. Output analysis
#### Frequency count file
The output is a tab separated file with the following columns:
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

Singletons are variants that appear once in the cohort and in a heterozygous genotype. In order to know the % of SNPs that are singletons, we simply have to filter the SNPs that have a value of 1 in the 6th column (heterozygote count) and then check that the value is 0:
     
     # Singleton count
     awk '($6==1)' ctrl.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
     
