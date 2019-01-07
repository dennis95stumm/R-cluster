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
#' This file contains the worker init script for the sample job.

#' Worker initialization script that installs the necessary libs for the sample job.
#'
#' @export
worker.init <- function() {
  packages <- c(
    "foreach",
    "iterators"
  )

  # Install libs if necessary.
  newPackages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(newPackages)) install.packages(newPackages, repos='http://cran.us.r-project.org')

  library("foreach")
  library("iterators")
}
