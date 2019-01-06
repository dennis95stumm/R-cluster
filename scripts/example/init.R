# TODO: Add doc

worker.init <- function() {
  packages <- c(
    "foreach",
    "iterators"
  )

  newPackages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(newPackages)) install.packages(newPackages, repos='http://cran.us.r-project.org')

  library("foreach")
  library("iterators")
}
