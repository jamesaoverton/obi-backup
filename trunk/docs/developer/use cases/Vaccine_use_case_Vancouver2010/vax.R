setwd(".");
a<-read.table('vaxar.txt', header=T, sep="\t");
library(dprep)
b<-disc.ew(a,c(11,15,16,17,18))
fit<-lm(CFU_dif ~ ., data=b)
anova(fit)

