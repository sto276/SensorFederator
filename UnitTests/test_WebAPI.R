


context('Web API')

#system('C:/R/R-3.4.4/bin/Rscript.exe C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederationWebAPI/StartServices.R')
#system('taskkill /F /IM Rscript.exe')


#### make sure the viewer code is commented out before doing this or it will fail
setup(system('C:/R/R-3.4.4/bin/Rscript.exe C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederatorWebAPI/StartServices.R', wait=F))
setup(Sys.sleep(2))


test_that('Sensors are available', {

  url <- 'http://127.0.0.1:8070/SensorAPI/getSensorLocations'
  resp <- getURL(url)
  d <- fromJSON(resp)
  expect_gt(nrow(d), 200)
})

test_that('Incorrect login error is thrown', {

  url <- 'http://127.0.0.1:8070/SensorAPI/getSensorLocations?usr=noone'
  resp <- getURL(url)
  d <- fromJSON(resp)
  expect_equal(d$error, "Incorrect user name or password - username actually")
})



teardown(suppressWarnings(suppressMessages(system('taskkill /F /IM Rscript.exe',ignore.stdout =T, ignore.stderr=T, show.output.on.console=F))))
