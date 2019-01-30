
# This script is at the top level of the infrsstructure - it needs to be sourced for other stuff to work


library(RCurl)
library(jsonlite)
library(stringr)
library(zoo)
library(xts)
library(rgdal)
library(raster)
library(reshape)
library(urltools)
library(lubridate)
library(async)
library(xml2)
library(htmlTable)
library(DBI)
library(RSQLite)

debugMode <- F

machineName <- as.character(Sys.info()['nodename'])
print(machineName)
if(machineName == 'FANCY-DP'){
  rootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/Shiny/SMIPS'
  sensorRootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'
  functionsRootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/myFunctions'
}else if (machineName == 'soils-discovery' & debugMode == T) {
  rootDir <<- '/home/sea084/R/SMIPS'
  sensorRootDir <<- '/home/sea084/R/SensorBackends'
  functionsRootDir <<- '/home/sea084/R/myFunctions'
}else if (machineName == 'soils-discovery' & debugMode == F) {
  rootDir <<- '/srv/shiny-server/SMIPS'
  sensorRootDir <<- '/srv/plumber/SensorFederator'
  functionsRootDir <<- '/srv/plumber/Functions'
}else if (machineName == 'TERNSOILS') {
  rootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/Shiny/SMIPS'
  sensorRootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'
  functionsRootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/myFunctions'
}else{
  rootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/Shiny/SMIPS'
  sensorRootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'
  functionsRootDir <<- 'C:/Users/sea084/Dropbox/RossRCode/myFunctions'
}


dbPath <- paste0(sensorRootDir, "/DB/SensorFederator.sqlite")

knownBackends <- c('SensorCloud', 'Adcon', 'OutPost', 'Cosmoz', 'DAFWA', 'Mait', 'DataFarmer')
knownFeatures <- c('Soil-Moisture', 'Rainfall', 'Humidity', 'Temperature', 'Wind-Direction', 'Wind-Speed')
timeAggMethods <- data.frame(mean='mean', sum='sum', min='min', max='max', none='none', stringsAsFactors = F)
FeatureAggTypes <-c(timeAggMethods$mean, timeAggMethods$sum, timeAggMethods$mean, timeAggMethods$mean, timeAggMethods$mean, timeAggMethods$mean)
names(FeatureAggTypes) <- knownFeatures

timeSteps <- data.frame(none='none', minutes='minutes', hours='hours', days='days', weeks='weeks', months='months', quarters='quarters', years='years', stringsAsFactors = F)
timeStepDurations <- data.frame(none=0, minutes=60, hours=3600, days=86400, weeks=604800, months=2592000, quarters=7948800, years=31536000, stringsAsFactors = F)


apiFormats <- data.frame(simpleTS='simpleTS', nestedTS='nestedTS', stringsAsFactors = F)





asyncThreadNum = 10
maxRecs = '1000000'
globalTimeOut = 200


source(paste0(functionsRootDir,'/GeneralUtils.R'))
source(paste0(functionsRootDir,'/VectorUtils.R'))
source(paste0(sensorRootDir, '/Backends/RequestChecks.R'))
source(paste0(sensorRootDir, '/Backends/Backend_Utils.R'))
source(paste0(sensorRootDir, '/Backends/Adcon_Backend.R'))
source(paste0(sensorRootDir, '/Backends/Outpost_Backend.R'))
source(paste0(sensorRootDir, '/Backends/SensorCloud_Backend.R'))
source(paste0(sensorRootDir, '/Backends/Cosmoz_Backend.R'))
source(paste0(sensorRootDir, '/Backends/DAFWA_Backend.R'))
source(paste0(sensorRootDir, '/Backends/Mait_Backend.R'))
source(paste0(sensorRootDir, '/Backends/DataFarmer_Backend.R'))
source(paste0(sensorRootDir, '/Backends/Backends.R'))
source(paste0(sensorRootDir, '/Backends/Authorisation.R'))






DBCon <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RO)
fk_On <- 'PRAGMA foreign_keys = ON;'
dbExecute(DBCon, fk_On)

#sitesInfo <- read.csv(paste0(sensorRootDir, '/SensorInfo/AllSites.csv'), stringsAsFactors = F)
#allSensorInfo <- read.csv(paste0(sensorRootDir, '/SensorInfo/AllSensors.csv'), stringsAsFactors = F)
#sensorInfo <- allSensorInfo[allSensorInfo$Active,]


defaultStartTime <- '09:00:00'




