#' @param providerInfo Constant metadata about the SILO provider
#' @param station The station ID (string format) to access data
#'
#' @export
generateSiteInfo_SILO <- function(
  providerInfo,
  station
)
{
  url <- str_c(
    "https://legacy.longpaddock.qld.gov.au/cgi-bin/silo/PatchedPointDataset.php?",
    "format=Standard",
    "&station=",
    station,
    "&start=20190101",
    "&finish=20190102",
    "&username=",
    providerInfo$usr,
    "&password=",
    providerInfo$pwd
  )

  lines <- getURL(url) %>%
    str_split("\n")

  split <- str_split(lines[[1]][14], ":", n=4)

  name <- str_trim(split[[1]][2], c("left")) %>%
    word(2, -2) %>%
    str_trim(c("right"))

  latitude <- as.double(word(split[[1]][3], -2))
  longitude <- as.double(split[[1]][4])

  # Site metadata
  locs <- data.frame(str_c('SILO_', station),
                     name,
                     providerInfo$provider,
                     providerInfo$backEnd,
                     providerInfo$access,
                     providerInfo$usr,
                     providerInfo$pwd,
                     latitude,
                     longitude,
                     T,
                     providerInfo$org,
                     providerInfo$email,
                     providerInfo$server,
                     stringsAsFactors = F)

  colnames(locs) <- c('SiteID',
                      'SiteName',
                      'Provider',
                      'Backend',
                      'Access',
                      'Usr',
                      'Pwd',
                      'Latitude',
                      'Longitude',
                      'Active',
                      'Owner',
                      'Contact',
                      'ProviderURL',
                      'Description')

  locs <- na.omit(locs)

  outName <- str_c('SensorInfo/', providerInfo$provider, '_Sites.csv')
  write_csv(locs, outName, row.names = F, quote = F)
  cat('Site info for ', providerInfo$provider, ' written to ',  outName, '\n')
}

generateSensorInfo_SILO <- function(
  providerInfo
)
{
  url <- str_c(
    "https://legacy.longpaddock.qld.gov.au/cgi-bin/silo/PatchedPointDataset.php?",
    "format=Standard",
    "&station=",
    station,
    "&start=20190101",
    "&finish=20190102",
    "&username=",
    providerInfo$usr,
    "&password=",
    providerInfo$pwd
  )

  lines <- getURL(url) %>%
    str_split("\n")

  split <- str_split(lines[[1]][14], ":", n=4)

  name <- str_trim(split[[1]][2], c("left")) %>%
    word(2, -2) %>%
    str_trim(c("right"))

  latitude <- as.double(word(split[[1]][3], -2))
  longitude <- as.double(split[[1]][4])

  ##############
  sensorDF <- getEmptySensorDF()

  dfRain <- data.frame(paste0('Cosmoz_', stnsJ$stations$site_no),
                       stnsJ$stations$site_name,
                       providerInfo$provider,
                       providerInfo$backEnd,
                       providerInfo$access,
                       providerInfo$usr,
                       providerInfo$pwd,
                       providerInfo$server,
                       stnsJ$stations$latitude,
                       stnsJ$stations$longitude,
                       paste0(providerInfo$backEnd, stnsJ$stations$site_no, '_Rainfall'),
                       paste0('Cosmoz_', stnsJ$stations$site_no, '_Rainfall'),
                       stnsJ$stations$installation_date,
                       NA,
                       'Rainfall',
                       NA,
                       NA,
                       T,
                       'mm',
                       stringsAsFactors = F)

  colnames(dfRain) <- c('SiteID',
                        'SiteName',
                        'Provider',
                        'Backend',
                        'Access',
                        'Usr',
                        'Pwd',
                        'SeverName',
                        'Latitude',
                        'Longitude',
                        'SensorID',
                        'SensorName',
                        'StartDate',
                        'EndDate',
                        'DataType',
                        'UpperDepth',
                        'LowerDepth',
                        'Calibrated',
                        'Units')

  sensorDF <- rbind(sensorDF, dfRain)

  dfSM <- data.frame( paste0('Cosmoz_', stnsJ$stations$site_no),
                      stnsJ$stations$site_name,
                      providerInfo$provider,
                      providerInfo$backEnd,
                      providerInfo$access,
                      providerInfo$usr,
                      providerInfo$pwd,
                      providerInfo$server,
                      stnsJ$stations$latitude,
                      stnsJ$stations$longitude,
                      paste0(providerInfo$backEnd, stnsJ$stations$site_no, '_SoilMoisture'),
                      paste0('Cosmoz_', stnsJ$stations$site_no, '_SoilMoisture'),
                      stnsJ$stations$installation_date,
                      NA,
                      'Soil-Moisture',
                      0,
                      300,
                      T,
                      'percent',
                      stringsAsFactors = F)

  colnames(dfSM) <- c('SiteID',
                      'SiteName',
                      'Provider',
                      'Backend',
                      'Access',
                      'Usr',
                      'Pwd',
                      'SeverName',
                      'Latitude',
                      'Longitude',
                      'SensorID',
                      'SensorName',
                      'StartDate',
                      'EndDate',
                      'DataType',
                      'UpperDepth',
                      'LowerDepth',
                      'Calibrated',
                      'Units')

  sensorDF <- rbind(sensorDF, dfSM)

  outName <- paste0(rootDir, '/SensorInfo/', providerInfo$provider, '_SensorsAll.csv')
  write.csv(sensorDF, outName, row.names = F, quote = F)
  cat(paste0('Sensor info for ', providerInfo$provider, ' written to ',  outName, '\n'))
  cat('\n')
  cat('OK. Now manually curate this file to expose the data you want\n')
  cat("Don't forget to recompile the 'AllSensors.csv' & 'AllSites.csv' files afetr these changes\n")
  vc(outName)
}

SILO_GenerateTimeSeries <- function(
  response,
  retType = 'df'
)
{
  tsj <- fromJSON(response, flatten=T)
  if(tsj$count == 0){
    (stop('No records were returned for the specified query'))
  }
  dts <- str_replace(tsj$observations[,1], 'T', ' ')
  dts2 <- str_replace(dts, 'Z', '')
  vals <- tsj$observations[,2]

  if(retType == 'xts'){
    tz <- xts(as.numeric(vals), order.by = dts2)
    return (tz)
  }else if(retType == 'df'){
    ndf <- data.frame(dts2, vals)
    colnames(ndf)<- c('theDate', 'Values')
    return(ndf)

  }else{
    stop(cat(retType, 'is an unkown data return type. Options are', paste(knownAdconReturnTypes, collapse=',' )), call. = F)
  }
}

getURLAsync_SILO <- function(
  x
)
{
  response <- getURL(x)
  ndf<- SILO_GenerateTimeSeries(response, retType = 'df')
  return(ndf)
}

