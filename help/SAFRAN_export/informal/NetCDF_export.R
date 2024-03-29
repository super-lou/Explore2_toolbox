# Copyright 2021-2023 Louis Héraut (louis.heraut@inrae.fr)*1,
#                     Éric Sauquet (eric.sauquet@inrae.fr)*1
#
# *1   INRAE, France
#
# This file is part of Explore2 R toolbox.
#
# Explore2 R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Explore2 R toolbox is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


## 0. LIBRARY ________________________________________________________
if (!require (remotes)) install.packages("remotes")
if (!require (NCf)) remotes::install_github("super-lou/NCf")


## 1. INITIALISATION _________________________________________________
initialise_NCf()


## 2. TITLE __________________________________________________________
NCf$title.01.title = "MODEL_20221205"


## 3. GLOBAL ATTRIBUTS _______________________________________________
NCf$global.01.data_type = "diagnostic"
NCf$global.02.contact = "@"


## 4. DIMENSIONS _____________________________________________________
### 4.1. Time ________________________________________________________
date_de_debut = "2000-01-01"
date_de_fin = "2000-01-31"
fuseau_horaire = "UTC"
pas_de_temps = "days"

from = as.POSIXct(date_de_debut, tz=fuseau_horaire)
to = as.POSIXct(date_de_fin, tz=fuseau_horaire)
origin = as.POSIXct("1950-01-01", tz=fuseau_horaire)
units = paste0(pas_de_temps, " since ", origin)
time = seq.POSIXt(from=from, to=to, by=pas_de_temps)
time = as.numeric(time - origin)

NCf$time.name = "time"
NCf$time.value = time
NCf$time.01.standard_name = "time"
NCf$time.02.units = units

### 4.2. Station _____________________________________________________
NCf$station.name = "station"
NCf$station.value = 1:3

NCf$code_hydro.name = "code_hydro"
NCf$code_hydro.dimension = "station, code_hydro_strlen"
NCf$code_hydro.precision = "char"
NCf$code_hydro.value = c("AAAAAAAA", "BBBBBBBB", "CCCCCCCC")
NCf$code_hydro.01.standard_name = "code_hydro"
NCf$code_hydro_strlen.name = "code_hydro_strlen"
NCf$code_hydro_strlen.value = 1:max(nchar(NCf$code_hydro.value))
NCf$code_hydro_strlen.is_nchar_dimension = TRUE


## 5. VARIABLES ______________________________________________________
### 5.1. Debit _______________________________________________________
NCf$Q.name = "Q"
NCf$Q.dimension = "station, time"
NCf$Q.precision = "float"
NCf$Q.value = matrix(
    data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
               digits=2),
    ncol=length(NCf$time.value))
NCf$Q.01.standard_name = "debit"
NCf$Q.02.units = "m3.s-1"
NCf$Q.03.missing_value = NaN

### 5.2. Surface _____________________________________________________
NCf$surface_model.name = "surface_model"
NCf$surface_model.dimension = "station"
NCf$surface_model.precision = "float"
NCf$surface_model.value = round(x=runif(length(NCf$station.value)),
                                digits=2)
NCf$surface_model.01.standard_name = "surface dans le monde du modèle"
NCf$surface_model.02.units = "km2"
NCf$surface_model.03.missing_value = NaN

### 5.3. Temperature _________________________________________________
NCf$T.name = "T"
NCf$T.dimension = "station, time"
NCf$T.precision = "float"
NCf$T.value = matrix(
    data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
               digits=2),
    ncol=length(NCf$time.value))
NCf$T.01.standard_name = "temperature"
NCf$T.02.units = "°C"
NCf$T.03.missing_value = NaN

### 5.4. Évapotranspiration de référence _____________________________
NCf$ET0.name = "ET0"
NCf$ET0.dimension = "station, time"
NCf$ET0.precision = "float"
NCf$ET0.value = matrix(
    data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
               digits=2),
    ncol=length(NCf$time.value))
NCf$ET0.01.standard_name = "Évapotranspiration de référence"
NCf$ET0.02.units = "mm"
NCf$ET0.03.missing_value = NaN

### 5.5. Précipitations liquides _____________________________________
NCf$Rl.name = "Rl"
NCf$Rl.dimension = "station, time"
NCf$Rl.precision = "float"
NCf$Rl.value = matrix(
    data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
    ncol=length(NCf$time.value))
NCf$Rl.01.standard_name = "Précipitations liquides"
NCf$Rl.02.units = "mm"
NCf$Rl.03.missing_value = NaN

### 5.6. Précipitations solides ______________________________________
NCf$Rs.name = "Rs"
NCf$Rs.dimension = "station, time"
NCf$Rs.precision = "float"
NCf$Rs.value = matrix(
    data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
               digits=2),
    ncol=length(NCf$time.value))
NCf$Rl.01.standard_name = "Précipitations solides"
NCf$Rl.02.units = "mm"
NCf$Rl.03.missing_value = NaN

### 5.7. Précipitations totales ______________________________________
NCf$R.name = "R"
NCf$R.dimension = "station, time"
NCf$R.precision = "float"
NCf$R.value = matrix(
    data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
               digits=2),
    ncol=length(NCf$time.value))
NCf$R.01.standard_name = "Précipitations totales"
NCf$R.02.units = "mm"
NCf$R.03.missing_value = NaN


## 6. SAVING _________________________________________________________
generate_NCf(out_dir="./")


## 7. READING ________________________________________________________
NetCDF_path = file.path("MODEL_20221205.nc")

NCdata = ncdf4::nc_open(NetCDF_path)    
Date = as.Date(ncdf4::ncvar_get(NCdata, "time"),
               origin=
                   as.Date(stringr::str_extract(
                                        ncdf4::ncatt_get(NCdata,
                                                         "time")$units,
                                        "[0-9]+-[0-9]+-[0-9]+")))
CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
QRaw = ncdf4::ncvar_get(NCdata, "Q")
ncdf4::nc_close(NCdata)
