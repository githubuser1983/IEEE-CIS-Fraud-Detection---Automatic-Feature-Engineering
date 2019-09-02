tt <- read.csv("train_transaction1000.csv",sep=",",header=T,stringsAsFactors = FALSE)
catVarsTT <- c("ProductCD","card1","card2","card3","card4","card5","card6","addr1","addr2","P_emaildomain","R_emaildomain",paste("M",seq(1,9),sep=""))
classVar <- c("isFraud")
removeVar <- c("TransactionID")
numVarsTT <- setdiff(names(tt),c(catVarsTT,classVar,removeVar))
NcatTT <- length(catVarsTT)

print(NcatTT)

for(numvar in numVarsTT){
    tt[is.na(tt[,numvar]),numvar] <- median(tt[!is.na(tt[,numvar]),numvar])
}
for(catvar in catVarsTT){
    tt[is.na(tt[,catvar]),catvar] <- "na"
}

# keep only dependent variables:
depCatVars <- c()
for(catvar in catVarsTT){
    print(catvar)
    t <- table(tt[,classVar],tt[,catvar])
    chsqt <- chisq.test(t)
    print(t)
    print(chsqt)
    if( chsqt$p.value < 0.05 ){
        depCatVars <- c(depCatVars,catvar)
    }
}
print(depCatVars)

depNumVars <- c()
for(numvar in numVarsTT){
    print(numvar)
    x <- tt[tt[,classVar]==1,numvar]
    y <- tt[tt[,classVar]==0,numvar]
    t <- ks.test(x,y)
    print(t)
    if( t$p.value < 0.05){
        depNumVars <- c(depNumVars,numvar)
    }
}
print(depCatVars)
print(length(depCatVars))
print(depNumVars)
print(length(depNumVars))


# randomly assign 'T' for 20% (= 200) as classVar
s <- sample(seq(1,dim(tt)[1]))[1:200]

tt[,"class"] <- tt[,classVar]
tt[s,"class"] <- "T"

tt <- cbind(tt[,classVar],tt[,"class"],tt[,depCatVars],scale(tt[,depNumVars]))
write.table(tt,"tt1000.csv",sep=",",col.names=F,row.names=F)


