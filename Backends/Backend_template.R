########################################################
#####                                            #######
#####  SensorFederation Data Adapter Workflow    #######
#####                                            #######
########################################################

# Author : Ross Searle
# Last Updated : 27/7/2018


#The info below sets out the steps you need to code to implement an 'Adapter' into the SensorFederation environment 
# The Cosmoz backend is a good simple example of implementing an 'Adapter' into the SensorFederation environment 

# in this workflow 'BackendName' refers to the name of the new Adapter you are creating


# Add Metadata  for sensors into the main config files using scripting specific to the situation. 2 shell functions are provided
# and should be coded as required to generate the metadata in the required format for the config files
# put this setup work in a file called 'BackendName_Admin.R for testing and dev puposes.

# First create a file called Backends/BackendName_Backend.R - this will be the main worker for your new Data Adapter

# use the providerInfo variable to supply static info to the generation functions
# : file = Backends/BackendName_Backend.R : function = generateSiteInfo_BackendName : variable = NA
# file is written to filename = Backends/BackendName_Sites.R
# : file = Backends/BackendName_Backend.R : function = generateSensorInfo_BackendName : variable = NA
# file is written to filename = Backends/BackendName_SensorsAll.R

# Next you can manually modify these files to remove any unwanted sensors etc
# The final edited sensors file should be called 'BackendName_SensorsToUse.csv

# There is code then to stitch all these individual provider files into the required main config files
# script name = Backends/AppAdminTasks.R : Lines =3-14


# Add the 'backend' section in to main flow control  statement  : file = Backends/Backends.R : function = getSensorData : variable = NA
# Add the 'backend' name value into the list of known providers : file = Backends/Backend_Config.R : function = main : variable = knownBackends

# add  source(paste0(sensorRootDir, '/Backends/BackendName_Backend.R')) to Backend_Config.R

# add the following function to the '/Backends/Backends.R file

# function = getSensorData_Cosmoz <- function(streams, startDate = NULL, endDate = NULL, aggPeriod=timeSteps$day, numrecs=maxRecs ){

    # THis function formats the dates etc , generates the urls and then sends them of to be submitted asynchronously
#}

# Then add the following function to the  '/Backends/BackendName_Backends.R file

# getURLAsync_OutPost <- function(x){}

# Then add the following function to the  '/Backends/BackendName_Backends.R file

# getURLAsync_OutPost <-cosmoz_GenerateTimeSeries <- function(response, retType = 'df'){



######   That is it   ###########


##  The list of functions below is the minimum set of functions you will need in the '/Backends/BackendName_Backends.R file to make things work



generateSiteInfo_BackendName <- function(providerInfo, rootDir){
  # generates a csv file of required site metadata that is wrtten to Backends/BackendName_Sites.R
}

generateSensorInfo_BackendName <- function( providerInfo, rootDir){
  # generates a csv file of required site metadata that is wrtten to Backends/generateSensorInfo_BackendName
}

getURLAsync_BackendName <- function(x){
  
  # This function handles sending of asynch requests to the native API endpoints and waits for all responses to be returned
}


BackendName_GenerateTimeSeries <- function(response, retType = 'df'){
  
  # This function generates the xts or df return object from the native response from the API being queried
  
  # Basically return a 'Date', 'Value' key pair
  # Value is numeric
  # Date is  dtring with this format '2016-04-19 09:30:00'
}









