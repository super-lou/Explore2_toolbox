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


#  _                             _        _     _          
# | | ___  ___  __ __ __ _  _ _ (_) __ _ | |__ | | ___  ___
# | |/ -_)(_-<  \ V // _` || '_|| |/ _` || '_ \| |/ -_)(_-<
# |_|\___|/__/   \_/ \__,_||_|  |_|\__,_||_.__/|_|\___|/__/ __________
# Les dimensions de la variable sont au même nombre que les axes
# spécifiés précédemment et sont définies de la même manière (nom et
# grandeur). L’ordre des indices souhaité dépend du type des
# dimensions : var (station, time)
#
# Le nom de la variable est typiquement un acronyme qui suit les
# références des tables MIP et auquel est associé un nom court ou long
# et une unité standard. Bien sûr il est identique au nom de la
# variable dans le nom du fichier.
#
#
# Paramètres :
#     standard_name : Un nom d’identification court de la variable
#
#         long_name : Un nom d’identification long de la variable
#
#             units : Spécifie l’unité de la variable
#
#         FillValue : Spécifie comment sont identifiés les valeurs
#                     manquantes
#
#     missing_value : Similaire
#
#      cell_methods : Fournit l’information concernant le calcul ou
#                     l’extraction de la variable


## 1. DEBIT __________________________________________________________
NCf$debit.name = "debit"
NCf$debit.dimension = "station, time"
NCf$debit.precision = "float"
NCf$debit.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$debit.01.standard_name = "debit"
NCf$debit.02.long_name = "debit modcou"
NCf$debit.03.units = "m3.s-1"
NCf$debit.04.missing_value = NaN
# Fournit l’information concernant le calcul ou l’extraction de la variable.
NCf$debit.05.cell_methods = "time:mean"
# Complément d’information sur l’extraction, le calcul de la variable
NCf$debit.06.comment = "source : ..."


## 2. PRÉCIPITATIONS _________________________________________________
### 2.1. Liquides _____________________________________________________
NCf$precipitations_liquides.name = "precipitations_liquides"
NCf$precipitations_liquides.dimension = "station, time"
NCf$precipitations_liquides.precision = "float"
NCf$precipitations_liquides.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$precipitations_liquides.01.standard_name = "precipitations liquides"
NCf$precipitations_liquides.02.long_name = "precipitations liquides modcou"
NCf$precipitations_liquides.03.units = "mm"
NCf$precipitations_liquides.04.missing_value = NaN
# Fournit l’information concernant le calcul ou l’extraction de la variable.
NCf$precipitations_liquides.05.cell_methods = "time:sum"
# Complément d’information sur l’extraction, le calcul de la variable
NCf$precipitations_liquides.06.comment = "source : ..."

### 2.2. Solides _____________________________________________________
NCf$precipitations_solides.name = "precipitations_solides"
NCf$precipitations_solides.dimension = "station, time"
NCf$precipitations_solides.precision = "float"
NCf$precipitations_solides.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$precipitations_solides.01.standard_name = "precipitations solides"
NCf$precipitations_solides.02.long_name = "precipitations solides modcou"
NCf$precipitations_solides.03.units = "mm"
NCf$precipitations_solides.04.missing_value = NaN
# Fournit l’information concernant le calcul ou l’extraction de la variable.
NCf$precipitations_solides.05.cell_methods = "time:sum"
# Complément d’information sur l’extraction, le calcul de la variable
NCf$precipitations_solides.06.comment = "source : ..."

### 2.3. Totales _____________________________________________________
NCf$precipitations_totales.name = "precipitations_totales"
NCf$precipitations_totales.dimension = "station, time"
NCf$precipitations_totales.precision = "float"
NCf$precipitations_totales.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$precipitations_totales.01.standard_name = "precipitations totales"
NCf$precipitations_totales.02.long_name = "precipitations totales modcou"
NCf$precipitations_totales.03.units = "mm"
NCf$precipitations_totales.04.missing_value = NaN
# Fournit l’information concernant le calcul ou l’extraction de la variable.
NCf$precipitations_totales.05.cell_methods = "time:sum"
# Complément d’information sur l’extraction, le calcul de la variable
NCf$precipitations_totales.06.comment = "source : ..."


## 3. TEMPÉRATURE ____________________________________________________
NCf$temperature.name = "temperature"
NCf$temperature.dimension = "station, time"
NCf$temperature.precision = "float"
NCf$temperature.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$temperature.01.standard_name = "temperature"
NCf$temperature.02.long_name = "temperature modcou"
NCf$temperature.03.units = "°C"
NCf$temperature.04.missing_value = NaN
# Fournit l’information concernant le calcul ou l’extraction de la variable.
NCf$temperature.05.cell_methods = "time:mean"
# Complément d’information sur l’extraction, le calcul de la variable
NCf$temperature.06.comment = "source : ..."


## 4. ÉVAPOTRANSPIRATION DE RÉFÉRENCE ________________________________
NCf$evapotranspiration_de_reference.name = "evapotranspiration_de_reference"
NCf$evapotranspiration_de_reference.dimension = "station, time"
NCf$evapotranspiration_de_reference.precision = "float"
NCf$evapotranspiration_de_reference.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$evapotranspiration_de_reference.01.standard_name = "evapotranspiration_de_reference"
NCf$evapotranspiration_de_reference.02.long_name = "evapotranspiration de reference modcou"
NCf$evapotranspiration_de_reference.03.units = "mm"
NCf$evapotranspiration_de_reference.04.missing_value = NaN
# Fournit l’information concernant le calcul ou l’extraction de la variable.
NCf$evapotranspiration_de_reference.05.cell_methods = "time:sum"
# Complément d’information sur l’extraction, le calcul de la variable
NCf$evapotranspiration_de_reference.06.comment = "source : ..."
