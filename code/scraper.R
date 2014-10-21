## Script to download and prepare the Colombia popultation data from DANE

# Dependencies
library(xlsx)
library(reshape2)

downloadAndProcess <- function() {
  # Downloading file
  url = 'https://www.dane.gov.co/files/investigaciones/poblacion/proyepobla06_20/Municipal_area_1985-2020.xls'
  download.file(url, 'data/Municipal_area_1985-2020.xlsx', method = 'curl')
  
  # Loading file.
  # has to use read.xlsx2 for some reason.
  message('Loading file ...')
  Sys.sleep(5)  # let it sleep for 5 seconds.
  population <- read.xlsx2('data/Municipal_area_1985-2020.xlsx', sheetIndex = 1, startRow = 10)
  
  ## Cleaning
  # Adding category data.
  names(population)[5:40] <- paste0("Total-", gsub("X", "", names(population)[5:40]))
  names(population)[41:76] <- paste0("Cabecera-", gsub("X", "", names(population)[41:76]))
  names(population)[77:length(names(population))] <- paste0("Resto-", gsub("X", "", names(population)[77:length(names(population))]))
  
  # Melting
  meltPop <- melt(data = population, id = c("DP", "DPNOM", "DPMP", "MPIO"))
  meltPop$variable <- gsub("\\.1", "", meltPop$variable)
  meltPop$variable <- gsub("\\.2", "", meltPop$variable)
  colnames(meltPop)[5] <- 'year'
  
  # Creating category labels
  meltPop$category <- NA
  meltPop$category <- ifelse(grepl("Total", meltPop$year), "Total", meltPop$category)
  meltPop$category <- ifelse(grepl("Cabecera", meltPop$year), "Cabecera", meltPop$category)
  meltPop$category <- ifelse(grepl("Resto", meltPop$year), "Resto", meltPop$category)
  
  # Cleaning-up
  meltPop$year <- gsub("Total-", "", meltPop$year)
  meltPop$year <- gsub("Cabecera-", "", meltPop$year)
  meltPop$year <- gsub("Resto-", "", meltPop$year)
  
  # Finish
  return(meltPop)
  
}

# Storing output
data <- downloadAndProcess()
write.csv(data, 'data/municipal_population_data.csv', row.names = F)


