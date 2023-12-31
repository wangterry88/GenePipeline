#setwd("/media/volume1/bioinfo/gene_platform/Plink-R-web/gwas")
setwd("./")
#############

#args = commandArgs(trailingOnly=TRUE)
cat(prompt="Input GWAS results (Full directory): ")
GWAS_RESULT<-readLines(con="stdin",1)

cat(prompt="Output plot file name (Short Name): ")
PLOT_OUT<-readLines(con="stdin",1)

cat(prompt="Output PRS Base summary file name (Short Name): ")
PRS_OUT<-readLines(con="stdin",1)

######### Install packages ###########


library(data.table)
library(dplyr)
library(ggplot2)
library(snpStats)
library(qqman)


gwas.result<-fread(GWAS_RESULT,sep="\t",header = T)

manhattan_data<-na.omit(gwas.result)

colnames(manhattan_data)[1]<-"CHR"
colnames(manhattan_data)[2]<-"BP"
colnames(manhattan_data)[3]<-"SNP"

manhattan_data<-manhattan_data[!grepl("MT|X|Y",manhattan_data$CHR), ]
tail(manhattan_data)


manhattan_data$CHR<-as.numeric(manhattan_data$CHR)
manhattan_data_nosex<-subset(manhattan_data,manhattan_data$CHR<23)

### Output PRS-ready summary data

PRS_Sig_data=subset(manhattan_data_nosex,manhattan_data_nosex$P<0.05)
PRS_Sig_data_unipue=distinct(PRS_Sig_data,SNP,.keep_all = T)

tmp_PRS=paste0('./GWAS/',PRS_OUT,'.PRS.Sig-0.05.txt',collapse = '')
fwrite(PRS_Sig_data_unipue,tmp_PRS,sep="\t",col.names=T)


### Output Gene-info summary data

annot_data<-manhattan_data_nosex[,c("CHR","BP","SNP","OR","P")]
tmp_annot=paste0('./GWAS/',PLOT_OUT,'.GWAS.annot.data.txt',collapse = '')
fwrite(annot_data,tmp_annot,sep="\t",col.names=T)

### Output manhattan plot data

tmp_manhattan=paste0('./GWAS/plot/',PLOT_OUT,'.manhattan.png',collapse = '')

png(file=tmp_manhattan, width = 2000,height = 1000,pointsize = 18)
par(cex=1.2)
color_set <-c("#8DA0CB","#E78AC3","#A6D854","#FFD92F","#E5C494","#66C2A5","#FC8D62")
manhattan(manhattan_data_nosex,
          col = color_set,
          suggestiveline = -log10(1e-05),
          genomewideline = -log10(5e-08),
          logp = T,
          annotatePval = 0.01,
          annotateTop=TRUE
)
dev.off()

# Plot QQ plot  (No sex)
qqdata<-manhattan_data_nosex$P

tmp_QQ=paste0('./GWAS/plot/',PLOT_OUT,'.QQ.png',collapse = '')

png(file=tmp_QQ, width = 2000,height = 1000,pointsize = 18)
qq.chisq(-2 * log(qqdata), df = 2, conc=c(0.05, 0.95),main = "Q-Q plot of GWAS p-values")
abline(0,1)
dev.off()

cat("Base file (GWAS summary stat.) was in : \n",tmp_PRS)
cat("\n")
cat("\n")
cat("Gene-info summary data (GWAS summary stat.) was in : \n",tmp_annot)
cat("\n")
cat("\n")