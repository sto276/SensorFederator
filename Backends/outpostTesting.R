library(RCurl)
library(jsonlite)
library(stringr)
library(httr)
library(XML)
library(xml2)
library(htmltidy)
library(zoo)
library(xts)
library(RCurl)
library(stringr)


myOpts <- curlOptions(connecttimeout = 2000, ssl.verifypeer = FALSE)



# use  a short time period as this data is huge
urlData <- 'https://www.outpostcentral.com/api/2.0/dataservice/mydata.aspx?userName=yoliver&password=export&dateFrom=1/Dec/2017%2000:00:00&dateTo=1/Dec/2017%2001:00:00'

dataXML <- getURL(urlData, .opts = myOpts , .encoding = 'UTF-8-BOM')

xmlObj=xmlParse(s2, useInternalNodes = TRUE)


s2 <- str_sub(dataXML, 4, nchar(dataXML))
str_sub(s2, 1, 100)
response2 <- substr(response, 2, nchar(response))


doc <- xmlRoot(xmlObj)
nsDefs <- xmlNamespaceDefinitions(doc)
ns <- structure(sapply(nsDefs, function(x) x$uri), names = names(nsDefs))

sites <-getNodeSet(doc, "//opdata:sites/opdata:site", ns)


for(i in 1:length(sites)){
  sn <- sites[i]
  
  siteName <- xpathSApply(doc ,"//opdata:sites/opdata:site/name", xmlValue, ns)[i]
  xpathSApply(doc ,paste0("//opdata:sites/opdata:site/name[text()='", siteName,"']/parent::opdata:site/opdata:inputs/opdata:input/name"), xmlValue, ns)
  
  name <- getNodeSet(sites[[i]], "name")[1]

nds <-  xpathSApply(doc,"//opdata:sites/opdata:site/name",xmlValue)[1]

nds <-  xpathSApply(doc,"//opdata:sites/opdata:site/name/parent::site/opdata:inputs/opdata:input", xmlValue, ns)


x <-  xpathSApply(nds,"//opdata:sites/opdata:site/name/opdat:inputs")[1]
  
  getNodeSet(sites[[i]], "//opdata:sites/opdata:site/name")
  
 
  
  
  
}[]

nodes[[1]]



xpathSApply (doc ,"//sites/site/name", xmlValue)

d <-xpathSApply (doc ,"//opdata:sites/opdata:site/name", xmlValue, ns)

doc[[1]][3][[1]][[1]]
doc[[1]][3][[1]][[1]]







cat(dataXML, file='c:/temp/outpost1.xml')

fileName='c:/temp/outpost1.xml'
con=file(fileName,open="r")
line=readLines(con)

download.file(urlData, 'c:/temp/out.xml')



foo <- GET(urlData)
has_bom(foo)
sb <- sans_bom(foo)




f <-paste(readLines(fileName), collapse="\n")
f <-readLines(fileName, fileEncoding = "UTF-8-BOM")

g <- str_replace_all(sb, '\n', '')

xmlObj=xmlParse(dataXML)
xmlObj=xmlParse(fileName, encoding='UTF-8-BOM')
doc <- xmlRoot(xmlObj)
xml_view(f)


nsDefs <- xmlNamespaceDefinitions(doc)
ns <- structure(sapply(nsDefs, function(x) x$uri), names = names(nsDefs))

xpathSApply (doc ,"//sites/site/name", xmlValue)

d <-xpathSApply (doc ,"//opdata:sites/opdata:site/opdata:name", xmlValue, ns)

doc[[1]][3][[1]][[1]]
doc[[1]][3][[1]][[1]]

n <- getNodeSet(doc, "opdata:sites", ns)


head(doc)
doc[1]
str(doc)


doc = xmlParse(system.file("exampleData", "tagnames.xml", package = "XML"))

els = getNodeSet(doc, "/doc//a[@status]")
sapply(els, function(el) xmlGetAttr(el, "status"))

# use of namespaces on an attribute.
getNodeSet(doc, "/doc//b[@x:status]", c(x = "http://www.omegahat.net"))
getNodeSet(doc, "/doc//b[@x:status='foo']", c(x = "http://www.omegahat.net"))

# Because we know the namespace definitions are on /doc/a
# we can compute them directly and use them.
nsDefs = xmlNamespaceDefinitions(getNodeSet(doc, "/doc/a")[[1]])
ns = structure(sapply(nsDefs, function(x) x$uri), names = names(nsDefs))
getNodeSet(doc, "/doc//b[@omegahat:status='foo']", ns)[[1]]



library(xml2)

doc <- read_xml(sb)
#peak at the namespaces
xml_ns(doc)

xml_find_all(doc,'/opdata:sites/opdata:site/opdata:name', xml_ns(doc))
xml_children(doc)
xml_length(doc)
xml_contents(doc)
xml_child(doc, 2)



doc[[1]][[1]][[1]]



l <- getNodeSet(doc, "/sites/site/name", ns)

getNodeSet(doc ,"/opdata:sites/opdata:site/opdata:name", xmlValue, namespaces = ns)


xpathSApply (doc ,"/data/sites/site/name", xmlValue, namespaces = ns)

xpathSApply (doc ,"//opdata:data/opdata:sites/opdata:site/opdata:name", xmlValue)
xpathSApply (doc ,"//sites/site/name", xmlValue, namespaces = ns)


getNodeSet(doc, "//div[@id]")




