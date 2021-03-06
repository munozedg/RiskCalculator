library(here)
library(dplyr)
library(jsonlite)
library(ggplot2)
library(rio)
#install_formats()
library(plotly)
library(tidyr)

library(DT)
library(gt)
library(gtExtras)

require(devtools)
# install_github('ramnathv/rCharts')
# install_github("jthomasmock/gtExtras")
# remotes::install_github("jthomasmock/gtExtras")


source(file.path("functions", "modif_mins.R"))

if (!dir.exists(file.path("data"))) dir.create(file.path("data"))

url_json  <- 'https://services.arcgis.com/g1fRTDLeMgspWrYp/arcgis/rest/services/SAMHD_DailySurveillance_Data_Public/FeatureServer/0/query?where=1%3D1&outFields=*&returnGeometry=false&outSR=4326&f=json'
url_json2 <- 'https://opendata.arcgis.com/datasets/169c6f6f455f48cea585f3624d11d393_0.geojson'

fn_cached_data <- "cached_data.tsv"

# get the data -----

if (!file.exists( file.path("data", fn_cached_data) )) {
  dat0 <- fromJSON(url_json)
  dat1 <- dat0$features$attributes %>%
    subset(!is.na(total_case_cumulative)) %>%
    mutate(reporting_date = as.POSIXct(reporting_date / 1000, origin = "1970-01-01"))
  rio::export(dat1, file.path("data", fn_cached_data))
} else {
  dat1 <- rio::import(file.path("data", fn_cached_data))
}


# TODO: merge this code into lines 19-27

MINS_OLD <- modif_mins( here("data", fn_cached_data) )
# cat("Last update: ", round(MINS_OLD), "minutes ago.\n")

if (MINS_OLD > 480 || MINS_OLD < 0) {

  dat0 <- fromJSON(url_json)
  dat1 <- dat0$features$attributes %>%
    subset(!is.na(total_case_cumulative)) %>%
    mutate(reporting_date = as.POSIXct(reporting_date / 1000, origin = "1970-01-01"))
  rio::export(dat1, file.path("data", fn_cached_data) )

} else {

  dat1 <- rio::import( file.path("data", fn_cached_data) )

}

gt_spark_table <- dat1 %>%
  arrange(reporting_date) %>%
  pivot_longer(any_of(colnames(dat1)[-(1:3)])) %>%
  group_by(name) %>%
  summarize(Median = median(value, na.rm = T),
            SD = sd(value, na.rm = T),
            across(.fns = ~list(na.omit(.x)))) %>%
  mutate(histogram = value, density = value) %>%
  rename(sparkline = value) %>%
  gt() %>%
  cols_hide((c("globalid", "objectid","reporting_date"))) %>%
  gt_sparkline(sparkline, type = "sparkline", same_limit = F) %>%
  gt_sparkline(histogram, type = "histogram", same_limit = F) %>%
  gt_sparkline(density,   type = "density",   same_limit = F)

# gt_spark_table


# make some projections next week

source("10-get-google-mobility.R")


