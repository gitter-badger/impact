#setwd("/Users/timsw/Documents/Toronto/Impact_Project/impact")

source("R/initialize.R") # creates loadPackages function

defpackages()
defmetadata() # loads to meta.data variable

# loadRPKMFile currently returns a data.frame
lung.expr <- loadRPKMFile("VAST_cRPKM-norm-Impact-Hsa115.tab.gz")

head(lung.expr[,1:5])
#                  geneid TB31413 TB35689 TB36090 TB32813
#ENSG00000000003   TSPAN6   23.20   20.71   43.46   26.60
#ENSG00000000005     TNMD    0.50    0.52    0.57    0.50
#ENSG00000000419     DPM1   20.67   40.09   32.36  101.06
#ENSG00000000457    SCYL3   12.06    6.03    8.55    7.04
#ENSG00000000460 C1orf112    3.66    8.05   14.91    6.96
#ENSG00000000938      FGR    6.02    3.53   10.36    4.67

# loadPSIFile returns an S4 object with 3 data.frame slots: def, psi, qual
# def is the raw data table from file, psi contains just the PSI values in data.frame
# qual contains just the QUAL columns in data.frame format
lung.splicing <- loadPSIFile("VAST_PSIVAL-Hsa115.TBID.tab.gz")
slotNames(lung.splicing)
head(lung.splicing@psi[,1:5])
#             TB31413 TB35689 TB36090 TB32813 TB37987
#HsaEX0067680   93.57   98.24   96.27   97.54   98.09
#HsaEX0067681    1.31    3.63    2.19    0.00    0.00
#HsaEX0056690   96.69   86.67   90.74   93.22   96.00
#HsaEX0056691  100.00  100.00   96.64  100.00  100.00
#HsaEX0010105  100.00  100.00   95.32   94.87   96.72
#HsaEX0010106  100.00  100.00  100.00   97.53  100.00
