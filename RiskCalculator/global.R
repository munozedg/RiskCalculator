library(here)
library(dplyr)
library(jsonlite)
library(ggplot2)
library(rio)
#install_formats()
library(plotly)

source(here::here("RiskCalculator","functions", "modif_mins.R"))

if (!dir.exists(here::here("data"))) dir.create(here::here("data"))

url_json  <- 'https://services.arcgis.com/g1fRTDLeMgspWrYp/arcgis/rest/services/SAMHD_DailySurveillance_Data_Public/FeatureServer/0/query?where=1%3D1&outFields=*&returnGeometry=false&outSR=4326&f=json'
url_json2 <- 'https://opendata.arcgis.com/datasets/169c6f6f455f48cea585f3624d11d393_0.geojson'

fn_cached_data <- "cached_data.tsv"

# get the data -----

if (!file.exists( here::here("data", fn_cached_data) )) {
  dat0 <- fromJSON(url_json)
  dat1 <- dat0$features$attributes %>%
    subset(!is.na(total_case_cumulative)) %>%
    mutate(reporting_date = as.POSIXct(reporting_date / 1000, origin = "1970-01-01"))
  rio::export(dat1, here::here("data", fn_cached_data))
} else {
  dat1 <- rio::import(here::here("data", fn_cached_data))
}


# TODO: merge this code into lines 19-27

MINS_OLD <- modif_mins( here("data", fn_cached_data) )
# cat("Last update: ", round(MINS_OLD), "minutes ago.\n")

if (MINS_OLD > 480 || MINS_OLD < 0) {

  dat0 <- fromJSON(url_json)
  dat1 <- dat0$features$attributes %>%
    subset(!is.na(total_case_cumulative)) %>%
    mutate(reporting_date = as.POSIXct(reporting_date / 1000, origin = "1970-01-01"))
  rio::export(dat1, here::here("data", fn_cached_data) )

} else {

  dat1 <- rio::import( here::here("data", fn_cached_data) )

}
