library(RSQLite)
library(readxl)
library(stringr)


#  populate sites table in the DB
dbPath <- "C:/Temp/ozNetDB.db"
con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
sitesDF <- read.csv('C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/BackendAdmin/OzNet/sites.csv', stringsAsFactors = F)
rs <- data.frame(sid=sitesDF$code, sitename=sitesDF$siteName, latitude=sitesDF$lats, longitude= sitesDF$lons, elevation=sitesDF$elevs, description='' )
dbWriteTable(con, 'sites', rs, append = T)
dbDisconnect(con)


# Explore the file structure

outDir <- 'c:/temp'
#region <- 'Adelong'
region <- 'Kyeamba'
region <- 'Murrumbidgee'
region <- 'Yanco'

fls <- list.files(paste0(inDir, '/', region), recursive = T, full.names = T)
cat('', file = paste0(outDir, '/', region, '_fields.csv'))
for (i in 1:length(fls)) {

  f <- fls[i]
  network <- basename(dirname(f))
  fname <- basename(f)
  tib <- readxl::read_xls(f, 1,  skip=1 )
  df <- as.data.frame(tib[-1,])
  cols <- paste0( colnames(df), collapse = ", ")
  cat(network,', ', fname,  ', ', cols, '\n', file = paste0(outDir, '/', region, '_fields.csv'), append = T)
  print(paste0(i , ' of ', length(fls)))
}





# process the files

region <- 'Adelong'
region <- 'Kyeamba'
region <- 'Murrumbidgee'
region <- 'Yanco'

inDir <- 'C:/Temp/ozNet'
isActive <- 'T'

dbPath <- "C:/Temp/ozNetDB.db"

cat('SiteID,SiteName,SensorGroup,Backend,Access,Usr,Pwd,Latitude,Longitude,Owner,Contact,ProviderURL,Description,ServerName\n', file=paste0(inDir, '/', region, '_Sites.csv'))




cat('SiteID,Active,SensorID,SensorName,StartDate,EndDate,DataType,UpperDepth,LowerDepth,Calibrated,Units\n', file=paste0(inDir, '/', region, '_Sensors.csv'))
con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
siteCodes <- read.csv(paste0('C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/BackendAdmin/OzNet/sites.csv'))


dirs <- list.dirs(paste0(inDir, '/', region), recursive = F)
for (k in 1:length(dirs)) {

  dir <- dirs[k]
  siteName <- basename(dir)
  siteCode <- siteCodes[siteCodes$siteName == siteName, 3]
  lon <- siteCodes[siteCodes$siteName == siteName, 4]
  lat <- siteCodes[siteCodes$siteName == siteName, 5]

   str <- paste0('OzNet_', siteCode, ',', siteName, ',OzNet,SenFedStore,Public,OzN,OzN,', lat, ',', lon, ',Monash University,sandra.monerris-belda(at)monash.edu,http://www.oznet.org.au/,An Australian monitoring network for soil moisture and micrometeorology,http://esoil.io\n')
   cat(str, file=paste0(inDir, '/', region, '_Sites.csv'), append = T)

  cat('\nProcessing ', siteName, '\n')

    fls <- list.files(dir, '.xls', full.names = T, recursive = F)

    if(length(fls) > 0){

         for (i in 1:length(fls)) {
        # for (i in 1:1) {

            cat(i, ' ')
            f <- fls[i]
            network <- basename(dirname(f))
            fname <- basename(f)

            tibx <- readxl::read_xls(f, 1,  skip=1 )
            ctypes <- c('date', rep('numeric', ncol(tibx)-1))
            cns <- colnames(tibx)

            tib <- readxl::read_xls(f, 1, col_types = ctypes , skip=3 , col_names = F)
            colnames(tib) <- cns

            for (j in 2:ncol(tib)) {

              coln <- colnames(tib)[j]
              bits <- str_split(coln, ' ')

              sid <- paste0( siteCode)

              if(str_trim(str_to_lower(bits[[1]][1])) == 'temp' ){

                dBtype <- 'ST'
                senType <- 'Soil-Temperature'
                unts <- "Degrees Celcius"
                d <- as.numeric(str_trim(str_remove(bits[[1]][2], 'cm')))
                upD <- d
                lowD <- d

              }else if(str_trim(str_to_lower(bits[[1]][1])) == 'sm'){

                dBtype <- 'SM'
                senType <- 'Soil-Moisture'
                unts <- "Percent"
                d1 <- str_remove(bits[[1]][2], 'cm')
                d2 <- str_split(d1, '-')
                upD <- as.numeric(str_trim( d2[[1]][1]))
                lowD <- as.numeric(str_trim( d2[[1]][2]))

              }else if(str_trim(str_to_lower(bits[[1]][1])) == 'suction'){

                dBtype <- 'SS'
                senType <- 'Soil-Suction'
                unts <- "Percent"
                d <- as.numeric(str_trim(str_remove(bits[[1]][2], 'cm')))
                upD <- d
                lowD <- d
              }else if(str_trim(str_to_lower(bits[[1]][2])) == 'rainfall'){

                dBtype <- 'RF'
                senType <- 'Rainfall'
                unts <- "mm"
                upD <- 0
                lowD <- 0
              }

              senID <- paste0( 'Oz_', sid, '_', dBtype, '_',upD, '_',lowD)

               if(i==1){

                  sql1 <- paste0( "Insert into sensors ( sid, sensID, dataType, upperDepth, lowerDepth, units )
                                    values ('", sid, "', '",senID, "','",senType, "',", upD, ",", lowD, ",'", unts,"')")
                  res <- dbSendStatement(con, sql1)
                  dbGetRowsAffected(res)
                  dbClearResult(res)

                 cat('OzNet_', sid, ",TRUE,",senID,",",senID,  ", , ,",senType,",",upD,",", lowD,",TRUE,",unts,  "\n", sep = '', file=paste0(inDir, '/', region, '_Sensors.csv'), append = T)

               }

              xdf <- data.frame(tib[,c(1,j)])
              odf <- data.frame(sid='m1', dt=xdf$DATE.TIME, dtype=dBtype, sensorID=senID, vals=xdf[,2])
              colnames(odf) <- c('sid', 'dt', 'dtype', 'sensorID', 'Value')
              colnames(odf)
              dbWriteTable(con, 'datastore', odf, append = T)
            }


          }

    }

}




dbDisconnect(con)





con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
sql1 <- "Delete from datastore"
res <- dbSendStatement(con, sql1)
dbGetRowsAffected(res)
dbClearResult(res)

con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
sql1 <- "Delete from sensors"
res <- dbSendStatement(con, sql1)
dbGetRowsAffected(res)
dbClearResult(res)




###### load required data into the SensorFederator Backend DB  #########
fls <- list.files('C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/SensorInfo/OzNet', '_Sites.csv', full.names = T, recursive = F)

dbPath <- "C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/DB/SensorFederator.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
for (i in 1:length(fls)) {
  siteDF <- read.csv(fls[i])
  dbWriteTable(con, 'sites', siteDF, append = T)
}
dbDisconnect(con)


fls <- list.files('C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/SensorInfo/OzNet', '_Sensors.csv', full.names = T, recursive = F)

dbPath <- "C:/Users/sea084/Dropbox/RossRCode/Git/SensorFederator/DB/SensorFederator.sqlite"
con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)
for (i in 1:length(fls)) {
  siteDF <- read.csv(fls[i])
  dbWriteTable(con, 'sensors', siteDF, append = T)
}
dbDisconnect(con)

#######  end of sensorFed loding



con <- dbConnect(RSQLite::SQLite(), dbPath, flags = SQLITE_RW)

sql <- "select sid, datetime(datetime(dt, 'unixepoch')), dtype, sensorID, value
  from datastore
where datetime(dt, 'unixepoch')
between '2001-12-01 00:00:00' and '2001-12-02 04:00:00'
and sid = 'm1'
and sensorID = 'Temp 4cm'"
res <- dbSendQuery(con, sql)
df <- dbFetch(res)
dbClearResult(res)
dbDisconnect(con)




