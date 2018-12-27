worker.init <- function() {
  packages <- c(
    "caret",
    "ggplot2",
    "dummies",
    "e1071",
    "data.table",
    "audio",
    "seewave",
    "tuneR",
    "entropy",
    "parallel",
    "MASS",
    "lme4",
    "caTools",
    "randomForest",
    "factoextra",
    "ggfortify",
    "pROC",
    "PRROC",
    "precrec",
    "doParallel"
  )

  newPackages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(newPackages)) install.packages(newPackages, repos='http://cran.us.r-project.org', lib="<PATH>/Rlib")

  library(caret)
  library(ggplot2)
  library(dummies)
  library(e1071)
  library(data.table)
  library(audio)
  library(seewave)
  library(tuneR)
  library(entropy)
  library(parallel)
  library(MASS)
  library(lme4)
  library(caTools)
  library(randomForest)
  library(factoextra)
  library(ggfortify)
  library(pROC)
  library(PRROC) 
  library(factoextra)
  library(precrec)  
  library(doParallel)

  setPackages(packages)
}
