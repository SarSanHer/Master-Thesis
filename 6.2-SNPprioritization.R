### SARA SANCHEZ-HEREDERO MARTINEZ
### Script to do SNP prioritization using machine learning

# --------------------- Load packages -----------------------------------------------------------------------------------------------
library(RANN)
library(FNN)
library(unbalanced)
library(parallel)
library(Hmisc)
library(rpart)
library(rpart.plot)
library(scales)
library(mlbench)
library(caret)
library(C50)
library(tree)
library(RWekajars)
library(RWeka)
library(Mlmetrics)
library(dismo)
library(gbm)
library(ggRandomForests)
library(randomForestSRC)
library(SNPassoc)
library(Epi)
library(pscl)
library(Rcmdr)
library(qvalue)
library(randomForest)
library(ggplot2)
library(ROCR)
library(stats)
library(caret)
library(DMwR)
library(DMwR2)
library(grid)
library(reshape)
library(ggthemes)
library(sandwich)
library(e2072)
library(dplyr)
library(MASS)
library(varSelRF)
library(reshape2)
library(party)
library(ggthemes)
library(AppliedPredictiveModeling)
library(mlbench)
library(ROSE)
library(pROC)
library(doParallel)
library(ggvis)
library(mlr)
library(ParamHelpers)
library(RANN)
library(FNN)
library(unbalanced)
library(parallel)
library(Hmisc)
library(rpart)
library(rpart.plot)
#library(Rcmdr)
library(pscl)
library(scales)
library(mlbench)
library(caret)
library(C50)
library(tree)
library(randomUniformForest)
library(RWekajars)
library(RWeka)
library(Mlmetrics)
library(dismo)
library(gbm)
library(ggRandomForests)
library(randomForestSRC)
library(SNPassoc)
library(Epi)
library(pscl)
library(Rcmdr)
library(qvalue)
library(randomForest)
library(ggplot2)
library(ROCR)
library(stats)
library(caret)
library(DMwR)
library(DMwR2)
library(grid)
require(rfUtilities)
library(randomForest)
library(ggplot2)
library(ROCR)
library(stats)
library(caret)
library(DMwR)
library(grid)
require(rfUtilities)
library(reshape)
library(ggthemes)
library(sandwich)
library(e2072)
library(dplyr)
library(MASS)
library(varSelRF)
library(reshape2)
library(party)
library(ggthemes)
library(AppliedPredictiveModeling)
library(mlbench)
library(ROSE)
library(pROC)
library(doParallel)
library(ggvis)
library(mlr)
library(ParamHelpers)
library(RANN)
library(FNN)
library(unbalanced)
library(parallel)
library(Hmisc)
library(rpart)
library(rpart.plot)
library(pscl)
library(scales)
library(mlbench)
library(caret)
library(C50)
library(tree)
library(caret)
library(csv)
library(csvread)
library(Rcmdr)
library(readxl)
library(rfUtilities)
library(MLmetrics)


# --------------------- Load train -----------------------------------------------------------------------------------------------
# genotype file
plink <- read.table("/Volumes/SSD/Prioritization/files/train/bestSNP/bestSNP.raw", sep = " ", header = T, row.names = 2)
plink <- plink[6:length(plink[1,])]

# phenotype file
phen <- read.table("/Volumes/SSD/GAPIT/inputs/train_phen.txt" , head = TRUE, row.names = 1, sep = '\t') #ID BMI Age

# merge both to create apropiate input
data <- merge(phen, plink, by=0, all = T, )     # ID BMI Age SNPs
row.names(data)<- data[,1]                      # Assign row names

# Clean data
data[1] <- NULL                                 # Remove first col (contains row names)
data = data[!row.names(data)%in%c('1_10_086'),] # Remove this row because we dont have BMI info
data = data[!row.names(data)%in%c('MARHC796'),] # Remove this row because it has one NA :(
data[,'rs12610520_1'] <- NULL                   # Remove this col because it has too many NAs

# Correct data format
data$Age <- as.numeric(data$Age)
indx <- sapply(data, is.integer)
data[indx] <- lapply(data[indx], function(x) as.factor(x))

lvls <- c('0', '1', '2')
data[indx] <-  lapply(data[indx], factor, levels=lvls)


# Overview of data
summary(data)
str(data)



# --------------------- Load test -----------------------------------------------------------------------------------------------
t <- read.table("/Volumes/SSD/Prioritization/files/test/bestSNPs.raw", sep = " ", header = T, row.names = 2)
t <- t[6:length(t[1,])]

# phenotype file
p <- read.table("/Volumes/SSD/GAPIT/inputs/val_phen.txt" , head = TRUE, row.names = 1, sep = ',') #ID BMI Age

# merge both to create apropiate input
test <- merge(p, t, by=0, all = T, )     # ID BMI Age SNPs
row.names(test)<- test[,1]               # Assign row names

# Clean data
test[1] <- NULL                                 # Remove first col (contains row names)
test = test[!row.names(test)%in%c('ARS278'),]   # Remove this row because we dont have BMI info
test[,'rs12610520_1'] <- NULL                   # Remove this col because it has too many NAs

# remove people with NAs
which(is.na(test))
test = test[!row.names(test)%in%c('ARS025'),]   # Remove this row because we dont have BMI info
test = test[!row.names(test)%in%c('ARS036'),]   # Remove this row because we dont have BMI info
test = test[!row.names(test)%in%c('ARS037'),]   # Remove this row because we dont have BMI info

# Correct data format
test$BMI <- as.numeric(test$BMI)
test$Age <- as.numeric(test$Age)
indx <- sapply(test, is.integer)
test[indx] <- lapply(test[indx], function(x) as.factor(x))

lvls <- c('0', '1', '2')
test[indx] <-  lapply(test[indx], factor, levels=lvls)

# Overview of data
summary(test)
str(test)




# --------------------- RANDOM FOREST -----------------------------------------------------------------------------------------------

###### ASSESS PARAMETERS ###

# Random Search
control <- trainControl(method="repeatedcv", number=10, repeats=5, search="random")
set.seed(8)
rf_random <- train(BMI~., data=data, method="rf", metric="RMSE", tuneLength=15)     
print(rf_random)
plot(rf_random)
  ### The final value used for the model was mtry = 33


# Manual: gráfico del error OOB en cada iteracion, es lo mismo, busqueda de parametros
params <- tuneRF(x = data,       # data set de entrenamiento 
       y = data$BMI,  # variable a predecir
       mtryStart  = 1,   # cantidad de variables inicial 
       stepFactor = 2,   # incremento de variables
       ntreeTry   = 1000, # cantidad arboles a ejecutar en cada iteracion
       improve    = .05,  # mejora minima del OOB para seguir iteraciones, una vez se alcanza ese valor el algoritmo para
       plot=TRUE,
       trace=TRUE, 
       importance=TRUE
)




###### RUN ###
rf.mdl<-randomForest(BMI~.,data=data, mtry=17,keep.inbag=TRUE, importance=TRUE,ntree=2000, prox=TRUE,localImp=TRUE,norm.votes=TRUE,importanceSD=TRUE,confusion=TRUE)
print(rf.mdl) # log
summary(rf.mdl)
plot(rf.mdl) # graph, check number of trees for convergence -> 200?

#write.table(rf.mdl$importance, file='importance.csv', quote=FALSE, sep=";", col.names = T, row.names = T)


###### CROSS VALIDATION ###
rf.cv <- rf.crossValidation(rf.mdl, 
                            data[,2:length(data)], # variables que quiero que utilice el modelo (todo menos BMI)
                            p=0.20, 
                            n=5, # k?
                            ntree=1000) 
summary(rf.cv)



###### SAVE MODEL ###
save(rf.mdl, file="BMI.mdl") # guardar el RF que hemos creado
#rf.mdl<-load(file="BMI.mdl")



###### Some info ###
# Print one tree
tree<-getTree(rf.mdl, k=200, labelVar=TRUE) # no lo necesitamos: saca un arbol del bosque para ver cómo son
tree

# graphical depiction of the marginal effect of a variable on the class response
partialPlot(rf.mdl, data, Age, "0", xlab="Age", main="BMI")



###### IMPORTANCE ###
options(max.print=1000000)  # print computation

# SNP METHOD
X <- within(data, BMI <- NULL )
X = data.frame(X) #generar dataframe para lo que quieres predecir y otra para lo demas
Y = (data$BMI)
Y <- as.numeric(Y) #debera ser numeric

library(vita) # la del paquete chachi
vari= compVarImp(X,Y,rf.mdl)
vari$importance
vari$importanceSD
summary(vari)
#write.table(vari$importanceSD, file='importance.csv', quote=FALSE, sep=";", col.names = T, row.names = T, dec = ',')



###### VALIDATION ###
predicciones <- predict(object = rf.mdl, test) # mi RF model + valdecillas
plot(predicciones,test$BMI, col = "steelblue4", main = "Prediccion vs valor real", 
     pch = 19, xlab = "predicciones", ylab = "test", abline(0, 1)) # EDITAR PARA CUANTITATIVAS


# PARAMETROS DE CALIDAD DE LA VALIDACION (all NAs)
MAPE(y_pred=as.vector(predicciones), y_true=as.vector(test$BMI))
MSE(y_pred=predicciones, y_true=test$BMI)
RMSE(y_pred=predicciones, y_true=test$BMI)
RMSLE(y_pred=predicciones, y_true=test$BMI)  #Root mean square logarithmis error loss
RMSPE(y_pred=predicciones, y_true=test$BMI)  #Root mean square percentage error loss

R2_Score(y_pred=predicciones, y_true=test$BMI)
RAE(y_pred=predicciones, y_true=test$BMI) ##Relative Absolute error Loss


# cross-validated permutation variable importance -> mueve snp random y si sale significativo entonces es que no era verdaderamente significativo
cv_vi = CVPVI(X,Y,k = 21, mtry = 17, ntree =3000)
summary(cv_vi)
cv_vi$cv_varim
#write.table(cv_vi$cv_varim, file='importance.csv', quote=FALSE, sep=";", col.names = T, row.names = T, dec = ',')

# Novel Test approach
cv_p = NTA(cv_vi$cv_varim)
summary(cv_p,pless = 0.05)
#write.table(summary(cv_p,pless = 0.05), file='importance.csv', quote=FALSE, sep=";", col.names = T, row.names = T, dec = ',')
summary(cv_p,pless = 0.1)


# --------------------- RANDOM UNIFORM FOREST -----------------------------------------------------------------------------------------------

###### PREPARE DATA ###
#Train
train<-within(data, {BMI <- as.numeric(BMI)})
X <- as.matrix(within(train, BMI <- NULL ))
Y <- as.numeric(train$BMI)

#Validation
test2<-within(test, {BMI <- as.numeric(BMI)})
X1 <- as.matrix(within(test2, BMI <- NULL ))
Y1 <- as.numeric(test$BMI)



###### RUN ###
rufen <- randomUniformForest(BMI~.,data=train,mtry = "random",ntree=2000,nodesize=1,replace=TRUE,OOB=TRUE, depthcontrol=TRUE,BreimanBounds=TRUE,bagging=TRUE,featureselectionrule = "entropy") 
plot(rufen)
summary(rufen)

rufgi <- randomUniformForest(BMI~.,data=train,mtry = "random",ntree=2000,maxVar=30,nodesize=1,replace=TRUE,OOB=TRUE, depthcontrol=TRUE,BreimanBounds=TRUE,bagging=TRUE,featureselectionrule = "gini") 
plot(rufgi)
summary(rufgi)



###### Some info ###
pr.rufen<-predict(rufen, X1)
ms.rufen<-model.stats(pr.rufen, Y1, regression = T)


OneTree <- getTree.randomUniformForest(rufen, 20)
plotTree(OneTree) ###parte de ejemplo de un arbol
plotTree(OneTree, fullTree = TRUE, xlim = c(1,20), ylim = c(0, 20)) ####todo el arbol de ejemplo



###### IMPORTANCE ###
imp.rufgi <- randomUniformForest::importance(rufgi, Xtest = test, maxInteractions = 20, maxVar=30)
imp.rufen <- randomUniformForest::importance(rufen, Xtest = test, maxInteractions = 20, maxVar=30)
plot(imp.rufgi,  Xtest=train, nLocalFeatures = 30)
plot(imp.rufgi, Xtest=train)

#write.table(imp.rufen[["globalVariableImportance"]], file='importance.csv', quote=FALSE, sep=";", col.names = T, row.names = T, dec = ',')


### hacer importancia como RF 

partialDependenceBetweenPredictors(Xtest = X1,  
                                   importanceObject = imp.rufen,
                                   features = c("rs72814718_1", "rs114680917_1"),
                                   whichOrder = 'all',
                                   perspective = FALSE,
                                   outliersFilter = FALSE)


# --------------------- GRADIENT BOOSTING -----------------------------------------------------------------------------------------------

###### ASSESS PARAMETERS ###
gbm.step <- gbm.step(dat=data, 
                     gbm.x = 2:110, # predictor columns
                     gbm.y = 1, # response column
                     family = "gaussian",                              
                     tree.complexity = 10, # depth of individual trees
                     learning.rate = 0.01, 
                     bag.fraction = 0.8, # percentage of data used in each tree
                     step.size=0.01,
                     tolerance.method="auto",
                     n.trees = 1000) 


print(gbm.step)
summary(gbm.step)
names(gbm.step)
gbm.step$n.trees
gbm.step$cv.roc.matrix
print(gbm.step)



###### RUN ###

#Ajusta el modelo automaticamente o eliminanado el numero de variables que quiera
arbolsimp<-gbm.simplify(gbm.step, n.folds = 10, n.drops = 90, # try n.drops = 90
                        alpha = 1, prev.stratify = TRUE,
                        eval.data = NULL, plot = TRUE)
summary(arbolsimp)
print(arbolsimp)
save(gbm.step, file="arbolsimp_BMI.mdl")

# esto si no funciona lo de antes
gbm.sim <- gbm.step(dat=data, 
                    gbm.x = arbolsimp$pred.list[[90]], #Columnas de los predictores
                    gbm.y = 1, # Columna de la variable respuesta
                    family = "gaussian",  #"bernouilli"  para respuesta binomial                            
                    tree.complexity = 30, #complejidad (profundidad) de los ?rbooles individuales
                    learning.rate = 0.001, 
                    max.trees = 10000,
                    bag.fraction = 0.8, #Proporci?n de datos considerados para construir cada ?rbol.
                    step.size=0.1,
                    tolerance.method="auto"
) 
summary(gbm.sim)

gbm.fit <- gbm(
  formula = BMI ~ .,
  distribution = "gaussian",
  data = data,
  n.trees = 5000,
  interaction.depth = 3,
  shrinkage = 0.1,
  cv.folds = 5,
  n.cores = NULL, # will use all cores by default
  verbose = FALSE
)  

print(gbm.fit)
gbm.perf(gbm.fit, method = "cv")
---------------------------------------------------------------------
  
#Lo primero que podemos hacer es representar el efecto parcial de cada una de las VE:

par(mfrow=c(1), mar=c(2), oma=c(1))
gbm.plot(gbm.sim,  write.title = TRUE)

par(mfrow = c(1, 2))
gbm.plot(gbm.sim, i.var = "Age", col = "firebrick",main="Age")
plot(gbm.sim, i.var = "Age", col = "green",main="")

par(mfrow=c(4,3), mar=c(2,2,2,2), oma=c(1,1,1,1))
gbm.plot.fits(gbm.sim)


gbm.plot(gbm.sim, n.plots=12, write.title = TRUE)

par(mfrow=c(3,3), mar=c(2,2,2,2), oma=c(1,1,1,1))
gbm.plot.fits(gbm.sim)




# We can also see here which variables interact more stronlgy between each other
interaction<-gbm.interactions(gbm.sim)
interaction
interaction$rank.list
interaction$interactions
write.table(interaction$interactions, file='importance.csv', quote=FALSE, sep=";", col.names = T, row.names = T, dec = ',')


#Elegimos las dos variables con una mayor interacci?n
gbm.perspec(gbm.sim, 84,38)

-----------------------------------------------------------------------
predict.gbm(gbm.sim,test, n.trees=50, type="response")
preds <- c(-27.67909,-27.77513,-27.80190,-27.69347,-27.71407,-27.61017,-27.72542,-27.70212,-27.67244,-27.61650,-27.68758,-27.73423,-27.73730,-27.71921,-27.68680,-27.73299,-27.71630,-27.71112,-27.71126,-27.68450,-27.57720,-27.69655,-27.66785,-27.72244,-27.72605,-27.68149,-27.65428,-27.73634,-27.68570,-27.70280,-27.81949,-27.75129,-27.42941,-27.66978,-27.52290,-27.61025,-27.47512,-27.70221,-27.73635,-27.64089,-27.52729,-27.71177,-27.73368,-27.73789,-27.72528,-27.67840,-27.58120,-27.70511,-27.81482,-27.70637,-27.76018,-27.50380,-27.72815,-27.81012,-27.71248,-27.77785,-27.69914,-27.77520,-27.72130,-27.70780,-27.74074,-27.72418,-27.72776,-27.65052,-27.70268,-27.73204,-27.52690,-27.66093,-27.70457,-27.71737,-27.72407,-27.71301,-27.73407,-27.73789,-27.73829,-27.54324,-27.57915,-27.71007,-27.69084,-27.67293,-27.66902,-27.75698,-27.70169,-27.62251,-27.71224,-27.78173,-27.70498,-27.70761,-27.65550,-27.70744,-27.63305,-27.65464,-27.75799,-27.78129,-27.69357,-27.68539,-27.66864,-27.64956,-27.67864,-27.73670,-27.65763,-27.71046,-27.71848,-27.70020,-27.72396,-27.52338,-27.75161,-27.50218,-27.75190,-27.65534,-27.73439,-27.50971,-27.66863,-27.69222,-27.80203,-27.70460,-27.68027,-27.74030,-27.69205,-27.77880,-27.74018,-27.82990,-27.57198,-27.77181,-27.46401,-27.69386,-27.50708,-27.73267,-27.65521,-27.71691,-27.79761,-27.68317,-27.74954,-27.74844,-27.73090,-27.74561,-27.69651,-27.67105,-27.70188,-27.66718,-27.73128,-27.72395,-27.70413,-27.51110,-27.64749,-27.47483,-27.75199,-27.71730,-27.70530,-27.77443,-27.64490,-27.61499,-27.74341,-27.69428,-27.77275,-27.66411,-27.72595,-27.75711,-27.83700,-27.70254,-27.72520,-27.67948,-27.77021,-27.59882,-27.76031,-27.55654,-27.70610,-27.54093,-27.71032,-27.72364,-27.58332,-27.67240,-27.71800,-27.63676,-27.70753,-27.68667,-27.73572,-27.66145,-27.76969,-27.73491,-27.68458,-27.62017,-27.70594,-27.71391,-27.80833,-27.65347,-27.72707,-27.73390,-27.70781,-27.70944,-27.75991,-27.74070,-27.59831,-27.66457)

# Generate predictions on test dataset
preds <- predict(gbm.sim, newdata = test, n.trees = 99)
labels <- test[,"BMI"]

par(mfrow=c(1,1))
plot(p,test$BMI, col = "steelblue4", main = "Prediccion vs valor real", 
     pch = 19, xlab = "predicciones", ylab = "test", abline(0, 1))



test_mse <- mean((preds - test$BMI)^2)
test_mse

library(MLmetrics)

MAPE(preds,test$BMI)
MSE(y_pred=preds, y_true=test$BMI)
RMSE(y_pred=preds, y_true=test$BMI)
RMSLE(y_pred=preds, y_true=test$BMI)  #Root mean square logarithmis error loss
RMSPE(y_pred=preds, y_true=test$BMI)  #Root mean square percentage error loss
R2_Score(y_pred=preds, y_true=test$BMI)
RAE(y_pred=preds, y_true=test$BMI) ##Relative Absolute error Loss






