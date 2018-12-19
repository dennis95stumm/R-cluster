library("doRedis")


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
  )
)

optionParser = OptionParser(option_list=optionList)
options = parse_args(optionParser)

registerDoRedis(options$queue)
# TODO load skript, files and the necessary libs
removeQueue(options$queue)
