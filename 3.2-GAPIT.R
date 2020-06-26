### SARA SANCHEZ-HEREDERO MARTINEZ
### Script to execute GAPIT software (https://www.maizegenetics.net/gapit) for the GWAS analysis

# --------------------- Load packages -----------------------------------------------------------------------------------------------

# # Bioconductor
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install(version = "3.10")
# 
# # Libraries
# BiocManager::install("multtest")
# install.packages("gplots")
# install.packages("LDheatmap")
# install.packages("genetics")
# install.packages("ape")
# install.packages("EMMREML")
# install.packages("scatterplot3d") #The downloaded link at: http://cran.r-project.org/package=scatterplot3d

# Load packages
library(multtest)
library(gplots)
library(LDheatmap)
library(genetics)
library(ape)
library(EMMREML)
library(compiler) #this library is already installed in R
library("scatterplot3d")

# GAPIT library
source("http://zzlab.net/GAPIT/gapit_functions.txt")

# EMMA library 
source("http://zzlab.net/GAPIT/emma.txt")


# --------------------- Load data -----------------------------------------------------------------------------------------------
# Set working directory
setwd('/Volumes/SSD/GAPIT')


# Import data
myY_t <- read.table("val_phen.txt", head = TRUE)
myG_t <- read.table("valCases.hmp.txt" , header = F) # IMPORTANT! No '#' in the data to avoid errors 


# Adjust data so that myY_t and myG_t are compatible
z <- c()
for(i in myY_t$ID){
  z<-c(z,paste('1_',i,sep = ''))
}

myY_t[,1]<-z
myY_t <- myY_t[,1:2]

#---------------------- Step2: run GAPIT --------------------------------

myG_tAPIT <- GAPIT(
  Y=myY_t,
  G=myG_t,
  PCA.total=3,
  Model.selection = TRUE, # determine the optimal number of PCs/Covariates to include for each phenotype
  model=c("GLM", # most simple
          "MLM", # EMMAx implementation
          "MLMM",
          "FarmCPU") # elegir los modelos que nos interesen
)

# Models that use EMMAx: MLM, CMLM, ECMLM, and SUPER
# MLMM: uses forward-backward stepwise linear mixed-model regression to include associated markers as covariates. 
# FarmCPU: solve the problem of false positive control and confounding between testing markers and cofactors
          #simultaneously. It has higher statistical power than MLMM.


# --------------------- Export results -----------------------------------------------------------------------------------------------

# Import data
FarmCPU_r <- read.table('GAPIT.FarmCPU.BMI.GWAS.Results.csv', sep = ',', header = T)
FarmCPU_err <- read.table('GAPIT.FarmCPU.BMI.Df.tValue.StdErr.csv', sep = ',', header = T)


# Extract significant SNPs
mySNPs <- FarmCPU_r[(FarmCPU_r$P.value<0.01),]$SNP
myResults <- FarmCPU_r[(FarmCPU_r$P.value<0.01),]

# Write snps to text file to extract using PLINK
write.table(mySNPs, file='significantSNPs.txt', quote=FALSE, sep="\n", col.names = F, row.names = FALSE) # list of SNP IDs
write.table(myResults, file='/GWAS_results.csv', quote=FALSE, sep=";", col.names = T, row.names = FALSE, dec = ',') # table with values



