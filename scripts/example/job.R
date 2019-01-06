# TODO: Add doc

run <- function(filePath) {
  lines <- readLines(filePath, warn=FALSE)

  result <- foreach (i=lines, .combine="combineResults") %dopar% {
    partitialResult <- c()
    characters <- unlist(strsplit(i, ""))
    partitialResult["Gesamt"] <- length(characters)

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
  return(capture.output(write.csv(c())))
}

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
