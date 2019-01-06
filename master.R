source("./common.R")

# TODO: Add doc

options <- parseMasterArgs()
redisOpts <- getRedisOptionsFromArgs(options)

if (!isOptionSpecified("queue", options)) {
  stop("There must be at least a queue specified!")
}

# TODO: Throw error if there is already a queue with that name

do.call("registerDoRedis", args=c(options$queue, redisOpts))

tryCatch({
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

  if (filePassed && file.exists(options$file) && scriptPassed && file.exists(options$script)) {
    source(options$script)

    if (!exists("run")) {
      stop("In the specified script is no function named run!")
    }

    setProgress(TRUE)
    result <- run(options$file)

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
  removeQueue(options$queue)
})
