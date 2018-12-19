library("doRedis")
library("optparse")
library("data.table")

optionList = list(
  make_option(
    c("-q", "--queue"),
    type="character",
    help="The queue the workes should run on."
  ), make_option(
    c("-i", "--init"),
    type="character",
    help=paste(
      "Path to the init script (e.g. installation of libs) that should be",
      "executed on each worker. This file should contain a function named",
      "woker.init without any parameters.",
      sep="\n\t\t"
    )
  ), make_option(
    c("-s", "--script"),
    type="character",
    help=paste(
      "Path to the job script. This script should contain a run function",
      "taking only one argument, where the data for the job will be passed.",
      sep="\n\t\t"
    )
  ), make_option(
    c("-f", "--files"),
    type="character",
    help=paste(
      "Path to the file or files commaseparated, which contains the data for",
      "the job.",
      sep="\n\t\t"
    )
  ), make_option(
    c("-o", "--outfile"),
    type="character",
    help=paste(
      "Path to the file where the results of the job should be saved.",
      sep="\n\t\t"
    )
  )
)

optionParser = OptionParser(option_list=optionList)
options = parse_args(optionParser)

# TODO error if queue is not set

#registerDoRedis(options$queue)

if (any(names(options) == "init") && !is.na(options$init)) {
  source(options$init)
  setExport("worker.init")
}

# TODO check that the job script is specified
if (any(names(options) == "files") && !is.na(options$files)) {
  source(options$script)
  files <- unlist(strsplit(options$files, split=","))
  rawData <- myData<-fread(files[1], sep = , header = FALSE)
  run(rawData)

# TODO load files and call jobs in parallel
#  foreach (file:files) {
#    rawData <- myData<-fread(path, sep = , header = FALSE)
#  }
# TODO handle results and write them to specified outfile or to stdout
}
#removeQueue(options$queue)
