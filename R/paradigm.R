#PRE
grep no_engraft ming_engraft_v2.txt | cut -f 2 | sed 's/^/PHL/g' > nonengraft_v2.phl
grep Lymphoma ming_engraft_v2.txt | cut -f 2 | sed 's/^/PHL/g' > lymphoma_v2.phl
grep -f <( sed 's/PHL//g' lymphoma_v2.phl ) -v ming_engraft_v2.txt | grep -v no_engraft | grep -v omit_no | cut -f 2 | sed 's/^/PHL/g' > engraft_v2.phl
grep omit_no ming_engraft_v2.txt | cut -f 2 | sed 's/^/PHL/g' > omit_v2.phl

### BEGIN R CODE ###
para <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/Paradigm_Raw.txt", sep="\t", header=T, row.names=1)

engraft <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/engraft_v2.phl", stringsAsFactors=F)$V1
nonengraft <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/nonengraft_v2.phl", stringsAsFactors=F)$V1
lymphoma <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/lymphoma_v2.phl", stringsAsFactors=F)$V1
omit <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/omit_v2.phl", stringsAsFactors=F)$V1

adeno <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/adenocarcinoma.phl", stringsAsFactors=F)$V1
squamous <- read.table("/Users/timsw/Documents/Toronto/Impact_Project/squamous.phl", stringsAsFactors=F)$V1

plabels <- colnames(para)

omit <- union(omit, lymphoma)

toOmit <- which(plabels %in% omit)

#para <- para[,-toOmit]
#plabels <- plabels[-toOmit]

plabels[which(plabels %in% engraft)] <- "YES"
plabels[which(plabels %in% lymphoma)] <- "P1"
plabels[!grepl("YES|P1", plabels)] <- "NO"

dlabels <- colnames(para)
dlabels[which(dlabels %in% engraft & dlabels %in% squamous)] <- "YES.SQ"
dlabels[which(dlabels %in% engraft & dlabels %in% adeno)] <- "YES.AD"
dlabels[which(dlabels %in% union(nonengraft.og,lymphoma) & dlabels %in% squamous)] <- "NO.SQ"
dlabels[which(dlabels %in% union(nonengraft.og,lymphoma) & dlabels %in% adeno)] <- "NO.AD"

rowRanges <- function(x) {
   unlist(lapply(1:nrow(x), function(y) { 
   	 r <- as.numeric(x[y,])
     max(r)-min(r)
   }))
}

rowAbsSums <- function(x) {
   unlist(lapply(1:nrow(x), function(y) { 
   	 r <- abs(as.numeric(x[y,]))
     sum(r)
   }))
}

imp <- rowRanges(para)
sm <- rowAbsSums(para)
thresh <- quantile(imp, 0.75)
smThresh <- quantile(sm, 0.75)
varData <- para[which(imp > thresh & sm > smThresh),]
varLabels <- rownames(para)[which(imp > thresh & sm > smThresh)]

require(pamr)
require(gplots)
require(RColorBrewer)

mycol <- colorRampPalette(rev(brewer.pal(11,"RdBu")))

data <- list(x=as.matrix(varData),y=plabels) 
res <- pamr.train( data )
rescv <- pamr.cv(res, data)
resfdr <- pamr.fdr( res, data)
pamr.plotcen(res, data, threshold=2.13)
pamr.geneplot( res, data, threshold=2.13)

good <- c(1481,72,2076,432,558,1785,75,428,1100)
goodLab <- varLabels[good]
hclust.med <- function(x) hclust(x, method="median")
dist.man <- function(x) dist(x, method="euclidean")
labelcol <- brewer.pal(11,"YlGn")
heatmap.2( as.matrix(para[goodLab,]), trace="none", ColSideColors=c("white",labelcol[c(3,7)])[as.integer(factor(dlabels))], scale="row", col=mycol(100), hclustfun=hclust.med, distfun=dist.man)

adenocols <- which(colnames(para) %in% adeno)
squamouscols <- which(colnames(para) %in% squamous)
toplot <- para
bound = 3
for(i in 1:nrow(toplot)) {
	for(j in 1:ncol(toplot)) {
		if(toplot[i,j] > bound) {
			toplot[i,j] <- bound
		}
		if(toplot[i,j] < -1*bound) {
			toplot[i,j] <- -1*bound
		}
	}
}
heatmap.2( as.matrix(toplot[goodLab, squamouscols]), trace="none", ColSideColors=c("white","lightgrey","black")[as.integer(factor(plabels[squamouscols]))], scale="row", col=mycol(100), hclustfun=hclust.med, distfun=dist.man)
heatmap.2( as.matrix(toplot[goodLab, adenocols]), trace="none", ColSideColors=c("white","lightgrey","black")[as.integer(factor(plabels[adenocols]))], scale="row", col=mycol(100), hclustfun=hclust.med, distfun=dist.man)

heatmap.2( as.matrix(para[goodLab,which(plabels == "NO")]), trace="none", Rowv=FALSE)
heatmap.2( as.matrix(para[goodLab,which(plabels == "YES")]), trace="none", Rowv=FALSE)