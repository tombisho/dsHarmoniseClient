url <- "https://cran.r-project.org/src/contrib/Archive/JohnsonDistribution/JohnsonDistribution_0.24.tar.gz"
pkgFile <- "JohnsonDistribution_0.24.tar.gz"
download.file(url = url, destfile = pkgFile)

install.packages(pkgs=pkgFile, type="source", repos=NULL)

unlink(pkgFile)



library(devtools)
install_github("bonorico/gcipdr")

IPD <- airquality[, -6]
md <- Return.IPD.design.matrix(IPD, fill.missing = TRUE)
IPDsummary <- Return.key.IPD.summaries( md, "moment.corr" )


moms <- IPDsummary$first.four.moments   
corr <- IPDsummary$correlation.matrix
corr[lower.tri(corr)]  # inspect
n <- IPDsummary$sample.size
supp <- IPDsummary$is.binary.variable
names <- IPDsummary$variable.names


H <- 1  ## number of artificial IPD copies to be generated


set.seed(8736, "L'Ecuyer")

## Gaussian copula based IPD simulation


system.time(
  
  IPDstar <- DataRebuild( H, n, correlation.matrix = corr, moments = moms,
                          x.mode = supp, data.rearrange = "norta",
                          corrtype = "moment.corr", marg.model = "gamma",
                          variable.names = names, checkdata = TRUE, tabulate.similar.data = TRUE  )
)





