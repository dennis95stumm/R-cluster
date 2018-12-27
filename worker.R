library("doRedis")
library("optparse")
library("parallel")
library("redux")

# TODO: Add doc

optionList = list(
  make_option(
    c("-l", "--logpath"),
    type="character",
    default=".",
    help=paste(
      "The path to the workers log files. Defaults to the current path.",
      "Per each worker gets a custom file created.",
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
  ),
  make_option(
    c("-n", "--number"),
    type="integer",
    default=detectCores(),
    help="Number of workers to start. Defaults to number of computers cores."
  )
)

optionParser = OptionParser(option_list=optionList)
options = parse_args(optionParser)

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

runWorker <- function(num) {
  con <- hiredis(c(redisOpts))
  queue <- unlist(con$SCAN(0)[2][1])[1]

  if (!is.null(queue) && !is.na(queue)) {
    queue <- sub("\\..*", "", queue)
    do.call("redisWorker", c(
      queue=queue,
      log=paste(
        options$logpath,
        paste("worker_", num, ".log", sep=""),
        sep=.Platform$file.sep
      ),
      linger=0,
      redisOpts
    ))
  }

  Sys.sleep(10)

  runWorker(num)
}

mclapply(c(1:options$number), runWorker, mc.cores=options$number)
