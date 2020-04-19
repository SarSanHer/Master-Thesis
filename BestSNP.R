### SARA SANCHEZ-HEREDERO MARTINEZ
### Script to find best SNP from the block considering:
      # 1. Number of NA
      # 2. Effect estimated by SNPeff

# --------------------- Load data -----------------------------------------------------------------------------------------------

blocks <- read.table("/Volumes/SSD/Prioritization/files/blocks/blocks.blocks.det", head = T)
b <- data.frame(do.call('rbind', strsplit(as.character(blocks[,6]),'|',fixed=TRUE)))


snps <- scan('/Volumes/SSD/Prioritization/significantSNPs.txt',what="", sep="\n")

# Genotype data is the traw transformation in PLINK (shows NAs)
gen <- read.table("/Volumes/SSD/Prioritization/files/extractedSNPs/signifSNP2.traw", sep = "\t", header = T)
gen <- cbind(gen[,2],gen[,7:length(gen[1,])]) # keep only relevant columns
g <- gen[,2:length(gen[1,])]
rownames(g) <- gen[,1] # assign rownames as snp names


# SNPeff results
eff <- read.table("/Volumes/SSD/SNPeff/preimpCases.annMOD.vcf", sep = "\t", header = F)
#row.names(eff) <- eff[,3] # assign rownames as snp names
#eff <- eff[,1:9] # keep only info (not genotype)
e <- data.frame(do.call('rbind', strsplit(as.character(eff[,8]),'|',fixed=TRUE)))
row.names(e) <- eff[,3]
cols <- c('ANN','annotation','impact','geneName','geneID','featureType','featureID','transcriptBiotype','rank/total','HGVS.c','HGVS.p','cDNA_position','CDS_position','Protein_position','Distance to feature','Warnings ')
effect <- e[1:16]
colnames(effect) <- cols

# --------------------- NA info -----------------------------------------------------------------------------------------------

# Count NAs per SNP info[1]
count <- c()
for(i in snps){
  NAs <- sum(is.na(g[i,]))
  count <- c(count, NAs)
}

# Create dataframe to store the NA counts
info <- data.frame(SNP=snps,NAs=count,stringsAsFactors=FALSE)
rownames(info)<-info[,1]



# --------------------- Effect info -----------------------------------------------------------------------------------------------

impact <- c()
warning <- c()

for(i in snps){
  # {HIGH,MODERATE, LOW, MODIFIER}
  if(as.character(effect[i,3])=="HIGH"){
    ef <- 4
  }else if(as.character(effect[i,3])=="MODERATE"){
    ef <- 3
  }else if(as.character(effect[i,3])=="LOW"){
    ef <- 2
  }else if(as.character(effect[i,3])=="MODIFIER"){
    ef <- 1
  }
  impact <- c(impact, ef)
  
  # if warning
  w <- as.character(effect[i,16])
  if(grepl("WARNING", w)){
    warning <- c(warning, "yes")
  }else{
    warning <- c(warning, "no")
  }
}

# Merge all in dataframe
info <- cbind(info, impact, warning)


annotation <- c()
for(i in snps){
  if(as.character(effect[i,2])=="3_prime_UTR_variant"
     | as.character(effect[i,2])=="5_prime_UTR_premature_start_codon_gain_variant"
     | as.character(effect[i,2])=="5_prime_UTR_variant"
     | as.character(effect[i,2])=="initiator_codon_variant&non_canonical_start_codon"
     | as.character(effect[i,2])=="protein_protein_contact"
     | as.character(effect[i,2])=="start_lost"
     | as.character(effect[i,2])=="stop_gained"
     | as.character(effect[i,2])=="stop_gained&splice_region_variant"
     | as.character(effect[i,2])=="stop_lost"
     | as.character(effect[i,2])=="stop_retained_variant"
     | as.character(effect[i,2])=="structural_interaction_variant"
     | as.character(effect[i,2])=="TF_binding_site_variant"
     ){
    an <- 2
  }else if(as.character(effect[i,2])=="downstream_gene_variant"
           | as.character(effect[i,2])=="intergenic_region"
           | as.character(effect[i,2])=="intragenic_variant"
           | as.character(effect[i,2])=="intron_variant"
           | as.character(effect[i,2])=="missense_variant"
           | as.character(effect[i,2])=="missense_variant&splice_region_variant"
           | as.character(effect[i,2])=="non_coding_transcript_exon_variant"
           | as.character(effect[i,2])=="PR"
           | as.character(effect[i,2])=="splice_acceptor_variant&intron_variant"
           | as.character(effect[i,2])=="splice_region_variant"
           | as.character(effect[i,2])=="splice_region_variant&intron_variant"
           | as.character(effect[i,2])=="splice_region_variant&non_coding_transcript_exon_variant"
           | as.character(effect[i,2])=="splice_region_variant&synonymous_variant"
           | as.character(effect[i,2])=="sequence_feature"
           | as.character(effect[i,2])=="synonymous_variant"
           | as.character(effect[i,2])=="upstream_gene_variant"
           ){
    an <- 1
  }
  annotation <- c(annotation, an)}
  

# --------------------- Check blocks -----------------------------------------------------------------------------------------------

#set up writing
logFile = "selectSNP.txt"
cat("Blocks of SNPs  >>>  most significant SNPs ", file=logFile, append=FALSE, sep = "\n")

# List to store selected SNPs per block
thegoodones <- c()

# Check blocks
for(i in blocks$SNPS){
  a <- c(strsplit(as.character(i),'|',fixed=TRUE)) # get all SNPs of the block in a list
  thisBlock <- info[info$SNP %in% a[[1]],]
  
  thisBlock <- subset(thisBlock, NAs==min(thisBlock$NAs)) # filter SNPs' with lowest number of NAs
  thisBlock <- subset(thisBlock, impact==max(thisBlock$impact)) # filter SNPs' with highest impact
  thisBlock <- subset(thisBlock, annotation==max(thisBlock$annotation)) # filter SNPs' with most relevant mutation type
  
  thegoodones <- c(thegoodones, thisBlock$SNP[1]) # append one of the good SNPs to the list
  
  # Write all valid SNPs to a file
  cat("\n\n", file=logFile, append=TRUE, sep = "") 
  cat("* ", file=logFile, append=TRUE, sep = "")
  for(i in a){
    cat(i, file=logFile, append=TRUE, sep = ", ")
  }
  cat("  >>>  ", file=logFile, append=TRUE, sep = "")
  cat(thisBlock$SNP, file=logFile, append=TRUE, sep = ", ")

  #for(rs in thisBlock$SNP){print(info[rs,])}

}


# write the selected good SNPs to a txt file
write.table(thegoodones, file='ultimateSNPs.txt', quote=FALSE, sep="\n", col.names = F, row.names = FALSE)



