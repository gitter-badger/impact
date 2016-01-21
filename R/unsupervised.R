# This should contain multiple approaches towards unsupervised learning.
#

req.set <- c("cluster","pamr","apcluster","gplots")
loadPackages(req.set)


euc.dist <- dist(log2fold, method = "euclidean")
apres <- apcluster(euc.dist)
