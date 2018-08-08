

context('Backends')

sensorRootDir <- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'
source(paste0(sensorRootDir, '/Backends/Backend_Config.R'))




test_that('Cosmoz is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'Cosmoz_2' & sensorInfo$DataType == 'Rainfall' & sensorInfo$Backend=='Cosmoz', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors[1,],  aggPeriod=timeSteps$days , startDate='27-05-2017', endDate='28-05-2017', numrecs = 10000)
  expect_equal(length(d), 2)
})


test_that('DAFWA is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'DAFWA_BR' & sensorInfo$DataType == 'Rainfall', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors[1,],  aggPeriod=timeSteps$weeks, startDate='22-08-2017', endDate='28-08-2017')
  expect_equal(length(d), 1)
})


test_that('Outpost is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'op12251' & sensorInfo$DataType == 'Soil-Moisture', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors[1:3,], aggPeriod=timeSteps$days, startDate='09-05-2017', endDate='11-05-2017' )
  expect_equal(length(d), 9)
})


test_that('Senaps is working', {
  sensors <- sensorInfo[sensorInfo$SiteID == 'cerdi.sfs.5278.platform' & sensorInfo$DataType == 'Soil-Moisture', ]
  sensors <- sensors[order(sensors$UpperDepth),]
  d <- getSensorData(streams=sensors,aggPeriod = timeSteps$days, startDate='09-04-2017', endDate='11-04-2017' )
  expect_equal(length(d), 27)
})


test_that('Adcon is working', {
  sensors <- sensorInfo[sensorInfo$SiteID ==  '15314' & sensorInfo$DataType=='Rainfall', ]
  d <- getSensorData(streams=sensors[1,],  aggPeriod=timeSteps$none , startDate='27-05-2016', endDate='29-05-2016')
  expect_equal(length(d), 2)
})