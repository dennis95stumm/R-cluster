# TODO: Add doc

run <- function(filePath) {
  setProgress(FALSE)

  iterator <- ireadLines(filePath, warn=FALSE)

  result <- foreach (i=iterator, .combine="combineResults") %do% {
    items <- unlist(strsplit(i, " "))
    
    partitialResult <- foreach (item=items, .combine="combineResults") %dopar% {
      characterStats <- c()
      characters <- unlist(strsplit(item, ""))
      characterStats["Gesamt"] <- length(characters)

      foreach (character=characters) %do% {
        if (length(character) > 0) {
          if (is.na(characterStats[character])) {
            characterStats[character] <- 0
          }

          characterStats[character] <- characterStats[character] + 1
        }
      }

      characterStats
    }

    partitialResult["Zeilen"] <- 1

    if (length(items) == 0) {
      partitialResult["Leerzeichen"] <- 0
      partitialResult["Gesamt"] <- 0
    } else {
      partitialResult["Leerzeichen"] <- length(items) - 1
      partitialResult["Gesamt"] <- partitialResult["Gesamt"] + partitialResult["Leerzeichen"]
    }

    partitialResult
  }

  result <- cbind(result)
  colnames(result)[1] <- "Anzahl"
  return(capture.output(write.csv(result)))
}

combineResults <- function(map1, map2) {
  result <- c(map1)

  foreach (stat=names(map2)) %do% {
    if (is.na(result[stat])) {
      result[stat] <- 0
    }

    result[stat] <- result[stat] + map2[stat]
  }

  return(result)
}
