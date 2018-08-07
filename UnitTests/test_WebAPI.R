


context('Web API')

#system('C:/R/R-3.4.4/bin/Rscript.exe C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederationWebAPI/StartServices.R')
#system('taskkill /F /IM Rscript.exe')

setup(system('C:/R/R-3.4.4/bin/Rscript.exe C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederationWebAPI/StartServices.R', wait=F))
setup(Sys.sleep(2))


test_that('Sensors are available', {

  url <- 'http://127.0.0.1:8070/SensorAPI/getSensorLocations'
  resp <- getURL(url)
  d <- fromJSON(resp)
  expect_equal(nrow(d), 302)
})

test_that('Incorrect login error is thrown', {

  url <- 'http://127.0.0.1:8070/SensorAPI/getSensorLocations?usr=noone'
  resp <- getURL(url)
  d <- fromJSON(resp)
  expect_equal(d$error, "Incorrect user name or password")
})


teardown(system('taskkill /F /IM Rscript.exe'))
