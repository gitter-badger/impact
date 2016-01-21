#!/usr/bin/env Rscript
#
#  Install/loading of required Packages.

####### Variables

full.pkg.set <- c("xlsx",
	"cluster",
        "apcluster",
        "pamr",
        "ggplot2",
        "reshape2",
        "gplots",
        "RColorBrewer")

path.to.git <- "" # overwrite this variable if you are copy/pasting code into R studio or visual R console
path.to.data <- "" # by default it is path.to.git/IMPACT_data

# Colorblind Palette!
cbb <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

####### Initialize

if(path.to.git == "") {
   path.to.git <- getwd()
}
writeLines(sprintf("Path to git repo (path.to.git) is: %s", path.to.git), stderr())

if(path.to.data == "") {
   path.to.data <- paste(c(path.to.git,"/IMPACT_data"), collapse="")
}
writeLines(sprintf("Path to data (path.to.data) is: %s", path.to.data), stderr())

####### Functions

loadPackages <- function(toLoad, local.lib="Rlib/") {
  for(i in toLoad) {
    writeLines(sprintf("Trying to load required package: %s", toString(i)), stderr())
    if(!suppressWarnings(require(toString(i), character.only=T, quietly=T)) &&
                 !suppressWarnings(require(toString(i), character.only=T, lib.loc=local.lib, quietly=T))){
        writeLines(sprintf("%s did not load correctly! Now trying to install..", i), stderr())
        install.packages(i, dependencies=TRUE, repos='http://cran.us.r-project.org', lib=local.lib)
        if(require(toString(i), character.only=T, lib.loc=local.lib)) {
          writeLines(sprintf("%s has been installed locally in R/Rlib!", i), stderr())
        } else {
          stop(sprintf("quitting!!! I could not install %s for you!", i))
                  }

    }
  }
}

loadMetaData <- function(filename, sheetname) {
   require(xslx)
   meta.result <- read.xlsx(filename, sheetName=sheetname)
}

loadGeneralData <- function(filename, path=path.to.data, namecol=1, isheader=T) {
  fullpath <- paste(c(path, filename), collapse="/")
  if(grepl(filename, ".gz$")) {
     data.result <- read.table(gzfile(fullpath, "r"), sep="\t", header=isheader, row.names=namecol, stringsAsFactors = F, quote="")
  } else {
     data.result <- read.table(fullpath, sep="\t", header=isheader, row.names=namecol, stringsAsFactors = F, quote="")
  }
  data.result
}

loadRPKMFile <- function(filename, path=path.to.data) {
   loadGeneralData( filename, path=path ) # default settings are already for cRPKM files  
}

loadPSIFile <- function(filename, path=path.to.data) {
   loadGeneralData( filename, path=path )
}

###### Exported Functions Using Defaults

# This function loads/installs the full package set.
defpackages <- function() {
   writeLines("Loading packages with 'loadPackages'.", stderr())
   loadPackages(full.pkg.set, local.lib=paste(c(path.to.git,"/Rlib"), collapse=""))
}

# This function loads the default meta data file
defmetadata <- function(filename="IMPACT_Summary_15Aug2014.xlsx", sheetname="15Aug2014") {
   writeLines("Loading meta data with 'loadMetaData'.", stderr())
   loadMetaData(paste(c(path.to.data,filename), collapse="/"), sheetname)
}

