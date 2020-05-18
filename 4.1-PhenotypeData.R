### Script by Sara Sanchez Heredero
### Function: Analysis of the distribution of the BMI phenotypic data, 
#             study the association between BMI and other variables (smoking, age, ACPA and rheumatoid factor),
#             and save csv-format phenotype to HapMap compatible format



#------------------- Load libraries ------------------------------------------------------------------------------------------------
library(nortest) #lillie.test
library(ggplot.multistats)
library(rriskDistributions)
library(MASS)
library(survival)
library(npsurv)
library(lsei)
library(fitdistrplus)
library(moments)
library(e1071)
library(dplyr) 
library(ggplot2) # plots
library(GGally)
library (finalfit) # ff_glimpse to see our data info
library (Hmisc) # correlation matrix
library(corrplot) # plot correlation
library(car)
library(lme4)
library(MuMIn) # dredging
library(relaimpo)




# --------------------- Load data -----------------------------------------------------------------------------------------------
data <- read.csv('data.csv',sep = ';', header = T, row.names = 1, dec = ',') 

# Load IDs from train (La Princesa, Clinico, La Paz) and test (Valdecillas)
train = read.csv('distribution/train-val/IDs_train.txt', header = F)
val = read.csv('distribution/train-val/IDs_val.txt', header = F)




# --------------------- BMI distribution -----------------------------------------------------------------------------------------------

### BMI
bmi <-as.numeric(data[,11])
test <- lillie.test(bmi)
fit.cont(bmi)

### Age
age <-as.numeric(data[,13])
test <- lillie.test(age)
fit.cont(age)





# --------------------- Covariates analysis -----------------------------------------------------------------------------------------------

### Data Preparation: select only columns I need and change column names
mydata <- data.frame(data$ID_ichip,data$BMI.cal,data$FactorReumatoide,data$ACPA,data$Fumador,data$Sexo,data$round_age)
mydata <- mydata[1:1010,]
mydata <- mydata[,2:7]
colnames(mydata)<-c('BMI', 'FR', 'ACPA', 'Smoker', 'Sex', 'Age')



### general analysis

# Data overview
summary(mydata) 

# Homogenice class 2 for ACPA values
levels(mydata$ACPA)[levels(mydata$ACPA) == ""] <- NA
levels(mydata$ACPA)[levels(mydata$ACPA) == "GRIS"] <- NA
factor(mydata$ACPA)

# Homogenize for smokers
levels(mydata$Smoker)[levels(mydata$Smoker) == ""] <- NA
levels(mydata$Smoker)[levels(mydata$Smoker) == "ns"] <- NA


# Function to remove NA's in specific columns
completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}

# Remove NA's 
mydata <- completeFun(mydata, "FR") # 2 row
mydata <- completeFun(mydata, "Sex") # 1 row
mydata <- completeFun(mydata, "ACPA") # 118 rows
mydata <- completeFun(mydata, "Smoker") # 53 rows


# Transform columns to the right class
glimpse(mydata)
mydata$FR <-as.factor(mydata$FR)
mydata$Sex <- as.factor(mydata$Sex)
mydata$Age <- as.numeric(mydata$Age)

# Data overview
summary(mydata) ### Now it has 849 observations from the original 1011
glimpse(mydata)


### Correlation

# Analysis of the correlation
cor_matrix <- rcorr(as.matrix(mydata[2:7])) #default is pearson correlation coefficient 
cor<-cor_matrix$r # Extract the correlation coefficients
p_val<-cor_matrix$P # Extract p-values

#Plot correlation to understand results
corrplot(cor_matrix$r, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45, )

      # Doesn't show much correlation, we will do this analysis in other ways to check


### Step 1: check variables one by one

age <- glm(formula= BMI ~ Age, data=mydata, family = gaussian) # study correlation
summary(age) # overview of the analysis -> correlated -> older ~ higher BMI
Anova(age) # check significance of results -> significant 

sex <- glm(formula= BMI ~ Sex, data=mydata, family = gaussian) 
summary(sex) # not correlated 
Anova(sex) # NOT significant 

fr <- glm(formula= BMI ~ FR, data=mydata, family = gaussian) 
summary(fr) # not correlated 
Anova(fr) # NOT significant

acpa <- glm(formula= BMI ~ ACPA, data=mydata, family = gaussian) 
summary(acpa) # not correlated 
Anova(acpa) # NOT significant

smoke <- glm(formula= BMI ~ Smoker, data=mydata, family = gaussian) 
summary(smoke) # almost correlated -> smokers ~ lower BMI
Anova(smoke) # almost significant (0.0709)


# To check BMI values given a class in a specific trait:
summary(subset(mydata, mydata$Smoker == 0))
summary(subset(mydata, mydata$Smoker == 1))



### Step 2: multivariate analysis
model <- glm(formula= BMI ~ Sex + Age + FR + ACPA + Smoker, data=mydata, family = gaussian)
summary(model)
Anova(model) ## Acpa and age are correlated
vif(model) ## results close to 1 == no collinearity



### All possible analises, compare and select best
fm1 <- lm(BMI ~ ., data = mydata, na.action = "na.fail")
dd <- dredge(fm1)

# Best models: (Intrc) ACPA  Age     FR Sex Smokr df    logLik    AICc    delta  weight
#               23.98   +   0.06391   +            5   -2545.372  5100.8  0.00    0.133
#               23.95       0.06441                3   -2547.507  5101.0  0.23    0.214
#               24.26       0.06344   +            4   -2546.818  5101.7  0.87    0.155


# Best model:
best <- glm(formula= BMI ~ ACPA + Age + FR, data=mydata, family = gaussian)
summary(best)
Anova(best) ## ACPA, Age and FR are all significant
vif(best) 


# Check relative importance of factors:
a <- calc.relimp(best, type = "lmg") ### ACPA and FR explain very little




# --------------------- Export data -----------------------------------------------------------------------------------------------

### Subset dataframes

# Transform ID's dataframes to lists
train <- train$V1
val<- val$V1

# Create dataframe with relevant phenotypic data
mydata <- data.frame(data$ID_ichip,data$BMI.cal, data$round_age)


# Create dataframes with the IDs in the lists
train_df <- mydata[mydata$data.ID_ichip %in% train,]
val_df <- mydata[mydata$data.ID_ichip %in% val,]


# Rename cols
colnames(train_df)<-c('ID', 'BMI', 'Age')
colnames(val_df)<-c('ID', 'BMI', 'Age')



### Write files

write.table(train_df, file='train_phen.txt', quote=FALSE, sep="\t", col.names = T, row.names = FALSE)
write.table(val_df, file='val_phen.txt', quote=FALSE, sep="\t", col.names = T, row.names = FALSE)










