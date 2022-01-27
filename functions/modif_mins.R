modif_mins <- function(myfilename, units = "mins") {
  # clac how old is this file in mins
  hora_actual <- as.POSIXct(Sys.time())
  if (file.exists(myfilename)) {
    hora_modif <- as.POSIXct( file.info(myfilename)$mtime )
    modif_hace_mins <- difftime(hora_actual, hora_modif, units = units)
  } else {
    modif_hace_mins <- -1 # difftime(hora_actual, hora_actual, units = units)
  }
  modif_hace_mins
}

# TIP: as.Date(file.info('cached_data.tsv')$ctime) < Sys.Date()
