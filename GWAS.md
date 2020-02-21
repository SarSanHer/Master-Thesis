# GWAS script

This file contains the commands used for the data processing after the SNPs' imputation through the Michigan Imputation Server. The resulting .zip files from each chromosome were merged into one file and then the information was analysed in order to obtain an overview of the data: we computed basic statistics of the data and performed a population stratification analysis again. Afterwards, the data was divided between training and validation (La Princesa, La Paz and Clínico; and Valcecillas respectively).  
Once the data has been prepared, the GWAS can be performed using [GAPIT](https://www.maizegenetics.net/gapit). From this analysis we will find SNPs that link BMI and rheumatic arthritis.

 ## Get all required data and tools  
 Download the required R packiges pointed in the [GAPIT](https://www.maizegenetics.net/gapit) manual tool
 
    # for mac
    brew install p7zip
    
    # refer to https://github.com/Santy-8128/DosageConvertor
    brew install cmake
    sudo easy-install pip
    pip install --user cget --ignore-installed six
    cd DosageConvertor
    bash install.sh
    
    
 ## Data preparation
 ### 1. Merging files
  * Note: when downloading files, those of size over 4Gb were corrupted, careful when downloading! Check that downloaded file size is correct, otherwise you'll get errors.

The Michigan Imputation Server produces a zip file for each chromosome; in order to work with them all in GAPIT, we must merge them into one single vcf file. The files must be uncompressed using 7-Zip program:
   
     # In ctr/case directory:
     for file in chr*.zip; do 7z e "${file}" -pPASSWORD; done

The output consists in two files: a '.dose.vcf.gz' and a '.info.gz' for each chromosome. In order to merge all chromosome files into one single file, we can use [bcftools](http://samtools.github.io/bcftools/bcftools.html):

     # Obtain PLINK files
     ./DosageConvertor    --vcfDose      TestDataImputedVCF.dose.vcf.gz
                          --info         TestDataImputedVCF.info          (optional)
                          --prefix       OutPrefix
                          --type         plink                            (default)
                          --format       1                                (or 2,3)
                          
                          
     # Transform files to VCF
     ./plink --dosage 
     
     
     # Merge VCF files
     for file in *dose*; do echo "${file}" >> files.txt; done # create txt with file names we want to use
     bcftools -- concat chr*.dose.vcf.gz | gzip > out.vcf.gz       


### 2. Data analysis
Check again same parameters we did before filtering and impotation to get a general overview of how our data looks after the treatment. We use the same commands as before:  
**1. Create plink files**

    ./plink --bfile <ctrl_filename> --make-bed --allow-no-sex --out <ctrl_plink>
    ./plink --bfile <case_filename> --make-bed --allow-no-sex --out <case_plink>

**2. Get basic statistics**

    ./plink --bfile <ctrl_plink> --freqx --maf 0.05 --missing --het --make-bed --allow-no-sex --out <ctrl_analysis>
    ./plink --bfile <case_plink> --freqx --maf 0.05 --missing --het --make-bed --allow-no-sex --out <case_analysis>
    
    # Singleton count
    awk '($6==1)' ctrl.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
    awk '($6==1)' case.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
    
    # Missing data
    awk '($6>0.02)' ctrl.imiss | wc -l # ctr genotypes
    awk '($5>0.02)' ctrl.lmiss | wc -l # ctr SNPs     
    awk '($6>0.02)' case.imiss | wc -l # case genotypes
    awk '($5>0.02)' case.lmiss | wc -l # case SNPs
    
    # Heterozygosis 
    awk '{ total += $6 } END { print total/NR }' ctrl.het
    awk '{ total += $6 } END { print total/NR }' case.het
    
Population stratification is also checked using the same R code as before.

### 3. Divide dataset
The dataset is divided in order to obtain a subdataset for validation. The samples collected for Valdecillas hospital are substracted from the whole and two new files are created using the following commands:

    # Commands 

## GAPIT 
With the data analysed and prepared, the GWAS analysis can be performed with the GAPIT toolbox in R.

