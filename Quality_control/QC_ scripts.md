# QC Scripts

This file contains the commands used for the quality control of the samples performed using PLINK. The goal was to filter out, in the control, all samples that did not follow the hwe equlibrium so to discard the SNPs that did not have a mendelian inheritance dynamic. For the case samples, the filter was on ...

## Download and install tools
     wget http://s3.amazonaws.com/plink1-assets/plink_mac_20200121.zip
  
  
 ## Pipeline 
 
 ### Prepare files for PLINK (--make-bed)
 In order to do this you have to either add plink to the PATH or work from the directory where PLINK is located. The input are the .bim, .bed and .fam files, so in the command we use the name (that is the same for the three files) without the extension. The same applies for the output.
 
      ./plink --bfile <control_files_name> --make-bed --out <new_control_name>
      ./plink --bfile <case_files_name> --make-bed --out <new_case_name>
      
      
 ### Filtering
  First we filter the control files to obtain a list of the SNPs that we will use for the case files. 
  
      #filtering
      ./plink --bfile <new_control_name> --make-bed --hwe 0.0001 --out <filtered_control>
      
      #extract second column since that one contains the SNPs
      cat <filtered_control.bim> | cut -f2 > <my_SNPs.txt>
 
 Now we filter the case files 
 
      #filtering
      ./plink --bfile <new_case_name> --make-bed --allow-no-sex --het --mind 0.02 --maf 0.05 --geno 0.02 --extract <my_SNPs.txt> --out <filtered_cases>
