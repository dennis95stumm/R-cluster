library("doRedis")
library("optparse")
library("parallel")
library("redux")

optionList = list(
  make_option(
    c("-n", "--number"),
    type="integer",
    default=detectCores(),
    help="Number of workers to start. Defaults to number of computers cores."
  ), make_option(
    c("-m", "--master"),
    type="character",
    help="The hostname or ip address of the master node."
  ), make_option(
    c("-l", "--logpath"),
    type="character",
    default=".",
    help=paste(
      "The path to the workers log files. Defaults to the current path.",
      "Per each worker gets a custom file created.",
      sep="\n\t\t"
    )
  )
)

optionParser = OptionParser(option_list=optionList)
options = parse_args(optionParser)

# TODO: check for errors

runWorker <- function(num) {
  # TODO: Handle master not reachable
  con <- hiredis(host=options$master)
  queue <- unlist(con$SCAN(0)[2][1])[1]

  if (!is.null(queue) && !is.na(queue)) {
    queue <- sub("\\..*", "", queue)
    redisWorker(
      queue=queue,
      host=options$master,
      log=paste(
        options$logpath,
        paste("worker_", num, ".log", sep=""),
        sep=.Platform$file.sep
      ),
      linger=0
    )
  }

  Sys.sleep(10)

  runWorker(num)
}

mclapply(c(1:options$number), runWorker, mc.cores=options$number)
