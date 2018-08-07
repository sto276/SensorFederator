library(testthat)
library(RCurl)
library(jsonlite)



sensorRootDir <- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorBackends'

source(paste0(sensorRootDir, '/Backends/Backend_Config.R'))



######   Run All tests  #########
test_results <- test_dir(paste0(sensorRootDir, '/UnitTests'))
print(test_results)


#### Fire up the local web server and run web API Tests only

test_results <- test_file(paste0(sensorRootDir, '/UnitTests/test_WebAPI.R'))
print(test_results)


