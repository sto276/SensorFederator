
currentUser <- ''
currentPwd <- ''

suppressWarnings( auth <- read.csv(paste0(sensorRootDir, '/ConfigFiles/logins.csv')))
suppressWarnings( usrs <- read.csv(paste0(sensorRootDir, '/ConfigFiles/users.csv')))
suppressWarnings( grps <- read.csv(paste0(sensorRootDir, '/ConfigFiles/groups.csv')))




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

  if(usr=='Public'){
    avail <- sensorInfo[sensorInfo$Access == 'Public',]
    return(avail)
  }else{

    idRec <- usrs[usrs$usrID == usr, ]
    if(nrow(idRec) != 1){stop('Incorrect user name or password')}

    cusr <- as.character(idRec$usrID[1])
    cpwd <- as.character(idRec$Key[1])
    cgrp <- as.character(idRec$Group[1])

    accessRec <- grps[grps$Group == cgrp, ]
    caccess <- as.character(accessRec$access[1])
    accessList <- as.vector(str_split(caccess, ';'))

    if(pwd == cpwd){

      if(usr == 'Admin'){
        return(sensorInfo)
      }else if(caccess == 'All'){
        return(sensorInfo)
      }
      else {
        #avail <- sensorInfo[sensorInfo$Access == 'Public' | sensorInfo$Access == 'Restricted' | sensorInfo$Provider %in% accessList[[1]],]
        avail <- sensorInfo[sensorInfo$Access == 'Public' | (sensorInfo$Access == 'Restricted' & sensorInfo$Provider %in% accessList[[1]]),]
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





