
currentUser <- ''
currentPwd <- ''

#suppressWarnings( auth <- read.csv(paste0(sensorRootDir, '/ConfigFiles/logins.csv')))
#suppressWarnings( usrs <- read.csv(paste0(sensorRootDir, '/ConfigFiles/users.csv')))
#suppressWarnings( grps <- read.csv(paste0(sensorRootDir, '/ConfigFiles/groups.csv')))




smipsLogin <- function(usr='Public', pwd='Public'){

  idRec <- auth[auth$usr == usr, ]
  if(nrow(idRec) > 0){
      cusr <- as.character(idRec$usr[1])
      cpwd <- as.character(idRec$pwd[1])
      caccess <- as.character(idRec$access[1])
      aList <- str_split(caccess, ';')


      if(pwd == cpwd){

        currentUser <- cusr
        currentPwd <- cpwd

        return(TRUE)

      }else{
        return(FALSE)
      }
  }else{
    return(FALSE)
  }

}


#getAuthorisedSensors(usr = 'SoilWaterApp', pwd = 'rLR4ArUomkODEpAgaDae4Ak')

getAuthorisedSensors <- function(usr='Public', pwd='Public'){

  if(usr=='Public'){
    #avail <- sensorInfo[sensorInfo$Access == 'Public',]

    sql <- "SELECT * FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID WHERE sites.Access = 'Public'"
    res <- dbSendQuery(DBCon, sql)
    avail <- dbFetch(res)
    dbClearResult(res)


    return(avail)
  }else{

    # idRec <- usrs[usrs$usrID == usr, ]
    # if(nrow(idRec) != 1){stop('Incorrect user name or password - username actually')}

    sql <- paste0("SELECT * FROM AuthUsers WHERE usrID = '", usr, "'")
    res <- dbSendQuery(DBCon, sql)
    idRec <- dbFetch(res)
    dbClearResult(res)
    if(nrow(idRec) != 1){stop('Incorrect user name or password - username actually')}

    cusr <- as.character(idRec$usrID[1])
    cpwd <- as.character(idRec$Pwd[1])
    cgrp <- as.character(idRec$GroupName[1])

    # accessRec <- grps[grps$Group == cgrp, ]
    # caccess <- as.character(accessRec$access[1])
    # accessList <- as.vector(str_split(caccess, ';'))

    sql <- paste0("SELECT * FROM AuthAccess WHERE GroupName = '", cgrp, "'")
    res <- dbSendQuery(DBCon, sql)
    accessRecs <- dbFetch(res)
    dbClearResult(res)
    accessList <- accessRecs$access

    if(pwd == cpwd){

      if(usr == 'Admin'){
        sql <- "SELECT * FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID"
        res <- dbSendQuery(DBCon, sql)
        sensorInfo <- dbFetch(res)
        dbClearResult(res)
        print("Admin")

        return(sensorInfo)
      #}else if(caccess == 'All'){
      }else if('All' %in% accessList){

        sql <- "SELECT * FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID"
        res <- dbSendQuery(DBCon, sql)
        sensorInfo <- dbFetch(res)
        dbClearResult(res)
        print("ALL")
        return(sensorInfo)
      }
      else {
        #avail <- sensorInfo[sensorInfo$Access == 'Public' | (sensorInfo$Access == 'Restricted' & sensorInfo$Provider %in% accessList[[1]]),]

        sql <- paste0("SELECT * FROM Sites INNER JOIN Sensors ON Sites.SiteID = Sensors.SiteID
        WHERE Access == 'Public' or ( Access == 'Restricted' and SensorGroup IN ( SELECT access FROM AuthAccess WHERE GroupName = '", cgrp, "'))")
        res <- dbSendQuery(DBCon, sql)
        avail <- dbFetch(res)
        print(head(avail))


        return(avail)
      }
       stop('Login failed')
    }
    else{
      stop('Incorrect user name or password')
    }
    stop('Login failed')
  }
}



getAuthorisedSensors_Old <- function(usr='Public', pwd='Public'){


  idRec <- auth[auth$usr == usr, ]
  if(nrow(idRec) != 1){stop('Incorrect user name or password')}
  cusr <- as.character(idRec$usr[1])
  cpwd <- as.character(idRec$pwd[1])
  caccess <- as.character(idRec$access[1])
  accessList <- as.vector(str_split(caccess, ';'))

  if(pwd == cpwd){

        if(idRec$usr=='Public'){
            avail <- sensorInfo[sensorInfo$Access == 'Public',]
            return(avail)
        }else if(idRec$usr=='Admin'){
          avail <- sensorInfo
          #print(unique(sensorInfo$Provider))
          return(avail)
        }else {
            #avail <- sensorInfo[sensorInfo$Access == 'Public' | sensorInfo$Access == 'Restricted' | sensorInfo$Provider %in% accessList[[1]],]
          avail <- sensorInfo[sensorInfo$Access == 'Public' | (sensorInfo$Access == 'Restricted' & sensorInfo$Provider %in% accessList[[1]]),]
           return(avail)
        }
   # stop('Login failed')
  }
  else{
    stop('Incorrect user name or password')
  }
  stop('Login failed')
}


makeRandomString <- function(n=1)
{
  lenght = sample(c(20:40))
  randomString <- c(1:n)
  for (i in 1:n)
  {
    randomString[i] <- paste(sample(c(0:9, letters, LETTERS),lenght, replace=TRUE),collapse="")
  }
  return(randomString)
}





