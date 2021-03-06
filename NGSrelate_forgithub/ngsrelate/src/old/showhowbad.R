library(Relate)
source("simrelatedatafuns.R")
source("ngsrelateHMM_270812.R")

set.seed(1)
k0=0.95
k1=0.05
a=0.06
nind=100
nsnp=1000
nchr=10
dat <-simData(nind=nind,nsnp=nsnp,nchr=nchr,k0=k0,k1=k1,nsnpprcm=5,a=a)
geno<-dat$geno
pos<-dat$pos
chr<-dat$chr
freq<-dat$truefreq
af<-apply(geno-1,2,mean,na.rm=TRUE)/2   

tp<-as.vector(table(c(as.vector(dat$truepaths),0,1,2)))
k0real=(tp[1]-1)/(dim(dat$truepaths)[2]*nchr)
k1real=(tp[2]-1)/(dim(dat$truepaths)[2]*nchr)
k2real=(tp[3]-1)/(dim(dat$truepaths)[2]*nchr)

alim2=0.15

print("How well does Relate do on real genos?")
ra1k2is0<-runHmmld(geno,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.0001,timesToRun=50,timesToConv=20,calc.a=T,fix.k2=0)
ra2k2is0<-runHmmld(geno,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.0001,timesToRun=50,timesToConv=20,calc.a=F,fix.k2=0)
# Does the correct pars give rise to better MLs? (i.e. is there an obsvious convergence problem?)
print(paste("Is ML estimate higher than like for true values:",ra1k2is0$kLike<runHmmld(geno,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.0001,timesToRun=50,timesToConv=20,calc.a=T,par=c(a,k2real,k1real,k0real),fix.k2=T)$kLike))
print(paste("Is ML estimate higher than like for true values:",ra2k2is0$kLike<runHmmld(geno,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.0001,timesToRun=50,timesToConv=20,calc.a=F,par=c(a,k2real,k1real,k0real),fix.k2=T)$kLike))

reslist <- list(ra1k2is0,ra2k2is0)
for(i in 1:length(reslist)){
  xx <-  reslist[[i]]
  for(postthres in c(0.5,0.75,0.9,0.95,0.99)){
    print(paste("Proportion of genome where post of sharing 1 allele is >", postthres," is ",mean(xx$post[2,]>postthres,na.rm=T), sep=""))
  }
  print(paste("Proportion of genome where viterbi path has state 1 is ",mean(xx$path==1,na.rm=T),sep=""))
  print(paste("ML k1 is",as.vector(xx$kResult)[2]))
  print(paste("Proportion of genome where 1 allele is shared ibd is",k1real))  
}

plot(ra2k2is0,chr=1)
points(pos[1:nsnp]/1e6,rep(.5,nsnp),col=-dat$truepaths[1,]+3,pch=20)

print("How well does Relate do on ML genos?")
like1<-getLikes(geno[1,]-1,dep=2)
like2<-getLikes(geno[2,]-1,dep=10)
ML1<-apply(like1,2,which.max)
ML2<-apply(like2,2,which.max)
geno_likebased<-rbind(ML1,ML2,geno[-c(1,2),])
af_likebased<-apply(geno_likebased-1,2,mean,na.rm=TRUE)/2   

ra2xk2is0eps0.01<-runHmmld(geno_likebased,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.01,timesToRun=100,timesToConv=50,calc.a=F,fix.k2=0)
ra2xk2is0eps0.05<-runHmmld(geno_likebased,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.05,timesToRun=100,timesToConv=50,calc.a=F,fix.k2=0)
ra2xk2is0eps0.10<-runHmmld(geno_likebased,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.10,timesToRun=50,timesToConv=50,calc.a=F,fix.k2=0)

# Does the correct pars give rise to better MLs? (i.e. is there an obsvious convergence problem?)
print(paste("Is ML estimate higher than like for true values:",-ra2xk2is0eps0.01$kLike>-runHmmld(geno_likebased,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.01,calc.a=F,par=c(a,k2real,k1real,k0real),fix.k2=0)$kLike))
print(paste("Is ML estimate higher than like for true values:",ra2xk2is0eps0.05$kLike<runHmmld(geno_likebased,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.05,calc.a=F,par=c(a,k2real,k1real,k0real),fix.k2=0)$kLike))
print(paste("Is ML estimate higher than like for true values:",ra2xk2is0eps0.10$kLike<runHmmld(geno_likebased,pair=c(1,2),pos=pos/1e6,chr=chr,back=0,ld_adj=F,alim=c(0.001,alim2),epsilon=0.10,calc.a=F,par=c(a,k2real,k1real,k0real),fix.k2=0)$kLike))

reslist <- list(ra2xk2is0eps0.01,ra2xk2is0eps0.05,ra2xk2is0eps0.10)
for(i in 1:length(reslist)){
  xx <-  reslist[[i]]
  for(postthres in c(0.5,0.75,0.9,0.95,0.99)){
    print(paste("Proportion of genome where post of sharing 1 allele is >", postthres," is ",mean(xx$post[2,]>postthres,na.rm=T), sep=""))
  }
  print(paste("Proportion of genome where viterbi path has state 1 is ",mean(xx$path==1,na.rm=T),sep=""))
  print(paste("ML k1 is",as.vector(xx$kResult)[2]))
  print(paste("Proportion of genome where 1 allele is shared ibd is",k1real))  
}

opti=20
#ri2<-relateHMM(geno_likebased-1,pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.01,calc.a=F,af=af_likebased)
#ri20.15k2is0eps0.01<-relateHMM(geno_likebased-1,pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.01,calc.a=F,af=af_likebased,fix.k2=0)
#relateHMM(geno_likebased-1,pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.01,calc.a=F,af=af_likebased,fix.k2=0,par=c(a,k2real,k1real,k0real))

#ri20.15k2is0eps0.05<-relateHMM(geno_likebased-1,pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.05,calc.a=F,af=af_likebased,fix.k2=0) 
#ri20.15k2is0eps0.10<-relateHMM(geno_likebased-1,pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.10,calc.a=F,af=af_likebased,fix.k2=0)


#ri2x<-ngsrelateHMM(rbind(like1,like2),pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.01,calc.a=F,af=af_likebased)
ngs2k2is0<- ngsrelateHMM(rbind(like1,like2),pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.01,calc.a=F,af=af_likebased,fix.k2=0)
print(paste("Is ML estimate higher than like for true values:",ngs2k2is0$k.loglike>ngsrelateHMM(rbind(like1,like2),pair=c(1,2),pos=pos/1e6,chr=chr,alim=c(0.001,alim2),opti=opti,epsilon=0.01,calc.a=F,af=af_likebased,fix.k2=0,par=c(a,k2real,k1real,k0real))$k.loglike))

reslist <- list(ngs2k2is0)
for(i in 1:length(reslist)){
  xx <-  reslist[[i]]
  for(postthres in c(0.5,0.75,0.9,0.95,0.99)){
    print(paste("Proportion of genome where post of sharing 1 allele is >", postthres," is ",mean(xx$decode$post[,2]>postthres,na.rm=T), sep=""))
  }
  print(paste("Proportion of genome where viterbi path has state 1 is ",mean(xx$decode$path==1,na.rm=T),sep=""))
  print(paste("ML k1 is",as.vector(xx$k)[2]))
  print(paste("Proportion of genome where 1 allele is shared ibd is",k1real))  
}





#### OLD stuff ############

# tp fp length dists



if(FALSE){


## measures of comparison
## Using post:
res <- c()
 for(postthres in c(0.5,0.9,0.95,0.99)){
  truestates <- as.vector(t(dat$truepath))
  postinfstates <- apply(xx$decode$post,1,function(x){if(max(x)>postthres){3-which.max(x)}else{NA}})
  nstates <- dim(xx$decode$post)[1]
  cs  <- sum(truestates==postinfstates,na.rm=T)
  ws  <- sum(truestates!=postinfstates,na.rm=T)
  na  <- sum(is.na(postinfstates))
  tp  <- sum(which(postinfstates==1)%in%which(truestates==1))
  fp  <- sum(!(which(postinfstates==1)%in%which(truestates==1))) 
  tn  <- sum(which(postinfstates==0)%in%which(truestates==0))
  fn  <- sum(!(which(postinfstates==0)%in%which(truestates==0)))
  res <- rbind(res,c(cs,ws,na,tp,fp,tn,fn))
}

## Using viterbi
vitinfstates <- xx$decode$path
cs  <- sum(truestates==vitinfstates,na.rm=T)
ws  <- sum(truestates!=vitinfstates,na.rm=T)
na  <- sum(is.na(vitinfstates))
tp  <- sum(which(vitinfstates==1)%in%which(truestates==1))
fp  <- sum(!(which(vitinfstates==1)%in%which(truestates==1)))
tn  <- sum(which(vitinfstates==0)%in%which(truestates==0))
fn  <- sum(!(which(vitinfstates==0)%in%which(truestates==0)))
res <- rbind(res,c(cs,ws,na,tp,fp,tn,fn))           

colnames(res) <- c("Corr","Not corr","NAs","TP","FP","TN","FN")
print(round(res,2))

k1est <- (res[,"TP"]+res[,"FP"])/(-res[,"NAs"]+nstates)
k0est <- (res[,"TN"]+res[,"FN"])/(-res[,"NAs"]+nstates)
fraccorr <- (res[,"TP"]+res[,"TN"])/(-res[,"NAs"]+nstates)
fracnotcorr <- (res[,"FP"]+res[,"FN"])/(-res[,"NAs"]+nstates)
