


# All od the settings are contained in Backend_Config.R

sitesInfo <- read.csv(paste0(sensorRootDir, '/SensorInfo/AllSites.csv'), stringsAsFactors = F)
sensorInfo <- read.csv(paste0(sensorRootDir, '/SensorInfo/AllSensors.csv'), stringsAsFactors = F)




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

 ## out <- tryCatch({

    backEnd <- streams$Backend[[1]][1]


    if(backEnd %in% knownBackends ){

          #if(streams$Access[1] == 'Public'){

              if(backEnd == 'SensorCloud'){

                  dfTS <- getSensorData_SensorCloud(streams=streams, startDate=startDate, endDate=endDate, aggPeriod=aggPeriod, numrecs=numrecs )
                  #return(ds)
              }else if(backEnd == 'Adcon') {
                  dfTS <- getSensorData_Adcon(streams=streams, startDate=startDate, endDate = endDate, aggPeriod=aggPeriod, numrecs=numrecs )
              }else if(backEnd == 'OutPost') {
                  dfTS <- getSensorData_Outpost(streams=streams, startDate=startDate, endDate = endDate, aggPeriod=aggPeriod, numrecs=numrecs )
              }

              dfTSm <- mergedfTSList(dfTS, streams = streams)
             print('here1')
             print(head(dfTSm))
              outts <- to.TS(dfTSm)
              print('here2')
              # if(aggPeriod != 'none'){
              #   resTS <- resampleTS(outts, aggPeriod, FeatureAggTypes[streams$DataType][1])
              #   return(resTS)
              # }else{
              #   return(outts)
              # }

             # outTS <- outts

              print(outFormat)

              if(aggPeriod != 'none'){
                outTS <- resampleTS(outts, aggPeriod, FeatureAggTypes[streams$DataType][1])
              }else{
                 outTS <- outts
               }


              if(outFormat=='nestedTS'){
                   ndf <- makeNestedDF(outTS, streams, startDate, endDate, aggperiod)
                   return(ndf)
              }else{
                  return(outTS)
              }


           #}else{

          #stop(paste0('You do not have permissions to access these sensors'), call. = F)
        #}

      }else{

        stop(paste0('Backend "' , backEnd, '" is not currently supported'), call. = F)
      }

    # }, error = function(e)
    # {
    #
    #   return(NULL)
    # }
    #
  #)

}

#ends <- endpoints(outts,'seconds',secs)
#outTS <- period.apply(outts,ends ,mean, na.rm=TRUE)







getSensorData_SensorCloud <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

  if(is.null(endDate))
  {
    dnowYMD <- format(Sys.time(), "%Y-%m-%d")
    isoEDate <- paste0(dnowYMD, 'T23:59:59.000Z')
  }else{
    edBits <- str_split(endDate, pattern = '-')
    ed <- paste0(edBits[[1]][3], '-', edBits[[1]][2], '-', edBits[[1]][1])
    isoEDate <- paste0(ed, 'T23:59:59.000Z')
  }

  if(is.null(startDate))
  {
    if(is.null(endDate))
    {
      ed <- format(Sys.time(), "%Y-%m-%d")
    }else{
      ed <- endDate
    }
    d <- ymd(ed) - years(1)
    isoSDate <- paste0(d, 'T00:00:00.000Z')
  }else{
    sdBits <- str_split(startDate, pattern = '-')
    sd <- paste0(sdBits[[1]][3], '-', sdBits[[1]][2], '-', sdBits[[1]][1])
    isoSDate <- paste0(sd, 'T00:00:00.000Z')
  }

  urls <- paste0( streams$SeverName, '/observations?streamid=', streams$SensorID,'&start=',isoSDate,'&end=',isoEDate , '&limit=', numrecs)
  print(urls)
  dataStreamsDF <- synchronise(async_map(
    urls,
    getURLAsync_SensorCloud, .limit = asyncThreadNum
  ))

  return(dataStreamsDF)
}


getSensorData_Adcon <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

  if(is.null(endDate))
  {
    dnowYMD <- format(Sys.time(), "%Y%m%d")
    isoEDate <- paste0(dnowYMD, 'T23:59:59')
  }else{
    edBits <- str_split(endDate, pattern = '-')
    ed <- paste0(edBits[[1]][3], '', edBits[[1]][2], '', edBits[[1]][1])
    isoEDate <- paste0(ed, 'T23:59:59')
  }

  if(is.null(startDate))
  {
    if(is.null(endDate))
    {
      ed <- format(Sys.time(), "%Y%m%d")
    }else{
      ed <- endDate
    }
    d <- ymd(ed) - years(1)
    isoSDate <- paste0(d, 'T00:00:00')
  }else{
    sdBits <- str_split(startDate, pattern = '-')
    sd <- paste0(sdBits[[1]][3], '', sdBits[[1]][2], '', sdBits[[1]][1])
    isoSDate <- paste0(sd, 'T00:00:00')
  }


  inter = 900
  sd <- as.POSIXct(isoSDate, format="%Y%m%dT%H:%M:%S")
  ed <- as.POSIXct(isoEDate, format="%Y%m%dT%H:%M:%S")

  deltaSecs <- as.numeric(ed-sd,units="secs")
  slots <- round(deltaSecs/inter) - 1
  server <- streams$SeverName
  auth <- adconLogin(usr=streams$Usr[1], pwd=streams$Pwd[1])
  urls <- paste0(streams$SeverName, '/addUPI?function=getdata&session-id=', auth , '&id=', nodeID=streams$SensorID, '&date=', isoSDate, '&slots=', slots , '&mode=' , mode)
  print(urls)
  adconServer <- streams$SeverName
  dataStreamsDF <- synchronise(async_map(
    urls,
    getURLAsync_Adcon, .limit = asyncThreadNum
  ))
  adconLogout(AuthID = auth)


  return(dataStreamsDF)


}


getSensorData_Outpost <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

 # 1/Dec/2017%2000:00:00
  if(is.null(endDate))
  {
    month.abb[4]
    dnowYMD <- format(Sys.time(), "%d/%b/%Y")
    isoEDate <- paste0(dnowYMD, '%2023:59:59')
  }else{
    edBits <- str_split(endDate, pattern = '-')
    ed <- paste0(edBits[[1]][1], '/', month.abb[as.numeric(edBits[[1]][2])], '/', edBits[[1]][3])
    isoEDate <- paste0(ed, '%2023:59:59')
  }

  if(is.null(startDate))
  {
    if(is.null(endDate))
    {
      ed <- format(Sys.time(), "%Y%m%d")
    }else{
      ed <- endDate
    }
    d <- ymd(ed) - years(1)
    isoSDate <- paste0(d, '%2000:00:00')
  }else{
    sdBits <- str_split(startDate, pattern = '-')
    sd <- paste0(sdBits[[1]][1], '/', month.abb[as.numeric(sdBits[[1]][2])], '/', sdBits[[1]][3])
    isoSDate <- paste0(sd, '%2000:00:00')
  }





  urls <- paste0(streams$SeverName, '/api/2.0/dataservice/mydata.aspx?userName=',  streams$Usr, '&password=', streams$Pwd,
                    '&dateFrom=' , isoSDate, '&dateTo=', isoEDate, '&outpostID=', streams$SiteID, '&inputID=', streams$SensorID)

  print(urls)

   dataStreamsDF <- synchronise(async_map(
    urls,
    getURLAsync_OutPost, .limit = asyncThreadNum
  ))



  return(dataStreamsDF)


}













getSensorFields <- function(){
  return (colnames(sensorInfo))
}


getSensorLocations <- function(usr='Public', pwd='Public', siteID=NULL, sensorType=NULL){


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
   return(NULL)
 }
 return(outDF)

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
  }else{
    sensors <- sensors[sensors$SiteID == siteID & sensors$DataType == sensorType, ]
  }

  print(outFormat)
  d <- getSensorData(streams=sensors, aggPeriod=aggPeriod, startDate=startDate, endDate=endDate, outFormat=outFormat  )
  print(d)
  return(d)
}



