library(RSQLite)
library(DBI)


dbPath <- "C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/DB/SensorFederator.sqlite"
#con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RO)

con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
fk_On <- 'PRAGMA foreign_keys = ON;'
dbExecute(con, fk_On)

sites <- read.csv('C:/Temp/db/Sites.csv', stringsAsFactors = F)
str(sites)
head(sites)
dbWriteTable(con, "sites", sites)

sensors <- read.csv('C:/Temp/db/Sensors.csv', stringsAsFactors = F)
str(sensors)
head(sensors)
dbWriteTable(con, "sensors", sensors, append=T)


