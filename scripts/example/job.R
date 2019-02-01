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
#' This file contains a sample job which is used to analyze files.

#' Analyzes the file passed to this function.
#'
#' @param filePath The path to the file, that should be analyzed.
#'
#' @return A string containing csv formatted stats for the passed file.
#' @export
run <- function(filePath) {
  # Read all lines of the file. 
  lines <- readLines(filePath, warn=FALSE)

  # Iterate over the lines and anlyze them.
  result <- foreach (i=lines, .combine="combineResults", .multicombine=TRUE, .inorder=FALSE) %dopar% {
    #### Runs on the workers ####
    partitialResult <- c()
    characters <- unlist(strsplit(i, ""))
    partitialResult["Gesamt"] <- length(characters)

    # Iterate over each single character and adjust the stats.
    foreach (character=characters) %do% {
      if (character == " ") {
        character = "Leerzeichen"
      }

      if (length(character) > 0) {
        if (is.null(partitialResult[character]) || is.na(partitialResult[character])) {
          partitialResult[character] <- 0
        }

        partitialResult[character] <- partitialResult[character] + 1
      }
    }

    partitialResult["Zeilen"] <- 1
    partitialResult

    #### End workers job script ####
  }

  # Get the results in a csv format, so they can be saved to a csv file.
  result <- cbind(result)
  colnames(result)[1] <- "Anzahl"
  return(capture.output(write.csv(result)))
}

#' Merges the stats of two subresults.
#'
#' This combine function runs on the client where the master script was
#' executed. So it isn't parallized and if there are too many iterations or
#' chars it may be that the combine function would be run slow.
#'
#' @param map1 Vector with the first subresult.
#' @param map2 Vector with the second subresult.
#'
#' @return A vector containing the merged stats of the subresults.
combineResults <- function(...) {
  result <- c()

  foreach (part=list(...)) %do% {
    foreach (stat=names(part)) %do% {
      if (is.null(result[stat]) || is.na(result[stat])) {
        result[stat] <- 0
      }

      result[stat] <- result[stat] + part[stat]
    }
  }

  return(result)
}
