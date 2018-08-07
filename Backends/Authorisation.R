
currentUser <- ''
currentPwd <- ''

auth <- read.csv(paste0(sensorRootDir, '/ConfigFiles/logins.csv'))




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


getAuthorisedSensors <- function(usr='Public', pwd='Public'){

  
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
            avail <- sensorInfo[sensorInfo$Access == 'Public' | sensorInfo$Access == 'Restricted' | sensorInfo$Provider %in% accessList[[1]],]
            return(avail)
        }
   # stop('Login failed')
  }
  else{
    stop('Incorrect user name or password')
  }
  stop('Login failed')
}





