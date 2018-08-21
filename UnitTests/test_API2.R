

context('Backends')

sensorRootDir <- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'
source(paste0(sensorRootDir, '/Backends/Backend_Config.R'))




test_that('Cosmoz is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'Cosmoz_2' & sensorInfo$DataType == 'Rainfall' & sensorInfo$Backend=='Cosmoz', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors[1,],  aggPeriod=timeSteps$days , startDate='2017-05-27T09:00:00', endDate='2017-05-28T09:00:00', numrecs = 10000)
  expect_equal(length(d), 2)
})


test_that('DAFWA is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'DAFWA_BR' & sensorInfo$DataType == 'Rainfall', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors[1,],  aggPeriod=timeSteps$weeks, startDate='2017-08-22T09:00:00', endDate='2017-08-28T09:00:00')
  expect_equal(length(d), 1)
})


test_that('Outpost is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'op12251' & sensorInfo$DataType == 'Soil-Moisture', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors[1:3,], aggPeriod=timeSteps$days, startDate='2017-05-09T09:00:00', endDate='2017-05-11T09:00:00' )
  expect_equal(length(d), 9)
})


test_that('Senaps is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'cerdi.sfs.5278.platform' & sensorInfo$DataType == 'Soil-Moisture', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors,aggPeriod = timeSteps$days, startDate='2015-04-09T09:00:00', endDate='2015-04-11T09:00:00' )
  expect_equal(length(d), 27)
})


test_that('Adcon is working', {
  #sensors <- sensorInfo[sensorInfo$SiteID ==  '15314' & sensorInfo$DataType=='Rainfall', ]
  sensors <- sensorInfo[sensorInfo$SiteID ==  '15314' & sensorInfo$DataType=='Soil-Moisture', ]
  d <- getSensorData(streams=sensors,  aggPeriod=timeSteps$days , startDate='2016-05-27T09:00:00', endDate='2016-05-30T09:00:00')
  expect_equal(length(d), 20)
})