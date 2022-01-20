library(jsonlite)
library(dplyr)


# get the data -----

dat0 <- fromJSON('https://services.arcgis.com/g1fRTDLeMgspWrYp/arcgis/rest/services/SAMHD_DailySurveillance_Data_Public/FeatureServer/0/query?where=1%3D1&outFields=*&returnGeometry=false&outSR=4326&f=json')

dat1 <- dat0$features$attributes %>%
  subset(!is.na(total_case_cumulative)) %>%
  mutate(reporting_date = as.POSIXct(reporting_date/1000, origin = "1970-01-01"))


# alternatively -----

dat0x <- fromJSON("https://opendata.arcgis.com/datasets/169c6f6f455f48cea585f3624d11d393_0.geojson")

dat1x <- dat0x$features$properties %>%
  subset(!is.na(total_case_cumulative))





