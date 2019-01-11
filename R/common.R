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
#' This file contains functionality that is used in master and worker scripts.

library("doRedis")
library("optparse")
library("parallel")
library("redux")

#' Returns a list of common options that used in the master and worker scripts.
#'
#' @return List containing options for master and worker scripts.
getCommonOptionList <- function() {
  return(list(
    make_option(
      c("-m", "--master"),
      type="character",
      help="The hostname or ip address of the master where the redis process runs."
    ), make_option(
      c("-p", "--master-port"),
      type="integer",
      help="The port of the redis process on the master."
    ), make_option(
      c("-w", "--master-password"),
      type="character",
      help="The password of the redis process on the master."
    ), make_option(
      c("-d", "--master-database"),
      type="character",
      help="The name of the database in redis on the master."
    )
  ))
}

#' Returns a list of options that can be passed to the worker script.
#'
#' @return List containing options for worker script.
getWorkerOptionList <- function() {
  workerOptions <- list(
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
      c("-n", "--number"),
      type="integer",
      default=detectCores(),
      help="Number of workers to start. Defaults to number of computers cores."
    )
  )

  commonOptions <- getCommonOptionList()
  workerOptions <- append(workerOptions, commonOptions)
  
  return(workerOptions)
}

#' Returns a list of options that can be passed to the master script.
#'
#' @return List containing options for master script.
getMasterOptionList <- function() {
  masterOptions <- list(
    make_option(
      c("-c", "--chunksize"),
      type="integer",
      help=paste(
        "Size of the chunks for the jobs that gets submitted to the worker.",
        sep="\n\t\t"
      )
    ), 
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
    ),
    make_option(
      c("-t", "--time"),
      default=FALSE,
      type="logical",
      help=paste(
        "Indicates whether the run time of the script should be measured and",
        "printed to the console.",
        sep="\n\t\t"
      )
    )
  )

  commonOptions <- getCommonOptionList()
  masterOptions <- append(masterOptions, commonOptions)

  return(masterOptions)
}

#' Returns a list of options that were passed to the worker script.
#'
#' @return List of options that were passed to the worker script.
#' @export
parseWorkerArgs <- function() {
  optionParser = OptionParser(option_list=getWorkerOptionList())
  options = parse_args(optionParser)

  return(options)
}

#' Returns a list of options that were passed to the master script.
#'
#' @return List of options that were passed to the master script.
#' @export
parseMasterArgs <- function() {
  optionParser = OptionParser(option_list=getMasterOptionList())
  options = parse_args(optionParser)

  return(options)
}

#' Returns the redis options passed to the script as commandline params.
#'
#' @param options The options passed to the script as commandline params.
#'
#' @return The redis options passed to the script as commandline params.
#' @export
getRedisOptionsFromArgs <- function(options) {
  redisOpts <- list()

  if (isOptionSpecified("master", options)) {
    redisOpts$host <- options$master
  }
  if (isOptionSpecified("master-port", options)) {
    redisOpts$port <- options$"master-port"
  }
  if (isOptionSpecified("master-password", options)) {
    redisOpts$password <- options$"master-password"
  }
  if (isOptionSpecified("master-database", options)) {
    redisOpts$db <- options$"master-database"
  }

  return(redisOpts)
}

#' Returns a boolean that indicates whether the option was passed or not.
#'
#' @param option Option that should be checked.
#' @param options Options passed to the script as commandline params.
#'
#' @return Boolean that indicates whether the option was passed or not.
#' @export
isOptionSpecified <- function(option, options) {
  return(any(names(options) == option) && !is.na(options[option]))
}
