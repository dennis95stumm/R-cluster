source("./common.R")

# TODO: Add doc

options <- parseWorkerArgs()
redisOpts <- getRedisOptionsFromArgs(options)

runWorker <- function(num) {
  con <- hiredis(c(redisOpts))

  while (TRUE) {
    queue <- unlist(con$SCAN(0)[2][1])[1]

    if (!is.null(queue) && !is.na(queue)) {
      queue <- sub("\\..*", "", queue)
      params <- c(
        queue=queue,
        linger=1,
        redisOpts
      )
      params$log <- file(paste(
        options$logpath,
        paste("worker_", num, ".log", sep=""),
        sep=.Platform$file.sep
      ), open="a+")
      do.call("redisWorker", params)
      sink(type="message")
      sink()
      flush(params$log)
      close(params$log)
    }
    Sys.sleep(10)
  }
}

mclapply(c(1:options$number), runWorker, mc.cores=options$number)
