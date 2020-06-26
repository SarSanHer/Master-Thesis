# QC Scripts

This file contains the commands used for the quality control of the samples performed using PLINK. The goal was to obtain files containing only the genotypes which frequencies can be associated to the disease (filtering out low quality or SNPs with other associations).

## Download and install tools
     # If PLINK has not been already installed
     wget http://s3.amazonaws.com/plink1-assets/plink_mac_20200121.zip
  
  
 ## Pipeline 
 
 ### Prepare files for PLINK (if not already done in the data analysis step) 
 To execute plink yu must, either add plink to the PATH, or work from the directory where PLINK is located. The input is the name of the .bim, .bed and .fam file (same for the three files) without the extension. The same applies for the output.
 
      ./plink --bfile <ctrl_filename> --make-bed --out <ctrl_plink>
      ./plink --bfile <case_filename> --make-bed --out <case_plink>
      
      
 ### Filtering
 For the control samples the filter applied was:
1. **hwe 0.0001**: it filters out the SNPs with a frequency in the cohort that indicate that there are forces altering the heritability of the SNP and, therefore, its association to the disease could be a false positive.

The filters applied to the case samples were:
1. **mind 0.02**: samples with a call rate under 2% are discarded
2. **geno 0.02**: SNPs with a call rate under 2% are discarded
3. **maf 0.05**: SNPs with a minor allele frequency lower than 5% are discarded
4. **SNPs' list**: only the SNPs found in the control (after filtering) were kept in the case samples' files.
 
  
       #CONTROL filtering
       ./plink --bfile <ctrl_plink> --make-bed --hwe 0.0001 --out <filtered_control>
      
       #extract second column since that one contains the SNPs
       cat <filtered_control.bim> | cut -f2 > <my_SNPs.txt>
  
       #CASE filtering
       ./plink --bfile <case_plink> --make-bed --allow-no-sex --het --mind 0.02 --maf 0.05 --geno 0.02 --extract <my_SNPs.txt> --out <filtered_cases>
       
       
 ## Population control       
Once the quality of the SNPs is assesed, is important to check the population stratification, which can be done with a Principal Component Analysis. To see this step, refer to the R scrip file stored in this same directory of the repository.
