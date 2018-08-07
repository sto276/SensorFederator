library(XML)
library(xts)

#print(paste0(' BEU = ',sensorRootDir ))
source(paste0(sensorRootDir, '/Backends/Backends.R'))



convertJSONtoDF <- function(resp){
  
  xin <- fromJSON(resp)
  outDF <- data.frame(xin$DataStream[[1]]$t)
  cnames<- c('DateTime', rep('x', nrow(xin)))
  
  for (i in 1:nrow(xin)) {
    d <- xin[i,]
    dd <- d$DataStream 
    outDF[, (i+1)] <- dd[[1]]$v
    
    d$DataType
    d$UpperDepthCm
    
    if(is.na(d$UpperDepth[1])){
      suffix = paste0('_x', i)
    }else if(d$UpperDepth == d$LowerDepth[1]){
      suffix = paste0('_', d$UpperDepth[1])
    }else{
      suffix =  paste0('_', d$UpperDepth[1], '_', d$LowerDepth[1])
    }
    cnames[i+1] <- c(paste0(d$DataType[1],suffix))
  }
  colnames(outDF) <- cnames
  return(outDF)
}


makeNestedDF <- function(TS, sensors, startDate, endDate, aggperiod){

  print(paste0('ag  = ', aggperiod))
  
  DF <- to.DF(TS)

  x <- data.frame(matrix(NA, nrow= (ncol(DF)-1), ncol=18))

  colnames(x) <- c('SiteID', 'SiteName', 'Provider', 'Backend', 'Access', 'Latitude', 'Longitude', 'SensorID', 'SensorName',
                   'UpperDepthCm', 'LowerDepthCm', 'RequestStartDate', 'RequestEndDate', 'AggregationPeriod', 'DataType',
                   'Units', 'Calibrated', 'DataStream')

  x$SiteID <- sensors$SiteID
  x$SiteName <- sensors$SiteName
  x$Provider <- sensors$Provider
  x$Backend <- sensors$Backend
  x$Access <- sensors$Access
  x$Latitude <- sensors$Latitude
  x$Longitude <- sensors$Longitude
  x$SensorID <- sensors$SensorID
  x$SensorName <- sensors$SensorName
  x$UpperDepthCm <- sensors$UpperDepth
  x$LowerDepthCm <- sensors$LowerDepth
  x$RequestStartDate <- startDate
  x$RequestEndDate <- endDate
  x$AggregationPeriod <- aggperiod
  x$DataType <- sensors$DataType
  x$Units <- sensors$Units
  x$Calibrated <- sensors$Calibrated

 print(str(x))

  TSout <- vector("list", ncol(DF)-1)

  for (i in 1 : (ncol(DF)-1)) {
    rdf <- data.frame(t=DF$DateTime, v=DF[i+1])
    colnames(rdf) <- c('t','v')
    TSout[[i]] <- rdf
  }



  x$DataStream <- I(TSout)


  print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')

  # jsn <- prettify(toJSON(x))
  # cat(jsn, file='c:/temp/aj.json')
  #
  # xin <- fromJSON('c:/temp/aj.json')

  return(x)

}


mergedfTSList <- function(listofDFTS, streams){

  lodf = list(length=nrow(streams))
  for(i in 1:nrow(streams)){

    ndf <- listofDFTS[[i]]
    sensor = streams[i, ]
    if(is.na(sensor$UpperDepth[1])){
      suffix = paste0('_x', i)
    }else if(sensor$UpperDepth == sensor$LowerDepth[1]){
      suffix = paste0('_', sensor$UpperDepth[1])
    }else{
      suffix =  paste0('_', sensor$UpperDepth[1], '_', sensor$LowerDepth[1])
    }
    colnames(ndf) <- c('Date', paste0(streams$DataType[1],suffix))

    lodf[[i]] <- ndf
  }

  mdf = Reduce(function(...) merge(..., all=T), lodf)
  return(mdf)

}



convertToXML <- function(df){

  xml <- xmlTree()
  xml$addTag("document", close=FALSE)
  for (i in 1:nrow(df)) {
    xml$addTag("row", close=FALSE)
    for (j in names(df)) {
      xml$addTag(j, df[i, j])
    }
    xml$closeTag()
  }
  xml$closeTag()
  outXml <- cat(saveXML(xml))
  return (outXml)
}


to.TS <- function(df){
  cns <-names(df)
df <- na.omit(df)
#write.csv(df, 'c:/temp/ts.csv')
#print(as.POSIXlt(df[,1]))
  ts <- xts(x=df[,-1], order.by=as.POSIXlt(df[,1], format = "%Y-%m-%d %H:%M:%S"), tzone =  "Australia/Brisbane")
  #ts <- xts(x=df[,-1],unique = FALSE, order.by=as.POSIXlt(df[,1], format = "%Y-%m-%d %H:%M:%S"), tzone =  Sys.getenv("TZ"))

  colnames(ts) <- cns[-1]

  return(ts)
}

to.DF <- function(ts){
  DF <- data.frame(DateTime=index(ts), coredata(ts),row.names=NULL)
}


cMax <- function(x){
  apply(x, 2, function(x) max(x, na.rm = TRUE))
}

cMin <- function(x){
  apply(x, 2, function(x) min(x, na.rm = TRUE))
}

cSum <- function(x){
  apply(x, 2, function(x) sum(x, na.rm = TRUE))
}

cMean<- function(x){
  apply(x, 2, function(x) mean(x, na.rm = TRUE))
}


resampleTS <- function(inTS, aggPeriod=timeSteps$day, ftype=timeAggMethods$mean){

  ends <- endpoints(inTS,aggPeriod,1)
  #print(ends)

  if(ftype==timeAggMethods$mean){
    outTS <- period.apply(inTS,ends ,cMean)
    return(outTS)
  }else if(ftype==timeAggMethods$sum){
    outTS <- period.apply(inTS,ends ,cSum)
    return(outTS)
  }else if(ftype==timeAggMethods$max){
    outTS <- period.apply(inTS,ends ,cmax)
    return(outTS)
  }else if(ftype==timeAggMethods$min){
    outTS <- period.apply(inTS,ends ,cMin)
    return(outTS)
  }else if(ftype==timeAggMethods$none){
    return(inTS)
  }else{
    return(inTS)
  }

}



getEmptySensorDF <- function(){

  sensorDF <- data.frame( SiteID = character(), SiteName = character(), Provider = character(), Organisation = character(),
                          Backend = character(), Access = character(), Usr = character(), pwd = character(),
                          Latitude = numeric(), Longitude=numeric(), serverName=character(), SensorID = character(),
                          sensorName = character(), StartDate = character(), EndDate = character(), DataType = character(),
                          UpperDepth = numeric(), LowerDepth = numeric(), Calibrated = logical(), Units = character(), stringsAsFactors = F )

}


