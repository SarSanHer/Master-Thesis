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

    ./plink --bfile <ctrl_plink> --freq counts --missing --het --out <ctrl_analysis>
    ./plink --bfile <case_plink> --freq counts --missing --het --out <case_analysis>

### 3. Output analysis
#### Frequency count file
The output is:
| Header | Definition |
| ------------- | ------------- |
| CHR  | Chromosome code  |
| SNP  | Variant identifier  |
| A1  | Allele 1 (usually minor)  |
| A2  | Allele 2 (usually minor)  |
| C1  | Allele 1 count  |
| C2  | Allele 2 count  |
| G0  | Missing genotype count (so C1 + C2 + 2 * G0 is constant on autosomal variants)  |

     
     # Singleton count
     <ctrl.frq.counts>
