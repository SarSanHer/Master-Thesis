### Sara Sánchez-Heredero Martínez 
### Code to analyse PCA results from PLINK's PCA analysis over case sample's files

# load libraries
library(ggplot2)

# setting work space
setwd('/Volumes/GRU/TFM/plink_files/PCA') # set working directory
options(scipen=100, digits=3) # tell R not to use exponential notation

# Load data
eigen <- data.frame(read.table("PCA_cases_plink.eigenvec", header=FALSE, skip=0, sep=" ")) # create dataframe for the .eigenvec file that PLINK created
val<-data.frame(read.table("PCA_cases_plink.eigenval", header=FALSE, skip=0, sep=" ")) #here we can see how much variance is explained by each principal component
hist(val[,1])
  
# Prepare dataframe for PCA plotting
rownames(eigen) <- eigen[,2] # set rownames to the value in the second col of the dataframe (hospital codes + sample ID)
eigen <- eigen[,3:ncol(eigen)] # delete two firs cols (1 is numeration and 2 is rownames)
summary(eigen) # show summary of the created dataframe

# Determine the proportion of variance of each component (PCA$scores)
proportionvariances <- ((apply(eigen, 1, sd)^2) / (sum(apply(eigen, 1, sd)^2)))*100 # apply is to perform the operation over each value of the matrix
pve <- data.frame(PC = 1:16, pve = val/sum(val)*100)
head((sort(proportionvariances, decreasing=TRUE)), 20) 

# plot variance
eigenval <- scan("./PCA_cases_plink.eigenval")
pve <- data.frame(PC = 1:10, pve = eigenval/sum(eigenval)*100)
a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") + theme_light()


# Find out how many hospital IDs we have
a <-c()
for(i in rownames(eigen)){a<-c(a,substring(i,1,3))}
unique(a)

# Group data by hospitals: create a new row 'hospital ID' to display the groups in the PCA plot
hosp <- c()
for(i in rownames(eigen)){
  if(grepl('ARC', i)){
    hosp <- c(hosp, 'Princesa')
  }else if(grepl('1_10', i)){
    hosp <- c(hosp, 'Princesa')
  }else if(grepl('ARS', i)){
    hosp <- c(hosp, 'Valdecillas')
  }else if(grepl('ARI', i)){
    hosp <- c(hosp, 'LaPaz')
  }else if(grepl('Ari', i)){
    hosp <- c(hosp, 'LaPaz')
  }else if(grepl('MAR', i)){
    hosp <- c(hosp, 'Clinico')
  }else{
    print(i)
  }
}

eigen <- cbind(hosp, eigen)



# Plot PCs
samples <- c("Princesa", "Clinico", "LaPaz", "Valdecillas")
colour <- c("blue","darkgreen","red","orange")
plot(eigen[,2], eigen[,3], col=colour, pch = 18, xlab="PC1", ylab="PC2", main="Case samples PCA")
legend('topleft', legend=samples, fill=colour, col=colour, cex=0.8, title='Hospitals')

plot(eigen[,2], eigen[,4], col=colour, pch = 18, xlab="PC1", ylab="PC3", main="Case samples PCA")
legend('topleft', legend=samples, fill=colour, col=colour, cex=0.8, title='Hospitals')

plot(eigen[,2], eigen[,5], col=colour, pch = 18, xlab="PC1", ylab="PC4", main="Case samples PCA")
legend('topleft', legend=samples, fill=colour, col=colour, cex=0.8, title='Hospitals')

plot(eigen[,3], eigen[,4], col=colour, pch = 18, xlab="PC2", ylab="PC3", main="Case samples PCA")
legend('topleft', legend=samples, fill=colour, col=colour, cex=0.8, title='Hospitals')

plot(eigen[,3], eigen[,5], col=colour, pch = 18, xlab="PC2", ylab="PC4", main="Case samples PCA")
legend('topleft', legend=samples, fill=colour, col=colour, cex=0.8, title='Hospitals')

plot(eigen[,4], eigen[,5], col=colour, pch = 18, xlab="PC3", ylab="PC4", main="Case samples PCA")
legend('topleft', legend=samples, fill=colour, col=colour, cex=0.8, title='Hospitals')

