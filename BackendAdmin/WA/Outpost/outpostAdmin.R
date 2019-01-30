library(RCurl)
library(jsonlite)
library(stringr)
library(httr)
library(XML)
library(xml2)
library(htmltidy)
library(zoo)
library(xts)
library(RCurl)
library(stringr)
library(raster)

source('C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/Backends/Backends.R')

myOpts <- curlOptions(connecttimeout = 2000, ssl.verifypeer = FALSE)



######### use  a short time period as default request to get info returns everything - this data is huge  ##########


# Manually curate the data to be displayed in the App from CSIRO GRDC Sites for RCSN - These are yvettes probes

# This login gets 2 projects RCSN and EConnect (DAFWA) - run this then manually split the projects into 2 seperate files

providerInfo = list( provider= c('RCSN'), backEnd=c('OutPost'), server=c('https://www.outpostcentral.com'), org=c('CSIRO'),
                     usr=c('yoliver'), pwd=c('export'),
                     access = c('Public'),
                     contact=c('Frank Demden PAA'), orgURL=c('http://outpostcentral.com/'))



generateSiteInfo_OutPost(providerInfo, rootDir)
generateSensorInfo_OutPost(providerInfo, rootDir)

vc(paste0(rootDir, '/SensorInfo/', providerInfo$provider, '_SensorsAll.csv'))


#####  USQ - Dave Freebairn

rootDir = 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'

providerInfo = list( provider= c('USQ-Outpost'), backEnd=c('OutPost'), server=c('https://www.outpostcentral.com'), org=c('USQ'),
                     usr=c('David+Freebairn'), pwd=c('USQ'),
                     access = c('Public'),
                     contact=c('David Freebairn'), orgURL=c('http://outpostcentral.com/'))

generateSiteInfo_OutPost(providerInfo, rootDir)
generateSensorInfo_OutPost(providerInfo, rootDir)

vc(paste0(rootDir, '/SensorInfo/', providerInfo$provider, '_SensorsAll.csv'))










