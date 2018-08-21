source('C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/Backends/Backends.R')



# Merge the individual 'Sites' csvs
files  <- list.files(paste0(sensorRootDir, '/SensorInfo'), pattern = '_Sites.csv$', full.names = T)
tables <- lapply(files, read.csv, header = TRUE, stringsAsFactors = F)
combined.df <- do.call(rbind , tables)
write.csv(combined.df, paste0(sensorRootDir, '/SensorInfo/AllSites.csv'), row.names = F, quote = F)


# Merge the individual 'sensorsToUse' csvs
files  <- list.files(paste0(sensorRootDir, '/SensorInfo'), pattern = '_SensorsToUse.csv$', full.names = T)
tables <- lapply(files, read.csv, header = TRUE, stringsAsFactors = F)
combined.df <- do.call(rbind , tables)
write.csv(combined.df, paste0(sensorRootDir, '/SensorInfo/AllSensors.csv'), row.names = F, quote = F)
vcd(combined.df)



##### Generate a password
makeRandomString(5)



#find which columns don't match
t <- rbind(tables[[1]], tables[[4]])
vcd(t)
n1 <- names(tables[[1]])
n4 <- names(tables[[4]])
which(n1 != n4)

vcd(n4)
