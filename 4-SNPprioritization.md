# SNP prioritization

After GWAS analysis, the SNPs with most significant association p-value (<0.01) were extracted. Those SNPs are organised in blocks, so the next step was to identify those blocks in order to find the most significant SNP of each block. The SNP selected in each block was according to the information from the SNPeff analysis (and the number of NA values).



## 1. Significant SNP extraction  
This was performed in R with the files resulting from the GAPIT GWAS analysis:  
**In R**

    # Load file
    FarmCPU_r <- read.table('GAPIT.FarmCPU.BMI.GWAS.Results.csv', sep = ',', header = T)
    
    # Extract significant SNPs
    mySNPs <- FarmCPU_r[(FarmCPU_r$P.value<0.01),]$SNP

    # Write snps to text file to extract using PLINK
    write.table(mySNPs, file='significantSNPs.txt', quote=FALSE, sep="\n", col.names = F, row.names = FALSE)

**In bash shell**

    # Extract SNPs from list using PLINK
    ./plink --bfile <train> --make-bed --allow-no-sex --extract <significantSNPs.txt> --out <sigSNPs>


## 2. Block identification
Most of the SNP significantly associated appear in groups, meaning that, if one SNP is present, all other SNPs in the group are likely to be present too. Identifying these groups will be useful because by testing the presence of one single SNP in a patient, we will know if all the SNPs in the group are also present.
Here, we use plink's "--blocks" option for [haplotype block estimation](https://www.cog-genomics.org/plink/1.9/ld#blocks). We modify the lower D-prime confidence interval to be 0.8 instead of the default 0.7 to be more restrictive.

    ./plink --bfile <sigSNPs> --allow-no-sex --blocks no-pheno-req --blocks-strong-lowci 0.8 --out <blocks>
    
## 3. Best SNP
The best SNP of each group is the one with the lowest number of NA records and higher effect according to SNPeff, so the best approach to finding it is to estimate a ratio of these two parameters for each SNP of the identified blocks.

    # Getting traw files to count NAs
    ./plink --bfile <sigSNPs> --recode A-transpose --out <tped_prefix>
    
The selection of the best SNP of each block was performed using R code that can be found in file ```4.1-BestSNP.R```. The identifed SNPs were outputed to a txt file so to extract those SNPs from the PLINK files using PLINK:

    # Extract SNPs from list using PLINK
    ./plink --bfile <sigSNPs> --make-bed --allow-no-sex --extract <bestSNPs.txt> --out <bestSNPs>


## 4.Supervised Learning
Once a smaller set of significant SNPs had been identified, the selected SNPs were used as input for a supervised learning program that aimed to find which SNPs had a higher relevance in the prediction of BMI and, therefore, would be more relevant in a diagnostic experiment. The algorithms used were:  
* Random Forest: because it runs efficiently on large databases with high number of attributes and does not have overfitting issues. It also provides a p-value for the accuracy of the results.  
* Random Uniform Forest: to validate results.  
* Gradient Boosting: also to validate results, it can have overfitting issues.  

In order to see the code used for this analysis please refer to file ```4.2-MachineLearning.R```. 

    
