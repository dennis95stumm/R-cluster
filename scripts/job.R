path <- dirname(parent.frame(2)$ofile)

source(paste(path, "getDataSize.R", sep="/"))
source(paste(path, "getFeatureData.R", sep="/"))

run <- function(x) {
  getFeatureData(x, getDataSize(x))
}
