# GWAS script

This file contains the commands used for the data processing after the SNPs' imputation through the Michigan Imputation Server. The resulting .zip files from each chromosome were merged into one file and then the information was analysed in order to obtain an overview of the data: we computed basic statistics of the data and performed a population stratification analysis again. Afterwards, the data was divided between training and validation (La Princesa, La Paz and Clínico; and Valcecillas respectively).  
Once the data has been prepared, the GWAS can be performed using [GAPIT](https://www.maizegenetics.net/gapit). From this analysis we will find SNPs that link BMI and rheumatic arthritis.

 ## Get all required data and tools  
 Download the required R packiges pointed in the [GAPIT](https://www.maizegenetics.net/gapit) manual tool
 
    # Decompress files (for mac)
    brew install p7zip
    
    # DosageConvertor (refer to https://github.com/Santy-8128/DosageConvertor)
    brew install cmake
    sudo easy-install pip
    pip install --user cget --ignore-installed six
    cd DosageConvertor
    bash install.sh
    
    
 ## Data preparation
 ### 1. Merging files
The Michigan Imputation Server produces a zip file for each chromosome; in order to work with them all in GAPIT, we need the in HapMap format, plus to analyse then with plinkas we did before we will need to transform them too into a plink readable format. The files must be uncompressed using 7-Zip program:
   
     # In ctr/case directory:
     for file in chr*.zip; do 7z e "${file}" -p'PASSWORD'; done

The output consists in two files: a '.dose.vcf.gz' and a '.info.gz' for each chromosome. In order to merge all chromosome files into one single file, we can use [bcftools](http://samtools.github.io/bcftools/bcftools.html):

     # Obtain PLINK files
     for TestDataImputedVCF in Directory; do Prefix="${TestDataImputedVCF%.*.*.*}";  \
     ./DosageConvertor --vcfDose "${TestDataImputedVCF}.dose.vcf.gz" \
     -info "${TestDataImputedVCF}.info.gz" \
     --prefix "Path/${Prefix##*/}" \
     --type plink \
     --format 1; done
                               
                          
     # Transform files to VCF
     ./plink2 --import-dosage chr*.plink.dosage.gz \
     --map chr*.plink.map \
     --fam chr*.plink.fam  \
     --recode vcf --out OutPrefix
     
     # Join VCF files and compress
     bcftools concat ctrl/chr{1..22}.vcf -o ctrl.vcf       
     bgzip -c ctrl.vcf > ctrl.vcf.gz


### 2. Data analysis
Check again same parameters we did before filtering and impotation to get a general overview of how our data looks after the treatment. We use the same commands as before:  
**1. Create plink files**

    ./plink --vcf <ctrl.vcf.gz> --make-bed --double-id --allow-no-sex --out <ctrl_plink>
    ./plink --vcf <case.vcf.gz> --make-bed --double-id --allow-no-sex --out <case_plink>

**2. Get basic statistics**

    ./plink --bfile <ctrl_plink> --freqx --maf 0.05 --missing --het --make-bed --allow-no-sex --double-id --out <analysis_ctrl>
    ./plink --bfile <case_plink> --freqx --maf 0.05 --missing --het --make-bed --allow-no-sex --double-id --out <case_analysis>
    
    # Singleton count
    awk '($6==1)' analysis_ctrl.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
    awk '($6==1)' case.frqx | awk -F "\t" '{ if(($5 == 0) || ($7 == 0)) {print} }' | wc -l
    
    # Missing data
    awk '{ total += $5; count++ } END { print total/count }' analysis_ctrl.lmiss # ctr SNPs 
    awk '{ total += $6; count++ } END { print total/count }' analysis_ctrl.imiss # ctr genotypes 
    awk '{ total += $5; count++ } END { print total/count }' analysis_case.lmiss # ctr SNPs 
    awk '{ total += $6; count++ } END { print total/count }' analysis_case.imiss # ctr genotypes 
   
    
    # Heterozygosis 
    awk '{ total += $6 } END { print total/NR }' ctrl.het
    awk '{ total += $6 } END { print total/NR }' case.het
    
Population stratification is also checked using the same R code as before.

### 3. Divide dataset
The dataset is divided in order to obtain a subdataset for validation. The samples collected for Valdecillas hospital are substracted from the whole and two new files are created using the following commands:

    # Commands 

## GAPIT 
The files must be transformed into HapMap format, which is possible with the following commands:

After all data has been analysed and transformed into the right formt, the GAPIT analysis is performed using an R code.
