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
  result <- foreach (i=lines, .combine="combineResults") %dopar% {
    partitialResult <- c()
    characters <- unlist(strsplit(i, ""))
    partitialResult["Gesamt"] <- length(characters)

    # Iterate over each single character and adjust the stats.
    foreach (character=characters) %do% {
      if (character == " ") {
        character = "Leerzeichen"
      }

      if (length(character) > 0) {
        if (is.na(partitialResult[character])) {
          partitialResult[character] <- 0
        }

        partitialResult[character] <- partitialResult[character] + 1
      }
    }

    partitialResult["Zeilen"] <- 1
    partitialResult
  }

  result <- cbind(result)
  colnames(result)[1] <- "Anzahl"
  return(capture.output(write.csv(result)))
}

#' Merges the stats of two subresults.
#'
#' @param map1 Vector with the first subresult.
#' @param map2 Vector with the second subresult.
#'
#' @return A vector containing the merged stats of the subresults.
combineResults <- function(map1, map2) {
  result <- map1

  foreach (stat=names(map2)) %do% {
    if (is.na(result[stat])) {
      result[stat] <- 0
    }

    result[stat] <- result[stat] + map2[stat]
  }

  return(result)
}
