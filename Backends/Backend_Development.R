source('C:/Users/sea084/Dropbox/RossRCode/Git/SensorBackends/Backends/Backend_Config.R')

getSensorFields()

locs <-getSensorLocations(usr = 'Admin', pwd = 'ross')
unique(locs$Provider)

locs <-getSensorLocations(usr = 'BOM', pwd = 'b')
unique(locs$Provider)


locs <-getSensorLocations(usr = 'Public', pwd = 'Public', siteID = 'cosmoz.site.13.plat')
locs


locs <-getSensorLocations(usr = 'Public', pwd = 'Public', siteID = 'cosmoz.site.13.plat', sensorType = 'Soil-Moisture')
locs <-getSensorLocations(usr = 'Public', pwd = 'Public', siteID = 'op12253', sensorType = 'Soil-Moisture')
locs


sens <- getSensorInfo( siteID = 'op12253', sensorType = 'Soil-Moisture')
sens <- getSensorInfo( siteID = 'op12253')
sens <- getSensorInfo( sensorType = 'Soil-Moisture')
sens <- getSensorInfo()
nrow(sens)

ad <- getSensorDataStreams(usr='Public', pwd='Public', siteID ='cosmoz.site.2.plat', sensorType = 'Soil-Moisture')
ad <- getSensorDataStreams(usr='Public', pwd='Public', siteID ='op12253', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$days)


ad <- getSensorDataStreams(usr='Public', pwd='Public', siteID ='cosmoz.site.13.plat', sensorType = 'Soil-Moisture', outFormat = apiFormats$nestedTS)
ad <- getSensorDataStreams(usr='Public', pwd='Public', siteID ='op12253', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$quarters)
ad <- getSensorDataStreams(usr='Public', pwd='Public', siteID ='op12253', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$days, startDate = '01-01-2018', endDate = '05-01-2018')
ad <- getSensorDataStreams(usr='Public', pwd='Public', siteID ='op12253', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$days, startDate = '01-01-2018', endDate = '05-01-2018')



ad <- getSensorDataStreams(siteID ='cosmoz.site.15.plat', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$days, startDate = '01-01-2018', endDate = '05-01-2018')
ad <- getSensorDataStreams(siteID ='cosmoz.site.2.plat', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$none, startDate = '01-01-2018', endDate = '05-01-2018')


ad <- getSensorDataStreams(siteID ='op12253', sensorType = 'Soil-Moisture', sensorID = '233046',  aggPeriod = timeSteps$none, startDate = '01-01-2018', endDate = '05-01-2018')
ad <- getSensorDataStreams(siteID ='op12253', sensorType = 'Soil-Moisture', sensorID = '233047',  aggPeriod = timeSteps$none, startDate = '01-01-2018', endDate = '05-01-2018')
ad <- getSensorDataStreams(siteID ='op12253', sensorType = 'Soil-Moisture', aggPeriod = timeSteps$none, startDate = '01-01-2018', endDate = '05-01-2018')

head(ad)








