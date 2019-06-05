providerInfo = list(provider = c('SILO'),
                    backEnd = c('SILO'),
                    server = c('http://www.longpaddock.qld.gov.au/cgi-bin/silo/'),
                    org = c('Queensland Department of Environment and Science (DES)'),
                    usr = c('CSIROESB15'),
                    pwd = c('DISKW8026'),
                    access = c('Public'),
                    contact = c('Long Paddock'),
                    email = c('longpaddock@qld.gov.au'),
                    orgURL = c('https://www.longpaddock.qld.gov.au/'))

generateSiteInfo_SILO(providerInfo = providerInfo, rootDir = sensorRootDir)

generateSensorInfo_SILO(providerInfo = providerInfo, rootDir = sensorRootDir)