



getData_SenFedStore <- function(sid, datatype, sensorID, sdate, edate){

   con <- dbConnect(RSQLite::SQLite(), senFedDbPath, flags = SQLITE_RO)

#   sql <- "SELECT datetime(datetime(datastore.dt, 'unixepoch')) as dt, datastore.Value
# FROM sensors INNER JOIN datastore ON sensors.sensID = datastore.sensorID
#   WHERE (((sensors.sid)='m1') AND ((sensors.dataType)='Soil-Moisture') and  datetime(dt, 'unixepoch')
#   between '2001-12-01 00:00:00' and '2001-12-02 04:00:00');"


  sql <- paste0("SELECT datetime(datetime(datastore.dt, 'unixepoch')) as dt, datastore.Value
  FROM sensors INNER JOIN datastore ON sensors.sensID = datastore.sensorID
  WHERE sensors.sid='",sid,"' AND sensors.dataType='",datatype,"'
  and datastore.sensorID='", sensorID, "' and datetime(dt, 'unixepoch')
  between '",sdate,"' and '",edate,"'
  ORDER BY datastore.dt;")

  print(sql)

  res <- dbSendQuery(con, sql)
  df <- dbFetch(res)
  #df

  dbClearResult(res)
  dbDisconnect(con)

  return(df)

}
