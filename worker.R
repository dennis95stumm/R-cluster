library("doRedis")
library("optparse")
library("parallel")

optionList = list(
  make_option(
    c("-n", "--number"),
    type="integer",
    default=detectCores(),
    help="Number of workers to start. Defaults to number of computers cores."
  ), make_option(
    c("-q", "--queue"),
    type="character",
    help="The queue the workes should run on."
  ), make_option(
    c("-m", "--master"),
    type="character",
    help="The hostname or ip address of the master node."
  )
)

optionParser = OptionParser(option_list=optionList)
options = parse_args(optionParser)

# todo allow multiple queues
startLocalWorkers(n=options$number, queue=options$queue, host=options$master)
