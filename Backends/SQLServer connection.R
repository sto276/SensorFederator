library(odbc)
library(RODBC)


con <- odbcDriverConnect("Driver={SQL Server};Server=localhost\\SQLEXPRESS;Database=ApSoil;Trusted_Connection=Yes")


d1 <- sqlFetch(con, "View_Layer1Water")
