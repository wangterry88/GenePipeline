setwd("./")

library(data.table)
library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
GWAS_name <-args[1]

# Gene result
gene_result_tmp<-paste0('./output/Result/',GWAS_name,'/',GWAS_name,'.Gene.result.genes.out')
gene_result<-fread(gene_result_tmp)

# Gene result adjust
gene_adj<-gene_result
gene_adj_P<-gene_adj$P
gene_adj_N<-length(gene_adj_P)

gene_adj$Padj_Bonf<-p.adjust(gene_adj_P,method="bonferroni",gene_adj_N)
gene_adj$Padj_BH<-p.adjust(gene_adj_P,method="BH",gene_adj_N)

# Gene result adjust output
gene_adj_tmp<-paste0("./output/Result/",GWAS_name,"/",GWAS_name,".Gene.result.adj.txt")
fwrite(gene_adj,gene_adj_tmp,sep="\t",col.names=T)

# Pahtway result
pathway_result_tmp<-paste0("./output/Result/",GWAS_name,"/",GWAS_name,".Pathway.result.txt")
pathway_result<-fread(pathway_result_tmp)

# Pahtway result adjust
Pahtway_adj<-pathway_result
Pahtway_adj_P<-Pahtway_adj$P
Pahtway_adj_N<-length(Pahtway_adj_P)

Pahtway_adj$Padj_Bonf<-p.adjust(Pahtway_adj_P,method="bonferroni",Pahtway_adj_N)
Pahtway_adj$Padj_BH<-p.adjust(Pahtway_adj_P,method="BH",Pahtway_adj_N)

# Pahtway result adjust output
Pahtway_adj_tmp<-paste0("./output/Result/",GWAS_name,"/",GWAS_name,".Pahtway.result.adj.txt")
fwrite(Pahtway_adj,Pahtway_adj_tmp,sep="\t",col.names=T)