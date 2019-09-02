ttf <- read.csv("tt1000-50-features.csv",header=F,sep=",")
library(randomForest)
library(e1071)
library(umap)
library(ROSE)
library(rgl)
library(pROC)

set.seed(12345)

d <- ttf

NPoints <- dim(d)[1]
NVars <- dim(d)[2]
vars <- seq(3,NVars)

x <- d[,vars]


c <- umap.defaults
c$n_components <- 3
u <- umap(x,c)
plot3d(u$layout,col=ifelse(d[,1]==1,"green","red"))

s <- sample(seq(1,NPoints))[1:round(0.8*NPoints)]

xtrain <- d[s, vars]
xtest <- d[-s, vars]
ytrain <- d[s,1]
ytest <- d[-s,1]

dftrain <- data.frame(y=as.factor(ytrain),xtrain)
dftest <- data.frame(y=as.factor(ytest),xtest)

dftrain <- ROSE(y ~ ., data = dftrain, seed = 1)$data

rf <- randomForest(y~.,data=dftrain)
sv <- svm(y~.+0,data=dftrain,probability=T)
print(rf)

pr <- predict(rf,newdata=dftest,type="prob")
prSv <- predict(sv,newdata=dftest)

yRf <- ifelse(pr[,1]>=0.5,1,0)
subs <- yRf == ytest

tsv <- table(prSv,ytest)
print(tsv)
print(sum(diag(tsv))/sum(tsv))

prediction <- predict(sv,newdata=xtest,probability=T)

roc_obj_sv <- roc(response=ytest, predictor=attr(prediction,"probabilities")[,1],auc=T)
print(auc(roc_obj_sv))

roc_obj_rf <- roc(response=ytest, predictor=pr[,1],auc=T)
print(auc(roc_obj_rf))

