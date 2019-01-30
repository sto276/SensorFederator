
getURL_DataFarmer <- function(url, streams){

  response <- getURL(url)
  ndf<- DataFarmer_GenerateTimeSeries(response, streams, retType = 'df')
  return(ndf)
}


DataFarmer_GenerateTimeSeries <- function(response, streams, retType = 'df'){

  feats <- streams$SensorID

  tsj <- fromJSON(response, flatten=T)
  if(nrow(tsj) == 0){
    (stop('No records were returned for the specified query'))
  }

  bits <- str_split(tsj$ReadingTime, '[+]')
  UTCstr <- sapply(bits, function (x) x[1])
  UTC <- as.numeric(str_replace_all(UTCstr, "/Date[(]", ''))
  locTimeInc <- sapply(bits, function (x) x[2])
  lti <- as.numeric(str_replace_all(locTimeInc, "[)]/", ''))
  dts <- (UTC*0.001) + lti
  posDT <- as.POSIXct(dts, origin='1970-1-1')

  outList <-   vector("list", length(feats) )
  for(i in 1:length(feats)){
    ndf <- data.frame(posDT, tsj[feats[i]])
    colnames(ndf)<- c('theDate', 'Values')
    outList[[i]] <- ndf
  }


  return (outList)

}


