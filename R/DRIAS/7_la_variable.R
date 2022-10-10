# \\\
# Copyright 2022 Louis Héraut (louis.heraut@inrae.fr)*1
#
# *1   INRAE, France
#
# This file is part of Ex2D R package.
#
# Ex2D R package is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ex2D R package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ex2D R package.
# If not, see <https://www.gnu.org/licenses/>.
# ///


#  _           __   __            _        _     _      
# | |    __ _  \ \ / / __ _  _ _ (_) __ _ | |__ | | ___ 
# | |__ / _` |  \ V / / _` || '_|| |/ _` || '_ \| |/ -_)
# |____|\__,_|   \_/  \__,_||_|  |_|\__,_||_.__/|_|\___| _____________
# Les dimensions de la variable sont au même nombre que les axes
# spécifiés précédemment et sont définies de la même manière (nom et
# grandeur). L’ordre des indices souhaité dépend du type des
# dimensions :
# • var (time, z, y, x)
#
# Le nom de la variable est typiquement un acronyme qui suit les
# références des tables MIP et auquel est associé un nom court ou long
# et une unité standard. Bien sûr il est identique au nom de la
# variable dans le nom du fichier.
#
#
# Un exemple :
#
# variables:
#     float SWI(time, y, x) ;
#         SWI:standard_name = "SWI" ;
#         SWI:long_name = "Soil Water Index" ;
#         SWI:units = " " ;
#         SWI:grid_mapping = "LambertParisII" ;
#         SWI:coordinates = "lat lon" ;
#         SWI:_FillValue = NaNf ;
#         SWI:missing_value = NaNf ;
#         SWI:cell_methods = "time:mean" ;
#
# Les attributs de la variable attendus :


## 1. STANDARD_NAME __________________________________________________
# Un nom d’identification court de la variable
standard_name =
    "SWI"
long_name =
    "Soil Water Index"

## 2. UNITS __________________________________________________________
# Spécifie l’unité de la variable coordonnée
units =
    " "

## 3. GRID_MAPPING ___________________________________________________
# Indique le nom de la ‘Projection’ (exemple ‘LambertParisII’) pour
# assurer la connexion
grid_mapping =
    "LambertParisII"

## 4. COORDINATES ____________________________________________________
# Fournit l’information de dimension scalaire ou le label d’une
# sous-région géographique
coordinates =
    "lat lon"

## 5. MISSING_VALUE ET _FILLVALUE ____________________________________
# Spécifie comment sont identifiés les valeurs manquantes
missing_value =
    NA
    # NaNf
_FillValue =
    NA
    # NaNf

## 6. CELL_METHODS ___________________________________________________
# Fournit l’information concernant le calcul ou l’extraction de la
# variable
cell_methods =
    "time: mean"

## 7. COMMENT ________________________________________________________
# Complément d’information sur l’extraction, le calcul de la variable
comment =
    "Potential evapotranspiration calculated using the Hargreaves method with unique coefficient 0.175 from DRIAS-2020 corrected data set (the variable rsdsAdjust is not used). 
Source : ........."
