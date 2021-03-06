# 12 Movilidad Google

# Leer Datos Mobility Google

# Google - bajar archivos movilidad

library(conflicted)
library(lubridate)
library(dplyr)
library(stringr)
library(tidyr)
# library(DataExplorer) # optional
library(imputeTS)
library(TSstudio)

conflict_prefer("wday", "lubridate")
conflict_prefer("year", "lubridate")
conflict_prefer("month", "lubridate")
conflict_prefer("day", "lubridate")
conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")

# https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip

fecha_hoy <- today()

ymd_str <-
  function(fecha)
    paste0(str_pad(year(fecha),  4, pad = "0"),
           str_pad(month(fecha), 2, pad = "0"),
           str_pad(day(fecha),   2, pad = "0"))


url_base <-
  "https://www.gstatic.com/covid19/mobility/"

fn_base <- "Region_Mobility_Report_CSVs"
fn_zip  <- paste0(fn_base,".zip")

# dest_file  <- paste0("data/", fn_zip)
dest_file <- file.path("data", fn_zip)

# dest_file2 <- paste0("data/", ymd_str(fecha_hoy),"-",fn_zip)
dest_file2 <- file.path("data",paste0(ymd_str(fecha_hoy),"-",fn_zip) )

try(download.file(
  paste0(url_base, fn_zip),
  destfile = dest_file2,
  method = 'curl',
  quite = TRUE
))
# TODO:  test the result fo download.file > is(object, "try-error")

if (file.size(dest_file2) > 800) {
  # 783 in windows
  cat("\n\n", as.character(Sys.time()), "Downloading ---> ", fn_zip)
  try(download.file(
    paste0(url_base, fn_zip),
    destfile = dest_file,
    method = 'curl',
    quite = TRUE
  ))
  cat(" - done!")
}


# unzip 2022_US_Region_Mobility_Report.csv

fn_csv <- "2022_US_Region_Mobility_Report.csv"
outDir <- file.path("data")
unzip(dest_file, files = "2022_US_Region_Mobility_Report.csv", exdir=outDir)

get_mobility <- function(csv_file = fn_csv) {
  read.csv(file.path("data" , csv_file),
           fileEncoding = "UTF-8")  %>%
    filter(sub_region_1 == "Texas") %>%
    filter(sub_region_2 != "") %>%
    mutate(
      date = as.Date(date),
      country = country_region_code,
      state   = sub_region_1,
      county  = sub_region_2,
      retail      = retail_and_recreation_percent_change_from_baseline,
      grocery     = grocery_and_pharmacy_percent_change_from_baseline,
      parks       = parks_percent_change_from_baseline,
      transit     = transit_stations_percent_change_from_baseline,
      workplaces  = workplaces_percent_change_from_baseline,
      residential = residential_percent_change_from_baseline
    ) %>%
    select(date, county, retail, parks, transit, workplaces, residential) -> mobility
  mobility
}

mobility_2022 <- get_mobility()


# unzip 2021_US_Region_Mobility_Report.csv

fn_csv <- "2021_US_Region_Mobility_Report.csv"
outDir <- file.path("data")
unzip(dest_file, files = "2021_US_Region_Mobility_Report.csv", exdir=outDir)

mobility_2021 <- get_mobility()


# unzip 2020_US_Region_Mobility_Report.csv

fn_csv <- "2020_US_Region_Mobility_Report.csv"
outDir <- file.path("data")
unzip(dest_file, files = "2020_US_Region_Mobility_Report.csv", exdir=outDir)

mobility_2020 <- get_mobility()

mobility_all <- rbind(mobility_2020, mobility_2021, mobility_2022) %>%
  pivot_wider(
    names_from = county,
    values_from = c(retail, parks, transit, workplaces, residential)
  ) %>%
  mutate(date = as.POSIXct.Date(date))


# TODO: preprocess - missing - interpolate


rio::export(mobility_all,
            file.path("data", "mobility_cached_data.tsv"))

conflict_prefer("layout", "plotly")

# Get ride of many missing values ---
mobility_tx <- mobility_all %>%
  select_if(colSums(!is.na(.)) > nrow(mobility_all) * 0.80)

# TODO: imputate
# ts_plot(mobility_tx, slider = T)
mobility_tx <- imputeTS::na_interpolation(mobility_tx)
# ts_plot(mobility_tx, type = "multiple")


mobility_bx <- mobility_tx %>%
  mutate(date = as.Date(date)) %>%
  select(date, contains("Bexar")) %>%
  arrange(date)

# ts_plot(mobility_bx, type = "multiple")
mobility_bx <- imputeTS::na_interpolation(mobility_bx)
bx_plot <- ts_plot(mobility_bx, slider = TRUE)

# Explore the data ---

# plot_str(mobility_tx)

# plot_prcomp(na.omit(mobility_tx), variance_cap = 0.9, ncol = 8L)

# mobility_tx %>%
#   create_report(
#     output_format = html_document(
#       toc = TRUE,
#       toc_depth = 6,
#       theme = "yeti"
#     ),
#     output_file = "mobility_in_texas.html",
#     report_title = "Mobility in Texas",
#     y = NULL
#   )
