# This script is at the top level of the infrastructure - it needs to be sourced for other stuff to work
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
library(RColorBrewer)
library(sf)

source('Utilities/GeneralUtils.R')
source('Utilities/VectorUtils.R')
source('Backends/RequestChecks.R')
source('Backends/Backend_Utils.R')
source('Backends/Adcon_Backend.R')
source('Backends/Outpost_Backend.R')
source('Backends/SensorCloud_Backend.R')
source('Backends/Cosmoz_Backend.R')
source('Backends/DAFWA_Backend.R')
source('Backends/Mait_Backend.R')
source('Backends/DataFarmer_Backend.R')
source('Backends/SensFedStore_Backend.R')
source('Backends/Backends.R')
source('Backends/Authorisation.R')

debugMode <- F

timeAggMethods <- data.frame(mean = 'mean',
                             sum = 'sum',
                             min = 'min',
                             max = 'max',
                             none = 'none',
                             stringsAsFactors = F)

# List of known data sources
knownBackends <- c('SensorCloud',
                   'Adcon',
                   'OutPost',
                   'Cosmoz',
                   'DAFWA',
                   'Mait',
                   'DataFarmer',
                   'SenFedStore')

# List of possible data that can be accessed
knownFeatures <- c('Soil-Moisture',
                   'Soil-Temperature',
                   'Rainfall',
                   'Humidity',
                   'Temperature',
                   'Wind-Direction',
                   'Wind-Speed',
                   'Atmospheric Pressure',
                   'Vapour-Pressure',
                   'Dew-Point',
                   'Delta T',
                   'Suction')

FeatureAggTypes <-c(timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$sum,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean,
                    timeAggMethods$mean)

names(FeatureAggTypes) <- knownFeatures

# Time scales
timeSteps <- data.frame(none = 'none',
                        minutes ='minutes',
                        hours = 'hours',
                        days = 'days',
                        weeks = 'weeks',
                        months ='months',
                        quarters ='quarters',
                        years = 'years',
                        stringsAsFactors = F)

# Length of time steps in seconds
timeStepDurations <- data.frame(none = 0,
                                minutes = 60,
                                hours = 3600,
                                days = 86400,
                                weeks = 604800,
                                months = 2592000,
                                quarters = 7948800,
                                years = 31536000,
                                stringsAsFactors = F)

apiFormats <- data.frame(simpleTS = 'simpleTS',
                         nestedTS = 'nestedTS',
                         stringsAsFactors = F)

defaultStartTime <- '09:00:00'
asyncThreadNum = 10
maxRecs = '1000000'
globalTimeOut = 200

dbPath <- 'DB/SensorFederator.sqlite'
senFedDbPath <- 'BackebdAdmin/OzNet/ozNetDB.db'













