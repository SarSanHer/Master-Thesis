### SARA SANCHEZ-HEREDERO MARTINEZ
### Script to lyse epigenetic data

# --------------------- Load packages -----------------------------------------------------------------------------------------------

# BiocManager::install("ChAMP")

library(data.table)
library(ChAMP)
library(dplyr)
library(tibble)

# --------------------- Load data -----------------------------------------------------------------------------------------------

setwd('/Volumes/SSD/Epigenetics/files/')

# Methilation values
system.time(B<- read.table("beta_value.txt", sep="\t", header = T)) 
system.time(pvalue<- read.table("beta_pvalue.txt", sep="\t", header = T)) 
system.time(UnMe<- read.table("beta_UNMeth.txt", sep="\t", header = T)) 
system.time(Me<- read.table("beta_Meth.txt", sep="\t", header = T)) 
system.time(I<- read.table("beta_Intensity.txt", sep="\t", header = T)) 


# Phenotype 
P <- read.table("/Volumes/SSD/Epigenetics/files/filtered.csv", head = TRUE, sep = ";", dec = ',')


# Data overview and adjustments 
P$Age <- as.numeric(P$Age)
P$tabaco <- as.factor(P$tabaco)
P$qualitativeBMI <- as.factor(P$qualitativeBMI)
P$sexo <- as.factor(P$sexo)
P$tabaco <- as.factor(P$tabaco)
P<- dplyr::select(P,-ID, -Visita, -TargetID, -ARC, -qualitativeBMI, -fr, -ccpsn, -hupi_v1, -hupicat_v1)
str(P) # phenotype data should be numeric or factor to be correctly interpreted

str(B)
B<- dplyr::select(B,-INFINIUM_DESIGN_TYPE)

str(pvalue)
pvalue<- dplyr::select(pvalue,-INFINIUM_DESIGN_TYPE, -COLOR_CHANNEL)


B<-column_to_rownames(B, var = "TargetID")
P<-column_to_rownames(P, var = "TargetID")
pvalue<-column_to_rownames(pvalue, var = "TargetID")
UnMe<-column_to_rownames(UnMe, var = "TargetID")
Me<-column_to_rownames(Me, var = "TargetID")
I<-column_to_rownames(I, var = "TargetID")

# Transform to matrices
B<-as.matrix(B)
UnMe<-as.matrix(UnMe)
Me<-as.matrix(Me)
I<-as.matrix(I)


### Subsetting: only take metilation data from first visits
codes <- as.vector(P$Sample_Name)
c <- c()
for(i in codes){c <- c(c,paste('X',i,sep = ''))}
P$Sample_Name <- c
colnames(P) <- c('Sample_Name','Sample_Group','Age', 'smoke','sex')
str(P)

B <- df.subset <- B[, c]
UnMe <- df.subset <- UnMe[, c]
Me <- df.subset <- Me[, c]
I <- df.subset <- I[, c]

write.table(B, file='/Users/sarasanchez/Desktop/B.csv', quote=FALSE, sep=";", dec = ',', col.names = T, row.names = T)
write.table(P, file='/Users/sarasanchez/Desktop/P.csv', quote=FALSE, sep=";", dec = ',', col.names = T, row.names = T)


# --------------------- Data Overview -----------------------------------------------------------------------------------------------
hist(P$BMI, breaks = 10)


# --------------------- Run ChAMP -----------------------------------------------------------------------------------------------

setwd('/Volumes/SSD/Epigenetics/output') # so that output folders are created here


myload_n<-champ.filter(beta=B,
                     M=NULL,
                     pd=NULL,
                     intensity=I,
                     Meth=Me,
                     UnMeth=UnMe,
                     detP=NULL,         # filterDetP is reset FALSE now
                     beadcount=NULL,
                     autoimpute=TRUE,
                     filterDetP=TRUE,
                     ProbeCutoff=0,     # no needs to do imputation. autoimpute has been reset FALSE
                     SampleCutoff=0.1,
                     detPcut=0.01,
                     filterBeads=FALSE,
                     beadCutoff=0.05,
                     filterNoCG = TRUE,
                     filterSNPs = TRUE,
                     population = NULL,
                     filterMultiHit = FALSE,
                     filterXY = FALSE,
                     fixOutlier = TRUE,
                     arraytype = "450K")

'
[ Section 2: Filtering Start >>

  Filtering NoCG Start
    Only Keep CpGs, removing 3156 probes from the analysis.

  Filtering SNPs Start
    Using general 450K SNP list for filtering.
    Filtering probes with SNPs as identified in Zhous Nucleic Acids Research Paper 2016.
Removing 59901 probes from the analysis.

Fixing Outliers Start
Replacing all value smaller/equal to 0 with smallest positive value.
Replacing all value greater/equal to 1 with largest value below 1..
[ Section 2: Filtering Done ]

All filterings are Done, now you have 422520 probes and 22 samples.'

### Quality
champ.QC(beta = myload_n$beta,
         pheno=P$smoke,
         mdsPlot=TRUE,
         densityPlot=TRUE,
         dendrogram=TRUE,
         PDFplot=TRUE,
         Rplot=TRUE,
         Feature.sel="None",
         resultsDir="./BMI/1_QC")

### Get distribution of analysed zones and those that passed the filtering in the array
CpG.GUI(CpG=rownames(myload_n$beta), arraytype = "450K")


### QC
#myLoad<-as.matrix(myload_n)

myimpute_n<-champ.impute(beta=myload_n$beta, pd=P, method="KNN",
                       k=5,ProbeCutoff=0.2,SampleCutoff=0.1)

'
All NA are imputed by KNN method with parameter k as 5.
[<<<<< ChAMP.IMPUTE END >>>>]
[===========================]
Warning message:
In knnimp(x, k, maxmiss = rowmax, maxp = maxp) :
  4 rows with more than 50 % entries missing;
 mean imputation used for these rows
'


QC.GUI(beta=myimpute_n$beta,
       pheno=myimpute_n$pd,
       arraytype="450K")

QC.GUI(beta=myimpute_n$beta,
       pheno=P$sexo,
       arraytype="450K")


### Option to normalize data with a selection of normalization methods. 
##  There are four functions couldbe selected: "PBC","BMIQ","SWAN" and "FunctionalNormalize".  
##  SWAN method call for BOTHrgSet and mset input, FunctionNormalization call for rgset only , 
#   while PBC and BMIQ only needsbeta value. Please set parameter correctly. 
##  BMIQ method is the default function, which would also return normalised density plots in PDF format in results Dir.  FunctionalNormalize is provided inminfi package,  which ONLY support 450K data yet.   Not that BMIQ function might fail if yousample’s beta value distribution is not beta distribution, which occationally happen when too manyCpGs are deleted while loading .idat files with champ.load() function.
norm_n<-champ.norm(beta=myimpute_n$beta,
           resultsDir="./new/3_norm/",
           method="BMIQ",
           plotBMIQ=TRUE,
           arraytype="450K",
           cores=2)


champ.SVD(beta=norm_n,pd=P)

mynorm<-as.matrix(norm_n)
summary(norm_n)

QC.GUI(beta=norm_n,
       pheno=P$Sample_Group,
       arraytype="450K")

champ.QC(beta=norm_n, pheno=P$BMI)

champ.QC(beta = norm_n,
         pheno=P$Sample_Group,
         mdsPlot=TRUE,
         densityPlot=TRUE,
         dendrogram=TRUE,
         PDFplot=TRUE,
         Rplot=TRUE,
         Feature.sel="None",
         resultsDir="./3_norm/")



## Differential methylation per probes
myDMP_n<-champ.DMP(beta=norm_n,
                   pheno=P$Sample_Group,
                   compare.group = P$Sample_Group,
                   adjPVal = 1,
                   adjust.method = "BH",
                   arraytype = "450")

# Subsets & plots
DMP.GUI(DMP=myDMP_n[[1]],beta=norm_n,pheno=P$Sample_Group, cutgroupnumber = 3)

nsubset_01 <- myDMP_n[[1]][myDMP_n[[1]]$P.Value<0.01,]
DMP.GUI(DMP=nsubset_01,beta=norm_n,pheno=P$BMI, cutgroupnumber = 3)

nsubset_0001 <- myDMP_n[[1]][myDMP_n[[1]]$P.Value<0.0001,]
DMP.GUI(DMP=nsubset_0001,beta=norm_n,pheno=P$BMI, cutgroupnumber = 3)

#write.table(nsubset_0001, file='/Volumes/SSD/Epigenetics/output/BMI/filtered.csv', quote=FALSE, sep=";", dec = ',', col.names = T, row.names = T)


## Differential methylation per blocks
myBlock <- champ.Block(beta=norm_n,
                       pheno=P$sexo,
                       arraytype="450K")

## Differential methylation per probes

myGSEA <- champ.GSEA(beta=norm_n,DMP=myDMP_n[[1]], DMR=myDMP_n, arraytype="450K",adjPval=0.05, method="fisher")
head(myGSEA$DMP)
myEpiMod <- champ.EpiMod(beta=norm_n,pheno=P$BMI)


