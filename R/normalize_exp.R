#normalize impact data

source("http://www.bioconductor.org/biocLite.R")
biocLite("DESeq")
require("DESeq")

impact.rpkm <- read.table(gzfile("/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-Hsa115.TBID.tab.gz", "r"), sep="\t", header=T, row.names=1, stringsAsFactors = F)
normal.rpkm <- read.table(gzfile("/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-Hsa34.tab.gz", "r"), sep="\t", header=T, row.names=1, stringsAsFactors = F)

impact.name <- data.frame(name=impact.rpkm$NAME)
row.names(impact.name) <- row.names(impact.rpkm)
impact.rpkm <- impact.rpkm[complete.cases(impact.rpkm),-1]

#impact.rpkm$TB32813 <- rowMeans(impact.rpkm[,c("TB32813.1", "TB32813")])
#impact.rpkm$TB32813.1 <- NULL

head(impact.rpkm[,1:5])
#                TB31413 TB35689 TB36090 TB32813 TB37987
#ENSG00000000003   21.94   19.55   44.30   26.54   17.63
#ENSG00000000005    0.00    0.02    0.07    0.00    0.00
#ENSG00000000419   19.49   38.30   32.85  100.17   45.64
#ENSG00000000457   11.17    5.35    8.30    6.43    4.07
#ENSG00000000460    3.05    7.30   14.86    6.79    6.51
#ENSG00000000938    5.34    2.93   10.17    4.37    1.26

normal.name <- normal.rpkm$NAME
normal.rpkm <- normal.rpkm[complete.cases(normal.rpkm),-1]


head(normal.rpkm[,1:2])
#                X0022d26a.de97.4b13.a040.97d66abf02ba X004abbb0.ed64.492f.9b8d.5a6aa8c95251
#ENSG00000000003                                 11.05                                  7.65
#...

valid.rows <- intersect(row.names(impact.rpkm), row.names(normal.rpkm))

impact.sizes <- estimateSizeFactorsForMatrix(impact.rpkm)
normal.sizes <- estimateSizeFactorsForMatrix(normal.rpkm)

impact.norm <- impact.rpkm / do.call(rbind, rep(list(impact.sizes), nrow(impact.rpkm)))
normal.norm <- normal.rpkm / do.call(rbind, rep(list(normal.sizes), nrow(normal.rpkm)))

#impact.cds <- newCountDataSet( trunc(impact.rpkm), conditions=as.factor(colnames(impact.rpkm)) )
#normal.cds <- newCountDataSet( trunc(impact.rpkm), conditions=as.factor(colnames(impact.rpkm)) )
#impact.sizes <- estimateSizeFactors(impact.cds)
#normal.sizes <- estimateSizeFactors(normal.cds)
#impact.adj <- counts(impact.cds, normalized=T)
#normal.adj <- counts(normal.cds, normalized=T)

normal.means <- rowMeans(normal.norm[valid.rows,]) + 0.5 #pseudocnt
impact.norm[valid.rows,] <- impact.norm[valid.rows,] + 0.5 # pseudocnt
log2fold <- log2(impact.norm[valid.rows,] / normal.means)

geneid <- impact.name[valid.rows,]

write.table(cbind(geneid, round(log2fold, digits=2)), "/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-log2fold-Impact-Hsa115_vs_mean34.tab", sep="\t", quote=F)
write.table(cbind(geneid, round(impact.norm[valid.rows,], digits=2)), "/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-norm-Impact-Hsa115.tab", sep="\t", quote=F)
write.table(cbind(geneid, round(normal.norm[valid.rows,], digits=2)), "/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-norm-TCGA-TN-Hsa34.tab", sep="\t", quote=F)
write.table(cbind(geneid, round(impact.rpkm[valid.rows,], digits=2)), "/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-raw-Impact-Hsa115.tab", sep="\t", quote=F)
write.table(cbind(geneid, round(normal.norm[valid.rows,], digits=2)), "/Users/timsw/Documents/Toronto/Impact_Project/cRPKM-raw-TCGA-TN-Hsa34.tab", sep="\t", quote=F)


