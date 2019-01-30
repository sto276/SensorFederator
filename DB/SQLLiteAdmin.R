install.packages("RSQLite")
library(RSQLite)
library(DBI)


dbPath <- "C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/DB/SensorFederator.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RO)

sql <- 'Delete from testing'
res <- dbSendQuery(con, sql)
df <- dbFetch(res)


dbListTables(con)
dbListFields(con, "Sites")
df <- dbReadTable(con, "Sites")
head(df)

dbDisconnect(con)


sql <- "SELECT Sites.SiteID, Sites.SiteName, Sites.Provider, Sites.Backend, Sites.Usr, Sites.Pwd, Sites.Latitude, Sites.Longitude, Sites.Owner, Sites.Contact, Sites.ProviderURL, Sites.Description, Sensors.Active, Sensors.Access, Sensors.SensorID, Sensors.SensorName, Sensors.StartDate, Sensors.EndDate, Sensors.DataType, Sensors.UpperDepth, Sensors.LowerDepth, Sensors.Calibrated, Sensors.Units
FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID;"
res <- dbSendQuery(con, sql)
df <- dbFetch(res)

sql <- "SELECT * FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID"
res <- dbSendQuery(con, sql)
df <- dbFetch(res)




dbListFields(con, "Sensors")
airport <- dbSendQuery(con, "SELECT * FROM Sites WHERE Backend = ? and Provider = ?")

dbBind(airport, list("Adcon", "Rain"))
dbFetch(airport)


cc <- 'SELECT SiteID, group_concat(distinct(DataType)) as SensorTypes FROM Sensors GROUP BY SiteID'
res <- dbSendQuery(con, cc)
df <- dbFetch(res)





sql1 <- "SELECT access
  FROM AuthAccess
WHERE GroupName = 'BOM'"
res <- dbSendQuery(con, sql1)
df <- dbFetch(res)

avail <- sensorInfo[sensorInfo$Access == 'Public' | (sensorInfo$Access == 'Restricted' & sensorInfo$Provider %in% accessList[[1]]),]

sql <- "SELECT * FROM Sites WHERE Provider IN ( SELECT access FROM AuthAccess WHERE GroupName = 'BOM')"

sql <- "SELECT * FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID
        WHERE Access == 'Public' or ( Access == 'Restricted' and Provider IN ( SELECT access FROM AuthAccess WHERE GroupName = 'BOM'))"
res <- dbSendQuery(con, sql)
df <- dbFetch(res)




df <- dbFetch(res)


result = tryCatch({

  dbPath <- "C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/DB/SensorFederator.sqlite"
  con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
  sql1 <- "Insert into appUsers ( usr, pwd) values ('d', 'b')"
  res <- dbSendStatement(con, sql1)
  dbGetRowsAffected(res)
}, warning = function(w) {
  warning-handler-code
}, error = function(e) {
  print('No go big fella')
}, finally = {
  dbClearResult(res)
}
)






library(RSQLite)
library(DBI)
library(bcrypt)


srID = 'ross.searle@csiro.au'
passwd = 'rossiscool'
usrID = 'a'
passwd = 'b'
#password_hash <- hashpw(passwd)

dbPath <- "C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/DB/SensorFederator.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)




sql1 <- "Insert into appUsers ( usr, pwd) values ('a', 'b')"




sql1 <- "Insert into appUsers ( usr, pwd) values ('a', 'b')"


sqlInsert <- paste0("Insert into appUsers ( usr, pwd) values ('h', '",  digest(md5Input, serialize=F) ,"')")
print(sqlInsert)
res <- dbSendStatement(con, sqlInsert)
dbGetRowsAffected(res)


sqlqry<- paste0("select usr, pwd from appUsers where usr = 'h'")

res <- dbSendQuery(con, sqlqry)
df <- dbFetch(res)

identical(df$pwd, digest('sdfe', serialize=F))



library(digest)
digest("foo", "md5", serialize = FALSE)

md5Input <- 'abc'

md5 <- digest(md5Input, serialize=F)
identical(md5, digest(md5Input, serialize=F))





isValidEmail <- function(x) {
  grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", as.character(x), ignore.case=TRUE)
}

isValidEmail("felix@nicebread.de")
isValidEmail("felix.123.honeyBunny@nicebread.lmu.de")
isValidEmail("felix@nicebread.de  ")
isValidEmail("    felix@nicebread.de")
isValidEmail("felix+batman@nicebread.de")
isValidEmail("felix@nicebread.office")

# invalid addresses
isValidEmail("felix@nicebread")
isValidEmail("felix@nicebread@de")
isValidEmail("felixnicebread.de")

isValidEmail("ross@somewhere")
isValidEmail("ross.searle@csiro.au")





