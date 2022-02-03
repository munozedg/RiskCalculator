created_mins <- function(myfilename, units = "mins") {
  # calcula la antiguedad de un archivo en minutos
  hora_actual <- as.POSIXct(Sys.time())
  if (file.exists(myfilename)) {
    hora_creado <- as.POSIXct( file.info(myfilename)$ctime )
    creado_hace_mins <- difftime(hora_actual, hora_creado, units = units)
  } else {
    creado_hace_mins <- difftime(hora_actual, hora_actual, units = units)
  }
  creado_hace_mins
}
