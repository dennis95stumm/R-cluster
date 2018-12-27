library("doRedis")
library("optparse")
library("data.table")

# TODO add doc

optionList = list(
  make_option(
    c("-f", "--file"),
    type="character",
    help=paste(
      "Path to the file which contains the data for the job.",
      sep="\n\t\t"
    )
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
    c("-m", "--master"),
    type="character",
    help="The hostname or ip address of the master where the redis process runs."
  ), make_option(
    c("-mp", "--master-port"),
    type="integer",
    help="The port of the redis process on the master."
  ), make_option(
    c("-mpwd", "--master-password"),
    type="character",
    help="The password of the redis process on the master."
  ), make_option(
    c("-mdb", "--master-database"),
    type="character",
    help="The name of the database in redis on the master."
  ), make_option(
    c("-o", "--outfile"),
    type="character",
    help=paste(
      "Path to the file where the results of the job should be saved.",
      sep="\n\t\t"
    )
  ), make_option(
    c("-q", "--queue"),
    type="character",
    help="The queue the workes should run on."
  ), make_option(
    c("-s", "--script"),
    type="character",
    help=paste(
      "Path to the job script. This script should contain a run function",
      "taking only one argument, where the data for the job will be passed.",
      sep="\n\t\t"
    )
  )
)

optionParser = OptionParser(option_list=optionList)
options = parse_args(optionParser)

if (!any(names(options) == "queue") || is.na(options$queue)) {
  stop("There must be at least a queue specified!")
}

on.exit(removeQueue(options$queue))

redisOpts <- list()

if (any(names(options) == "master") && !is.na(options$master)) {
  redisOpts$host <- options$master
}
if (any(names(options) == "master-port") && !is.na(options$"master-port")) {
  redisOpts$port <- options$"master-port"
}
if (any(names(options) == "master-password") && !is.na(options$"master-password")) {
  redisOpts$password <- options$"master-password"
}
if (any(names(options) == "master-database") && !is.na(options$"master-database")) {
  redisOpts$db <- options$"master-database"
}

do.call("registerDoRedis", args=c(options$queue, redisOpts))

if (any(names(options) == "init") && !is.na(options$init) && file.exists(options$init)) {
  source(options$init)
  if (!exists("worker.init")) {
    stop("In the specified init file is no function named worker.init!")
  }
  setExport("worker.init")
}

filePassed <- any(names(options) == "file") && !is.na(options$file)
passedFileExists <- file.exists(options$file)
scriptPassed <- any(names(options) == "script") && !is.na(options$script)
passedScriptExists <- file.exists(options$script)

if (filePassed && passedFileExists && scriptPassed && passedScriptExists) {
  source(options$script)
  rawData <- myData<-fread(options$file, sep = , header = FALSE)
  if (!exists("run")) {
    stop("In the specified script is no function named run!")
  }
  result <- run(rawData)

  if (any(names(options) == "outfile") && !is.na(options$outfile)) {
    write(result, options$outfile)
  } else {
    print(result)
  }
} else {
  stop("There where no file or script specified or they didn't exist!")
}
