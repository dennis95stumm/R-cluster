getDataSize <- function (path, size) {
  NrRecoreds <- dim(rawData)[1]
  NrMeasurements <- NrRecoreds/4
  return(NrMeasurements)
}
