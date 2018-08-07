


site <- 'cerdi.sfs.5278.platform'
site <- 'cosmoz.site.2.plat'

sensors <- sensorInfo[sensorInfo$SiteID == site & sensorInfo$DataType == 'Soil-Moisture', ]
sensors <- sensors[order(sensors$UpperDepth),]

aggregSeconds=timeSteps$day
startDate='09-04-2017'
endDate='11-08-2017'

d <- getSensorData(streams=sensors, backEnd='SensorCloud', aggregSeconds=timeSteps$weeks, startDate=startDate, endDate=endDate )
write.csv(to.DF(d), 'c:/temp/ts.csv')

ends <- endpoints(d,timeSteps$weeks,1) 

head(resampleTS(d, aggPeriod=timeSteps$weeks, ftype=timeAggMethods$max))

inTS <- d

resampleTS <- function(inTS, aggPeriod=timeSteps$day, ftype=timeAggMethods$mean){
  
  ends <- endpoints(inTS,aggPeriod,1)
  
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