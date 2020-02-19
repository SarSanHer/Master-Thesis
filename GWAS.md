# GWAS script

This file contains the commands used for the data processing after the SNPs' imputation through the Michigan Imputation Server. The resulting .zip files from each chromosome were merged into one file and then the information was analysed in order to obtain an overview of the data: we computed basic statistics of the data and performed a population stratification analysis again. Afterwards, the data was divided between training and validation (La Princesa, La Paz and Clínico; and Valcecillas respectively).  
Once the data has been prepared, the GWAS can be performed using [GAPIT](https://www.maizegenetics.net/gapit). From this analysis we will find SNPs that link BMI and rheumatic arthritis.

 ## Get all required data and tools  
 Download the required R packiges pointed in the [GAPIT](https://www.maizegenetics.net/gapit) manual tool
 
    # for mac
    brew install p7zip
    
 ## Data preparation
 ### 1. Merging files
 The Michigan Imputation Server produces a zip file for each chromosome; in order to work with them all in GAPIT, we must merge them into one single vcf file. The files must be uncompressed using 7-Zip program:
 * Note: when downloading files, those of size over 4Gb were corrupted, careful when downloading! Check that downloaded file size is correct, otherwise you'll get errors
 
     brew install p7zip
     # enter password provided by the Michigan Imputation Server
