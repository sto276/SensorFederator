


# All od the settings are contained in Backend_Config.R

sitesInfo <- read.csv(paste0(sensorRootDir, '/SensorInfo/AllSites.csv'), stringsAsFactors = F)
#sitesInfo <- allSitesInfo[allSitesInfo$Active,]
allSensorInfo <- read.csv(paste0(sensorRootDir, '/SensorInfo/AllSensors.csv'), stringsAsFactors = F)
sensorInfo <- allSensorInfo[allSensorInfo$Active,]
print(sensorInfo[sensorInfo$Provider=='Cosmoz', ])

defaultStartTime <- '09:00:00'
#defaultEndTime <- '8:59:59'


#' Retrieve a timeseries of sensor data
#'
#' Gets a timeseries of sensor data as a dataframe from a given sensor platform
#'
#' @param streamID The unique ID used to identify the sensor - taken from the sensor metadata
#' @param backEnd The telemetry platform to query
#' @param startDate Start date of data stream to retrieve in dd-mm-yyyy format
#' @param endDate End date of data stream to retrieve in dd-mm-yyyy format
#' @param aggregSeconds Aggregation time step in seconds
#' @param numrecs Total number of records to return
#'
#' @return DataFrame containing date and data columns
#'
#' @examples
#' getSensorData('cerdi.sfs.4935.stream.4983.soil-moisture.1000mm')
#'
#' @export
getSensorData <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$days, numrecs=maxRecs, outFormat='simpleTS' ){

  out <- tryCatch({

    backEnd <- streams$Backend[[1]][1]


    if(backEnd %in% knownBackends ){




#### generate dates in ISO if none supplied
      if(is.null(endDate))
      {
        dnowYMD <- format(Sys.time(), "%Y-%m-%d")
        isoEDate <- paste0(dnowYMD, 'T', defaultStartTime, '')
      }else{
        isoEDate <- endDate
      }

      if(is.null(startDate))
      {
        if(is.null(endDate))
        {
          ed <- format(Sys.time(), "%Y-%m-%d")
          ed <- paste0(ed,  'T', defaultStartTime, '')
        }else{
          ed <- endDate
        }
        edp <- strptime(ed, "%Y-%m-%dT%H:%M:%S")
        py <- edp - 31536000
        as.character(py)
        isoSDate <- str_replace_all(as.character(py), ' ', 'T')
      }else{
        isoSDate <- startDate
      }




# send the request off to the various backends

      if(backEnd == 'SensorCloud'){
          dfTS <- getSensorData_SensorCloud(streams=streams, startDate=isoSDate, endDate=isoEDate, aggPeriod=aggPeriod, numrecs=numrecs )
      }else if(backEnd == 'Adcon') {
          dfTS <- getSensorData_Adcon(streams=streams, startDate=isoSDate, endDate = isoEDate, aggPeriod=aggPeriod, numrecs=numrecs )
      }else if(backEnd == 'OutPost') {
          dfTS <- getSensorData_Outpost(streams=streams, startDate=isoSDate, endDate = isoEDate, aggPeriod=aggPeriod, numrecs=numrecs )
      }else if(backEnd == 'Cosmoz') {
          dfTS <- getSensorData_Cosmoz(streams=streams, startDate=isoSDate, endDate = isoEDate, aggPeriod=aggPeriod, numrecs=numrecs )
      }else if(backEnd == 'DAFWA') {
          dfTS <- getSensorData_DAFWA(streams=streams, startDate=isoSDate, endDate = isoEDate, aggPeriod=aggPeriod, numrecs=numrecs )
      }


# Transform the repsonse as requested

      dfTSm <- mergedfTSList(dfTS, streams = streams)

      if(nrow(dfTSm) > 0){
        outts <- to.TS(dfTSm)
        if(aggPeriod != 'none'){
          # outTS <- resampleTS(outts, aggPeriod, FeatureAggTypes[streams$DataType][1])
          outTS <- resampleTS(outts, aggPeriod, FeatureAggTypes[streams$DataType][1], startDate=isoSDate, endDate = isoEDate)
        }else{
          outTS <- outts
        }

        if(outFormat=='nestedTS'){
          ndf <- makeNestedDF(outTS, streams, isoSDate, isoEDate, aggPeriod)
          return(ndf)
        }else{
          return(outTS)
        }
      }else{
        return(NULL)
      }

      }else{

        stop(paste0('Backend "' , backEnd, '" is not currently supported'), call. = F)
      }

  }, error = function(e)
  {

    stop(geterrmessage())
  }

  )

}




# getDatesForSpecificAPI <- function(startDate = NULL, endDate = NULL){
#
#
#
#   if(is.null(endDate))
#   {
#     dnowYMD <- format(Sys.time(), "%Y-%m-%d")
#     isoEDate <- paste0(dnowYMD, 'T', defaultEndTime)
#   }else{
#     edBits <- str_split(endDate, pattern = '-')
#     ed <- paste0(edBits[[1]][3], '-', edBits[[1]][2], '-', edBits[[1]][1] )
#     isoEDate <- ed
#   }
#
#   if(is.null(startDate))
#   {
#     if(is.null(endDate))
#     {
#       ed <- format(Sys.time(), "%Y-%m-%d")
#     }else{
#       ed <- endDate
#     }
#     d <- ymd(ed) - years(1)
#     isoSDate <- paste0(d)
#   }else{
#     sdBits <- str_split(startDate, pattern = '-')
#     sd <- paste0(sdBits[[1]][3], '-', sdBits[[1]][2], '-', sdBits[[1]][1])
#     isoSDate <- paste0(sd)
#   }
#
# }


getSensorData_DAFWA <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){



 # https://api.agric.wa.gov.au/v1/weatherstations/dailysummary.json?station_code=', 'BR', '&fromDate=2016-01-01&toDate=2016-09-29&api_key=CCB3F85A64008C6AC1789E4F.apikey

  isoSDate <- as.Date(startDate)
  isoEDate <- as.Date(endDate)


  siteid <- str_remove(streams$SiteID, paste0(streams$Provider, '_'))
  urls <- paste0( streams$SeverName, '/weatherstations/dailysummary.json?station_code=',siteid, '&fromDate=',isoSDate,'&toDate=',isoEDate ,'&api_key=CCB3F85A64008C6AC1789E4F.apikey')
#print(urls)
  tryCatch({
    dataStreamsDF <- synchronise(async_map( urls,  getURLAsync_DAFWA, .limit = asyncThreadNum ))
    }, error = function(e)
    {
      stop('No records were returned for the specified query. Most likely there is no data available in the date range specified - (async processing error)')
    })



  return(dataStreamsDF)
}


getSensorData_Cosmoz <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

  siteid <- str_remove(streams$SiteID, paste0(streams$Provider, '_'))

  if(str_to_lower(streams$DataType) == 'soil-moisture'){
    filt <- 'soil_moist_filtered'
  }else{
    filt <- 'rainfall'
  }
  urls <- paste0( streams$SeverName, '/rest/station/', siteid, '/records?processing_level=4', '&startdate=',startDate,'Z&enddate=',endDate ,'Z&property_filter=', filt,  '&count=', format(numrecs, scientific = FALSE) , '&offset=0')

  #print(urls)
  tryCatch({
    dataStreamsDF <- synchronise(async_map( urls,  getURLAsync_Cosmoz, .limit = asyncThreadNum ))

  }, error = function(e)
  {
    stop('No records were returned for the specified query. Most likely there is no data available in the date range specified - (async processing error)')
  })
  return(dataStreamsDF)
}


getSensorData_SensorCloud <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

  # if(is.null(endDate))
  # {
  #   dnowYMD <- format(Sys.time(), "%Y-%m-%d")
  #   isoEDate <- paste0(dnowYMD, 'T23:59:59.000Z')
  # }else{
  #   edBits <- str_split(endDate, pattern = '-')
  #   ed <- paste0(edBits[[1]][3], '-', edBits[[1]][2], '-', edBits[[1]][1])
  #   isoEDate <- paste0(ed, 'T23:59:59.000Z')
  # }
  #
  # if(is.null(startDate))
  # {
  #   if(is.null(endDate))
  #   {
  #     ed <- format(Sys.time(), "%Y-%m-%d")
  #   }else{
  #     ed <- endDate
  #   }
  #   d <- ymd(ed) - years(1)
  #   isoSDate <- paste0(d, 'T00:00:00.000Z')
  # }else{
  #   sdBits <- str_split(startDate, pattern = '-')
  #   sd <- paste0(sdBits[[1]][3], '-', sdBits[[1]][2], '-', sdBits[[1]][1])
  #   isoSDate <- paste0(sd, 'T00:00:00.000Z')
  # }

  isoSDate <- paste0(startDate, '.000Z')
  isoEDate <- paste0(endDate, '.000Z')

  urls <- paste0( streams$SeverName, '/observations?streamid=', streams$SensorID,'&start=',isoSDate,'&end=',isoEDate , '&limit=', format(numrecs, scientific = FALSE))
  #print(urls)
  tryCatch({
  dataStreamsDF <- synchronise(async_map(urls, getURLAsync_SensorCloud, .limit = asyncThreadNum))
  }, error = function(e)
  {
    stop('No records were returned for the specified query. Most likely there is no data available in the date range specified - (async processing error)')
  }
)

  return(dataStreamsDF)
}


getSensorData_Adcon <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

  # if(is.null(endDate))
  # {
  #   dnowYMD <- format(Sys.time(), "%Y%m%d")
  #   isoEDate <- paste0(dnowYMD, 'T23:59:59')
  # }else{
  #   edBits <- str_split(endDate, pattern = '-')
  #   ed <- paste0(edBits[[1]][3], '', edBits[[1]][2], '', edBits[[1]][1])
  #   isoEDate <- paste0(ed, 'T23:59:59')
  # }
  #
  # if(is.null(startDate))
  # {
  #   if(is.null(endDate))
  #   {
  #     ed <- format(Sys.time(), "%Y%m%d")
  #   }else{
  #     ed <- endDate
  #   }
  #   d <- ymd(ed) - years(1)
  #   isoSDate <- paste0(d, 'T00:00:00')
  # }else{
  #   sdBits <- str_split(startDate, pattern = '-')
  #   sd <- paste0(sdBits[[1]][3], '', sdBits[[1]][2], '', sdBits[[1]][1])
  #   isoSDate <- paste0(sd, 'T00:00:00')
  # }



  sd <- as.POSIXct(startDate, format="%Y-%m-%dT%H:%M:%S")
  ed <- as.POSIXct(endDate, format="%Y-%m-%dT%H:%M:%S")
  isoSDate <- str_remove_all(startDate, '-')

  server <- streams$SeverName
  auth <- adconLogin(usr=streams$Usr[1], pwd=streams$Pwd[1])

  inter = pokeDuration_Adcon(usr=streams$Usr[1], pwd=streams$Pwd[1], nodeID=streams$SensorID[1], date=isoSDate, slots = 2)
  deltaSecs <- as.numeric(ed-sd,units="secs")
  slots <- round(deltaSecs/inter)

  urls <- paste0(streams$SeverName, '/addUPI?function=getdata&session-id=', auth , '&id=', nodeID=streams$SensorID, '&date=', isoSDate, '&slots=', slots , '&mode=' , mode)
 #print(urls)
  adconServer <- streams$SeverName
  tryCatch({
  dataStreamsDF <- synchronise(async_map(urls, getURLAsync_Adcon, .limit = asyncThreadNum ))
  }, error = function(e)
  {
    stop('No records were returned for the specified query. Most likely there is no data available in the date range specified - (async processing error)')
  })
  adconLogout(AuthID = auth)

  return(dataStreamsDF)

}


getSensorData_Outpost <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){


  # if(is.null(endDate))
  # {
  #   month.abb[4]
  #   dnowYMD <- format(Sys.time(), "%d/%b/%Y")
  #   isoEDate <- paste0(dnowYMD, '%2023:59:59')
  # }else{
  #   edBits <- str_split(endDate, pattern = '-')
  #   ed <- paste0(edBits[[1]][1], '/', month.abb[as.numeric(edBits[[1]][2])], '/', edBits[[1]][3])
  #   isoEDate <- paste0(ed, '%2023:59:59')
  # }
  #
  # if(is.null(startDate))
  # {
  #   if(is.null(endDate))
  #   {
  #     ed <- format(Sys.time(), "%Y%m%d")
  #   }else{
  #     ed <- endDate
  #   }
  #   d <- ymd(ed) - years(1)
  #   isoSDate <- paste0(d, '%2000:00:00')
  # }else{
  #   sdBits <- str_split(startDate, pattern = '-')
  #   sd <- paste0(sdBits[[1]][1], '/', month.abb[as.numeric(sdBits[[1]][2])], '/', sdBits[[1]][3])
  #   isoSDate <- paste0(sd, '%2000:00:00')
  # }


  isoSDate <- str_replace_all(startDate, '-', '/')
  isoEDate <- str_replace_all(endDate, '-', '/')


  urls <- paste0(streams$SeverName, '/api/2.0/dataservice/mydata.aspx?userName=',  streams$Usr, '&password=', streams$Pwd,
                    '&dateFrom=' , isoSDate, '&dateTo=', isoEDate, '&outpostID=', streams$SiteID, '&inputID=', streams$SensorID)
  tryCatch({
   dataStreamsDF <- synchronise(async_map(urls, getURLAsync_OutPost, .limit = asyncThreadNum))
  }, error = function(e)
  {
    stop('No records were returned for the specified query. Most likely there is no data available in the date range specified - (async processing error)')
  })

  return(dataStreamsDF)


}













getSensorFields <- function(){
  return (colnames(sensorInfo))
}



getSensorLocations <- function(usr='Public', pwd='Public', siteID=NULL, sensorType=NULL, longitude=NULL, latitude=NULL, radius_km=NULL, bbox=NULL,  numToReturn=NULL){


 sensors <- getAuthorisedSensors(usr=usr, pwd=pwd)

 if(!is.null(siteID)){
   sensors <- sensors[sensors$SiteID==siteID,]
 }
 if(!is.null(sensorType)){
   sensors <- sensors[sensors$DataType==sensorType,]
 }

 s <- sensors[row.names(unique(sensors[,c("SiteName", "SiteID")])),]

 df1 <- merge(sitesInfo, s, by='SiteID')

 outDF <- data.frame(df1$SiteID,df1$SiteName.x, df1$Provider.x, df1$Backend.x, df1$Access.x,
                     df1$Longitude.x, df1$Latitude.x, df1$Active, df1$Owner, df1$Contact,
                     df1$ProviderURL, df1$Description, df1$StartDate, df1$EndDate)
 colnames(outDF) <- c('SiteID','SiteName','Provider','Backend','Access','Longitude','Latitude',
                     'Active','Owner','Contact','ProviderURL','Description','StartDate','EndDate')

 if(nrow(outDF) == 0){
   stop("No sensors could be found : getsensolocations")
 }


 if(!is.null(bbox)){
   qtype = 'bbox'
 }else if (!is.null(longitude) & !is.null(latitude)){
   qtype = 'point'
 }else{
   qtype = 'All'
 }


 if(qtype=='point'){
   coordinates(outDF) <- ~Longitude+Latitude
   crs(outDF) <- CRS("+proj=longlat +datum=WGS84")
   dist <- spDistsN1(outDF,c(as.numeric(longitude), as.numeric(latitude)), longlat = T)
   dfDist <- data.frame(outDF, distance=dist)
   outdfraw <- dfDist[order(dfDist$distance),]

   if(!is.null(radius_km)){
      outdf <- outdfraw[outdfraw$distance <= as.numeric(radius_km), ]
   }else{
      outdf <- outdfraw
   }

 }else if(qtype=='bbox'){
   bits <- str_split(bbox, ';')
   ymin <- as.numeric(bits[[1]][1])
   xmin <- as.numeric(bits[[1]][2])
   ymax <- as.numeric(bits[[1]][3])
   xmax <- as.numeric(bits[[1]][4])
   outdf <- outDF[outDF$Longitude >= xmin & outDF$Longitude <= xmax & outDF$Latitude >= ymin & outDF$Latitude <= ymax, ]

 }else{
   outdf <- outDF
 }


 n <- min(nrow(outdf), numToReturn)
 return(outdf[1:n, ])





}


getSensorInfo <-  function(usr='Public', pwd='Public', siteID=NULL, sensorType=NULL ){

  sensors <- getAuthorisedSensors(usr=usr, pwd=pwd)
  if(!is.null(siteID) & !is.null(sensorType))
  {
    sensors <- sensors[sensors$SiteID == siteID & sensors$DataType == sensorType, ]
  }else if(!is.null(siteID)){
    sensors <- sensors[sensors$SiteID == siteID, ]
  }else if(!is.null(sensorType)){
    sensors <- sensors[sensors$DataType == sensorType, ]
  }

  drops <- c("Usr","Pwd")
  outDF <-  sensors[ , !(names(sensors) %in% drops)]

  return(outDF)
}


getSensorDataStreams <-  function(usr='Public', pwd='Public', siteID=NULL, sensorType=NULL, sensorID=NULL, startDate=NULL, endDate=NULL, aggPeriod=timeSteps$none, outFormat='simpleTS' ){

  # restricted to a single location for so as to not overload bacend requests
  # have to restrict requests to a single data type as they have different aggregation types - could not aggregat but this may not be a common use case
  if(is.null(siteID) & is.null(sensorID))
    return(NULL)
   if(is.null(sensorType)& is.null(sensorID))
     return(NULL)

  sensors <- getAuthorisedSensors(usr=usr, pwd=pwd)

  if(!is.null(sensorID)){
    sensors <- sensors[sensors$SiteID == siteID & sensors$DataType == sensorType & sensors$SensorID == sensorID, ]
    if(nrow(sensors) < 1){stop('Could not find the specified sensor')}
  }else{
    sensors <- sensors[sensors$SiteID == siteID & sensors$DataType == sensorType, ]
    if(nrow(sensors) < 1){stop('Could not find the specified sensor')}
  }

  d <- getSensorData(streams=sensors, aggPeriod=aggPeriod, startDate=startDate, endDate=endDate, outFormat=outFormat  )

  return(d)
}


plotSensorLocationsImage <- function(DF){


  coordinates(DF) <- ~Longitude+Latitude

  pPath <- paste0(sensorRootDir, '/AncillaryData/Aust.shp')
  austBdy <- readShapeFile(pPath)

  scale.parameter = 1  # scaling paramter. less than 1 is zooming in, more than 1 zooming out.
  xshift = -0.1  # Shift to right in map units.
  yshift = 0.2  # Shift to left in map units.
  original.bbox = austBdy@bbox  # Pass bbox of your Spatial* Object.

  # Just copy-paste the following
  edges = original.bbox

  edges[1, ] <- (edges[1, ] - mean(edges[1, ])) * scale.parameter + mean(edges[1,]) + xshift
  edges[2, ] <- (edges[2, ] - mean(edges[2, ])) * scale.parameter + mean(edges[2,]) + yshift



  rbPal <- colorRampPalette(c('red','blue'))

  Col <- rbPal( length(knownBackends))
  levels <- knownBackends
  #legend("topleft", fill = Col, legend = levels, col = Col)

  rv = list("sp.polygons", austBdy, fill = "grey")

  spp <-  spplot(DF["Backend"], sp.layout = list(rv), key.space = "bottom", main = "Sensor Locations", xlim = edges[1, ], ylim = edges[2, ])

 return(spp)

}


