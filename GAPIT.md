# GAPIT 

"GAPIT – Genome Association and Prediction Integrated Tool – is an R package that performs a Genome-Wide Association Study (GWAS) and genome prediction (or selection)". Reference extracted from [GAPIT website](https://www.maizegenetics.net/gapit).

 ## Get all required data and tools  
 Download the required R packiges pointed in the [GAPIT](https://www.maizegenetics.net/gapit) manual tool:
 
 **R terminal**
 
    # Bioconductor
    if (!requireNamespace("BiocManager", quietly = TRUE))
       install.packages("BiocManager")
    BiocManager::install(version = "3.10")
    
    # R tools:
    source("http://www.bioconductor.org/biocLite.R")
    biocLite("multtest")
    install.packages("gplots")
    install.packages("LDheatmap")
    install.packages("genetics")
    install.packages("ape")
    install.packages("EMMREML")
    install.packages("scatterplot3d") #The downloaded link at: http://cran.r-project.org/package=scatterplot3d
    
    source("http://zzlab.net/GAPIT/gapit_functions.txt")
