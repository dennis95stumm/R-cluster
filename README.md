# R-cluster

A cluster-computing platform for R scripts!

## Requirements

* Redis: 5.0.3
* R: 3.5.2
* R-Libraries:
  * doRedis: 1.2.2
  * parallel: 3.5.1
  * optparse: 1.6.0
  * redux: 1.1.0

## Setup

The installation of the requirements depends on the underlying operation system.
Its recommended that you have at least two machines, one for the worker and one
for the master.

Redis is used to share the data with master and workers and for the job
management for the workers. For more details see at the documentation of
[doRedis](https://github.com/bwlewis/doRedis/blob/master/vignettes/doRedis.pdf).

### Redis

Download and install Redis on the master machine. For more details see on the
official [website](https://redis.io/download).

### R

Download and install R on the master and worker machines. For more details see
on the official [website](https://www.r-project.org/).

### R libraries

The required libraries must be installed on the master machine as well as on the
worker machines. It might be necessary to specify the
[library path](https://www.r-bloggers.com/package-paths-in-r/) if the default
library path is not writeable for the current user. To run the platform the
libraries can be installed with the following instructions in the interactive R
shell:

```R
install.packages("parallel")
install.packages("optparse")
install.packages("redux")
```

The latest version of the `doRedis` package is only available on github, it is
necessary to install it with the following commands:

```R
install.packages("devtools")
library(devtools)
install_github("bwlewis/doRedis")
```

The installation of the reqired libraries for the specific job should be
implemented in the [initialization script](#Initialization-script).

## Getting Started

After installing and configuring all the requirements the platform can be used.
Either download the source code or the
[latest release](https://github.com/dennis95stumm/R-cluster/releases) and place
it to the folder of your desire.

To get a job done at least a worker must run on the cluster. This can be done by
executing the following command:

```cmd
Rscript worker.R [options]
```

The following options can be passed to the worker script:

| Short | Long              | Default         | Description |
| ----- | ----------------- | --------------- | ----------- |
| -m    | --master          |                 | The hostname or ip address of the master where the redis process runs. |
| -p    | --master-port     |                 | The port of the redis process on the master. |
| -w    | --master-password |                 | The password of the redis process on the master. |
| -d    | --master-database |                 | The name of the database in redis on the master. |
| -l    | --logpath         | "."             | The path to the workers log files. Defaults to the current path. Per each worker gets a custom file created. |
| -n    | --number          | number of cores | Number of workers to start. Defaults to number of computers cores. |


### Run a job

To run a new job on the cluster you must execute the following line:

```cmd
Rscript master.R [options]
```

The following options can be passed to the master script:

| Short | Long              | Description |
| ----- | ----------------- | ----------- |
| -m    | --master          | The hostname or ip address of the master where the redis process runs. |
| -p    | --master-port     | The port of the redis process on the master. |
| -w    | --master-password | The password of the redis process on the master. |
| -d    | --master-database | The name of the database in redis on the master. |
| -c    | --chunksize       | Size of the chunks for the jobs that gets submitted to the worker. |
| -f    | --file            | Path to the file which contains the data for the job. |
| -i    | --init            | Path to the init script (e.g. installation of libs) that should be executed on each worker. This file should contain a function named woker.init without any parameters. |
| -o    | --outfile         | Path to the file where the results of the job should be saved. |
| -q    | --queue           | The queue the workes should run on. |
| -s    | --script          | Path to the job script. This script should contain a run function taking only one argument, where the data for the job will be passed. |


### Writing new jobs

A job consists of job script and if necessary a initialization script for the
workers. The job script gets executed on the master and the initialization
script gets executed once at the begin of a job on each worker node.

#### Job script

The job script must contain a `run` function, that gets called when starting the
job. It takes one parameter, which contains the path to the input file that
should be processed in the job. The processing algorithm can be written in this
function or be splitted up to other functions or scripts. To load necessary
scripts relative to the script path following construction can be used:

```R
path <- dirname(parent.frame(2)$ofile)
source(paste(path, FILENAME, sep="/"))
```

#### Initialization script

The optionally initialization script must contain a `worker.init` function,
where the initilization of each worker node can be done. Be sure that the user
starting the worker nodes and the master have write access to the lib path of R.
If necessary adjust this path by chainging the appropriate environment
variables.

#### Notes

* Depending on the implementation of the job script it may be that the workers
  wouldn't free up the memory after executing a job. Be careful by using
  variables throught multiple workers!
* The job could run slow if there are a lot of iterations, it might be useful to
  adjust the `chunksize` to get a faster job execution. Also depending on the
  `combine` function for the results can lead to high cpu consumption on the
  machine, where was the master script started and this can lead to slowing up
  the whole job.
* Running jobs with iterators doesn't support the progressbar yet. So it is
  necessary to deactivate the progressbar by calling `setProgress(FALSE)` in
  the specific job.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details
