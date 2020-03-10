### SARA SANCHEZ-HEREDERO MARTINEZ
### 7/Mar/2020

# Script to modify 0 genotypes with imputated genotype


#------------------------------ Load files -------------------------------------------------------------------------------------
setwd('/Volumes/SSD')

o_map<- read.table('filtered_cases_plink.map')
o_ped<- read.table('filtered_cases_plink.ped')
n_ped<- read.table('filtered_cases_plink.ped')


i_map <- read.table('newExtractCases.map')
i_ped <- read.table('newExtractCases.ped')

refs <- read.table('SNPs_rs.txt')

result<-read.table('/Volumes/SSD/CASES_FILES/FILTERED/filteredCases.ped')

#------------------------------ STEP 1 -------------------------------------------------------------------------------------
### Create table with coordenates of interest and correspondences between tables

# Find rs reference of imputed SNPs
imputedSNP <- refs[refs$V1 %in% i_map$V2,] # get rows if refs that have imputed SNPs (15973 out of 91728)

# Find row number of those SNPs
row_pos_o <- c()
for(i in imputedSNP$V2){ #iterate over list of imputed SNPs
  a <- toString(match(i,o_map$V2)) # find position in row 
  a <- as.integer(a) 
  row_pos_o <- c(row_pos_o, a) # append row number to list
}

# Locate those SNPs in original ped -> 6 first columns are info, then there are 2 columns per variant, which correspond to the position in the map file
col_pos_o <- c()
for(i in row_pos_o){ #iterate over list of row numbers
  a <- (2*i+6) # find position in row 
  b<- (a-1)
  col_pos_o <- c(col_pos_o,b,a) # append row number to list
}



#------------------------------ STEP 2 -------------------------------------------------------------------------------------
# Locate all in imputed files

row_pos_i <- c() # Theoretically all genotypes shpuld be in order, but we do this just in case
for(i in imputedSNP$V1){ 
  a <- toString(match(i,i_map$V2))
  a <- as.integer(a) 
  row_pos_i <- c(row_pos_i, a) 
}

# Locate SNPs in ped columns
col_pos_i <- c()
for(i in row_pos_i){ 
  a <- (2*i+6)
  b<- (a-1)
  col_pos_i <- c(col_pos_i, b, a) 
}


#------------------------------ STEP 3 -------------------------------------------------------------------------------------
### Check that both ped files have the same order in the subjects id
res <- c()
for(i in 1:1708){
  if(pmatch(toString(o_ped$V2[i]), toString(i_ped$V2[i]))){res<-c(res,'Y')}else{res<-c(res,'N')}
}

bubba <- data.frame(original=o_ped$V2,
                    imputated=i_ped$V2,
                    match=res)



#------------------------------ STEP 4 -------------------------------------------------------------------------------------
### Compare columns and create a new table containing the new values
for (i in 1:nrow(n_ped)){
  message(i)
  j = which(o_ped[i, col_pos_o] == 0)
  n_ped[i, col_pos_o[j]] = i_ped[i, col_pos_i[j]]
}



#------------------------------ STEP 5 -------------------------------------------------------------------------------------
# Write new file

write.table(n_ped, file='genotypes.ped', quote=FALSE, sep=' ', col.names = FALSE, row.names = FALSE)

