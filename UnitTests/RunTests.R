library(testthat)
library(RCurl)
library(jsonlite)



sensorRootDir <- 'C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator'

source(paste0(sensorRootDir, '/Backends/Backend_Config.R'))
setup(print("Ross is a legend"))


######   Run All tests  #########
test_results_All <- test_dir(paste0(sensorRootDir, '/UnitTests'))
print(test_results_All)



test_resultsAPI <- test_file(paste0(sensorRootDir, '/UnitTests/test_API2.R'))
print(test_resultsAPI)


#### Fire up the local web server and run web API Tests only

test_resultWebapi <- test_file(paste0(sensorRootDir, '/UnitTests/test_WebAPI.R'))
print(test_resultWebapi)



