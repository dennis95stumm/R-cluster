#' This file is part of R-cluster.
#'
#' R-cluster is free software: you can redistribute it and/or modify
#' it under the terms of the GNU General Public License as published by
#' the Free Software Foundation, either version 3 of the License, or
#' (at your option) any later version.
#'
#' R-cluster is distributed in the hope that it will be useful,
#' but WITHOUT ANY WARRANTY; without even the implied warranty of
#' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#' GNU General Public License for more details.
#'
#' You should have received a copy of the GNU General Public License
#' along with R-cluster.  If not, see <http://www.gnu.org/licenses/>.
#'
#' This file contains functionality for starting new workers for a cluster.

source("./common.R")

# Parse the passed args to this script throught the command line.
options <- parseWorkerArgs()
redisOpts <- getRedisOptionsFromArgs(options)


#' Starts a new woker that checks in specific intervals the Redis database for new
#' queues and executes the jobs on the queue.
#'
#' @param num The number of the worker that was started.
runWorker <- function(num) {
  con <- hiredis(c(redisOpts))

  while (TRUE) {
    # Check if there is a queue in Redis database.
    queue <- unlist(con$SCAN(0)[2][1])[1]

    # Execute the job for the new found queue.
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
      
      # Start worker for executing the job for the found queue.
      do.call("redisWorker", params)
      
      # Cleanup and close log file for the worker.
      sink(type="message")
      sink()
      flush(params$log)
      close(params$log)
    }
    Sys.sleep(10)
  }
}

# Start workers on the cluster depending on the amount passed to the script.
mclapply(c(1:options$number), runWorker, mc.cores=options$number)
