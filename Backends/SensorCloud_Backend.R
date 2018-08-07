
# some terminology mappings
#platforms = sites
#streams = sensors


# service <- 'https://sensor-cloud.io/api/sensor/v2/'
# usr <- 'ross.searle@csiro.au'
# pwd <- 'rossiscool'


#maxRecords <- "1000000"



generateSiteInfo_SC <- function(providerInfo, rootDir){

    usrpwd <- paste0(providerInfo$usr, ':', providerInfo$pwd)
    platforms <- getURL(paste0(providerInfo$server, "/platforms?expand=true"), userpwd=usrpwd, httpauth = 1L)
    platformsJ <- fromJSON(platforms)
    Pids <- str_replace(platformsJ$`_embedded`$platforms$id, '.plat', '')
    Pnames <- platformsJ$`_embedded`$platforms$name
    Plinks <- platformsJ$`_embedded`$platforms$`_links`
    plats <- data.frame(Pids, Pnames, Plinks)
    
    Plocs <- getURL(paste0(providerInfo$server, "/locations?expand=true"), userpwd=usrpwd, httpauth = 1L)
    PlocsJ <- fromJSON(Plocs)
    locsDesc <- str_replace_all(PlocsJ$`_embedded`$locations$description, ',', ' ')
    locsDesc <- str_replace_all(locsDesc, '\r\n', ' ')
    
    locsGeo <- PlocsJ$`_embedded`$locations$geojson
    lngs<- as.numeric(rapply(locsGeo$coordinates, function(x) x[[1]]))
    lats<- as.numeric(rapply(locsGeo$coordinates, function(x) x[[2]]))
    SiteID <- Plinks$self$href
    
    SIDurls <- url_parse(SiteID)
    SID <- str_split(SIDurls$path, '/')
    SIDs <- sapply(SID, function (x) x[length(x)])
    
    locs <- data.frame(SIDs, Pnames,providerInfo$provider, providerInfo$backEnd, providerInfo$access, providerInfo$usr, providerInfo$pwd, lats,   lngs,T, providerInfo$org, providerInfo$contact, providerInfo$orgURL, locsDesc, stringsAsFactors = F)
    colnames(locs) <- c('SiteID', 'SiteName', 'Provider', 'Backend', 'Access', 'Usr', 'Pwd', 'Latitude', 'Longitude', 'Active', 'Owner', 'Contact', 'ProviderURL', 'Description')
    locs <- na.omit(locs)
    outSiteDF <- locs[grepl(providerInfo$provider, locs$SiteID ),]
    outName <- paste0(rootDir, '/SensorInfo/', providerInfo$provider, '_Sites.csv')
    write.csv(outSiteDF, outName, row.names = F, quote = F)
    cat(paste0('Site info for ', providerInfo$provider, ' written to ',  outName, '\n'))
    vc(outName)

}

generateSensorInfo_SC <- function(providerInfo, rootDir){

    usrpwd <- paste0(providerInfo$usr, ':', providerInfo$pwd)
    sites <- read.csv(paste0(rootDir, '/SensorInfo/', providerInfo$provider , '_Sites.csv'))
    pb <- pbCreate(nrow(sites), progress='text', style=3, label='Generating Sensor data.....',timer=TRUE)
    
    sensorDF <- getEmptySensorDF()
    
    for(i in 1:nrow(sites)){
    
        id <- sites$SiteID[i]
        pbStep(pb, i)
        streams <- getURL(paste0(providerInfo$server, "/platforms/", id), userpwd=usrpwd, httpauth = 1L)
        #streams <- getURL(paste0(service, "/platforms/cosmoz.site.1.plat"), userpwd=usrpwd, httpauth = 1L)
        
        streamsJ <- fromJSON(streams)
        Snames <- streamsJ$`_embedded`$streams$id
        
        df <- data.frame( sites$SiteID[i], sites$SiteName[i], sites$Provider[i],providerInfo$backEnd, providerInfo$access, providerInfo$usr, providerInfo$pwd, providerInfo$server, sites$Latitude[i], sites$Longitude[i], Snames, '', NA, NA, NA, NA, NA, NA, '', stringsAsFactors = F)
        colnames(df) <- c('SiteID', 'SiteName', 'Provider', 'Backend', 'Access', 'Usr', 'Pwd', 'SeverName', 'Latitude', 'Longitude', 'SensorID', 'SensorName', 'StartDate', 'EndDate', 'DataType', 'UpperDepth', 'LowerDepth', 'Calibrated', 'Units')
        sensorDF <- rbind(sensorDF, df)
    
    }
    
    outName <- paste0(rootDir, '/SensorInfo/', providerInfo$provider, '_SensorsAll.csv')
    write.csv(sensorDF, outName, row.names = F, quote = F)
    pbClose(pb)
    cat(paste0('Sensor info for ', providerInfo$provider, ' written to ',  outName, '\n'))
    cat('\n')
    cat('OK. Now manually curate this file to expose the data you want\n')
    cat("Don't forget to recompile the 'AllSensors.csv' & 'AllSites.csv' files afetr these changes\n")
    vc(outName)
}

getURLAsync_SensorCloud <- function(x){
  usrpwd  <- 'ross.searle@csiro.au:rossiscool' # need to pass these inas parameters eventually


  response <- getURL(x, userpwd=usrpwd, httpauth = 1L)

  forDayData <- fromJSON(response, flatten=TRUE)
  ds1 <- str_replace(forDayData$results$t, 'T', ' ')
  ds2 <- str_replace(ds1, '.000Z', ' ')
  ndf <- data.frame(ds2, forDayData$results$v.v, stringsAsFactors = F) 
  
  colnames(ndf)<- c('theDate', 'Values')
  
  return(ndf)
}






