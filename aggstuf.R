

ts2 <- outts

dt <- index(first(ts2))
zd <- str_split(as.character(dt), ' ')[[1]][1]


zd <- '2018-08-01'
midnight <- strptime(paste0(zd, 'T00:00:88'), "%Y-%m-%dT%H:%M:%S")
dif <- as.numeric(difftime(dt,midnight,  units = "secs"))


index(outts)
index(ts2) <- index(outts) - (dif)

index(ts2)

lastday <- index(last(ts2))
time(ts2["2017-05-29"])
days <- c("2017-05-03","2017-05-23")

ends <- endpoints(ts2,aggPeriod,1)
outTS <- period.apply(ts2,ends ,cSum)

ends2 <- ends[1:length(ends)-1]



index(outTS) <- index(outTS) + (dif)
index(outTS)


head(ExcludeDates(ts2, exclude = c("2017-05-29")))

make.index.unique(outTS,drop=TRUE)


period.apply(outts, endpoints(outts, "hours", 24), sum)


outts[paste0(startDate,'/','2017-05-27T17:17:00'),]


sample.xts <- xts(1:6, as.POSIXct(c("2009-09-22 01:43:30",
                                    "2009-10-01 03:50:30", "2009-10-01 08:45:00", "2009-10-01 09:48:15",
                                    "2009-11-11 10:30:30", "2009-11-11 11:12:45")))
# align index into regular (e.g. 3-hour) blocks
aligned.xts <- align.time(sample.xts, n=60)
# apply your function to each block
count <- period.apply(aligned.xts, endpoints(aligned.xts, "hours", 24), length)
# create an empty xts object with the desired regular index
empty.xts <- xts(, seq(start(aligned.xts), end(aligned.xts), by="3 hours"))
# merge the counts with the empty object
head(out1 <- merge(empty.xts, count))





sd <- as.POSIXct(startDate, format = "%Y-%m-%dT%H:%M:%S")
ed <- as.POSIXct(endDate, format = "%Y-%m-%dT%H:%M:%S")
dif <- as.numeric(difftime(endDate, startDate,  units = "days")) + 1

d1 <-as.POSIXlt(startDate, format = "%Y-%m-%dT%H:%M:%S" )
dts <- xts(NULL , seq(sd, ed, by="24 hours"))
for (i in 1:dif) {
    d2 <- d1 +  24*60*60
    p <- outts[paste0(d1,'/',d2),]
    dts[d1] <- sum(p)
    d1 <- d2
}

indexFormat(dts) <- "%Y-%m-%dT%H:%M:%S"









f_add<- function(x,y){ x + y }
f_subtract<- function(x,y){ x - y }
f_multi<- function(x,y){ x * y }

doAggregation<- function(FUN, x, y){ FUN(x , y)}

operation(f_add, 9,2)
#> [1] 11
operation(f_subtract, 17,5)
#> [1] 12
operation(f_multi,6,8)
#> [1] 48








doAggregation<- function(FUN, x, y){ FUN(x , y)}

doAgg(outts, 'day', cSum)

startDate <- '2015-05-27T09:00:00'
endDate <- '2017-05-29T18:00:00'

start(outts)

df <- read.csv('c:/temp/outtsTest.csv')
ts <- xts(df[,-1], order.by=as.Date(df$DateTime,  format = "%d/%m/%Y %H:%M"))
indexFormat(ts) <- "%Y-%m-%dT%H:%M:%S"

saveRDS(outts2, 'c:/temp/outtsTest.rds')
ts <- readRDS('c:/temp/outtsTest.rds')

agts <- doAgg(ts, agg='weeks', FUN=cSum, startDate = startDate, endDate = endDate)


outTS <- resampleTS(ts, timeSteps$days, FeatureAggTypes[streams$DataType][1], startDate=startDate, endDate = endDate)




saveRDS(ndf, 'c:/temp/ndf.rds')











