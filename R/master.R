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
#' This file contains functionality for starting a new job on a cluster.

source("./common.R")

# Parse the passed args to this script throught the command line.
options <- parseMasterArgs()
redisOpts <- getRedisOptionsFromArgs(options)

# Check that there is a queue specified.
if (!isOptionSpecified("queue", options)) {
  stop("There must be at least a queue specified!")
}

# Ensure the specified queue is unique.
con <- hiredis(c(redisOpts))
queue <- unlist(con$SCAN(0, paste(options$queue, ".*", sep=""))[2][1])[1]

if (!is.null(queue) && !is.na(queue)) {
  stop(paste("There is already a queue with the name:", options$queue))
}

# Define the doRedis queue.
do.call("registerDoRedis", args=c(options$queue, redisOpts))

tryCatch({
  # Load and export the init script if specified.
  if (isOptionSpecified("init", options) && file.exists(options$init)) {
    source(options$init)

    if (!exists("worker.init")) {
      stop("In the specified init file is no function named worker.init!")
    }

    setExport("worker.init")
    worker.init()
  }

  filePassed <- isOptionSpecified("file", options)
  scriptPassed <- isOptionSpecified("script", options)

  # Check that the where passed existing file an script for the job.
  if (filePassed && file.exists(options$file) && scriptPassed && file.exists(options$script)) {
    source(options$script)

    if (!exists("run")) {
      stop("In the specified script is no function named run!")
    }

    # Set chunksize if specified.
    if (isOptionSpecified("chunksize", options)) {
      setChunkSize(options$chunksize)
    }

    # Enable progressbar.
    setProgress(TRUE)

    # Run the job.
    result <- run(options$file)

    # Write the output to the specified outfile or to the console.
    if (isOptionSpecified("outfile", options)) {
      write(result, options$outfile)
    } else {
      print(result)
    }
  } else {
    stop("There where no file or script specified or they didn't exist!")
  }
},
finally = {
  # Remove the doRedis queue, even if there was an error.
  removeQueue(options$queue)
})
