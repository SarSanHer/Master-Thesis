# Data analysis script

This script details the commands used in order to get information about the data used for this project. The goal was to assess allele frequencies, polymorphisms...

## Download and install tools
     wget http://s3.amazonaws.com/plink1-assets/plink_mac_20200121.zip
  
  
 ## Pipeline 
 
 ### Prepare files for PLINK (--make-bed)
 To execute plink yu must, either add plink to the PATH, or work from the directory where PLINK is located. The input is the name of the .bim, .bed and .fam file (same for the three files) without the extension. The same applies for the output.
 
      ./plink --bfile <ctrl_filename> --make-bed --out <ctrl_plink>
      ./plink --bfile <case_filename> --make-bed --out <case_plink>
      
      
### Get basic statistics
With PLINK we can obtain statistics of the input files, which creates a set of output files with counts and frequencies that we will later on analyse.

    ./plink --bfile <ctrl_plink> --freq counts --missing --mendel --het --out <ctrl_analysis>
    ./plink --bfile <case_plink> --freq counts --missing --mendel --het --out <case_analysis>
