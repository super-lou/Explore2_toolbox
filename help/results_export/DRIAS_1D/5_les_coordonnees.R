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


#  _          
# | | ___  ___
# | |/ -_)(_-<
# |_|\___|/__/
#                        _                                
#  __  ___  ___  _ _  __| | ___  _ _   _ _   ___  ___  ___
# / _|/ _ \/ _ \| '_|/ _` |/ _ \| ' \ | ' \ / -_)/ -_)(_-<
# \__|\___/\___/|_|  \__,_|\___/|_||_||_||_|\___|\___|/__/ ___________
# Les variables de coordonnées sont indispensables à la localisation
# des stations, elles sont donc unidimensionnelles fonction de
# l’élément ‘station’.
#
# Les stations doivent être incluses dans la couverture spatiale
# annoncée dans les métadonnées et nom du fichier.
#
# Paramètres :
#      standard_name : Un nom d’identification court de la coordonnée
#
#          long_name : Un nom d’identification long de la coordonnée
#
#              units : Spécifie l’unité de la variable coordonnée
#
# CoordinateAxisType
#            ou axis : Spécifie s’il s’agit d’une coordonnée spatiale
#                      (et laquelle) ou temporelle


## 1. WGS 84 _________________________________________________________
### 1.1. WGS 84 lon __________________________________________________
NCf$WGS84_lon.name = "WGS84_lon"
NCf$WGS84_lon.dimension = "station"
NCf$WGS84_lon.precision = "double"
NCf$WGS84_lon.value = 1:length(NCf$station.value)
NCf$WGS84_lon.01.standard_name = "longitude"
NCf$WGS84_lon.02.long_name = "longitude coordinate in WGS84"
NCf$WGS84_lon.03.units = "degrees_east"
NCf$WGS84_lon.04.axis = "lon"

### 1.2. WGS 84 lat __________________________________________________
NCf$WGS84_lat.name = "WGS84_lat"
NCf$WGS84_lat.dimension = "station"
NCf$WGS84_lat.precision = "double"
NCf$WGS84_lat.value = 1:length(NCf$station.value)
NCf$WGS84_lat.01.standard_name = "latitude"
NCf$WGS84_lat.02.long_name = "latitude coordinate in WGS84"
NCf$WGS84_lat.03.units = "degrees_north"
NCf$WGS84_lat.04.axis = "lat"


## 2. LAMBERT-93 _____________________________________________________
### 2.1. Lambert-93 X ________________________________________________
NCf$L93_X.name = "L93_X"
NCf$L93_X.dimension = "station"
NCf$L93_X.precision = "double"
NCf$L93_X.value = 1:length(NCf$station.value)
NCf$L93_X.01.standard_name = "X Lambert-93"
NCf$L93_X.02.long_name = "horizontal coordinate in Lambert-93"
NCf$L93_X.03.units = "m"
NCf$L93_X.04.axis = "X"

### 2.2. Lambert-93 Y ________________________________________________
NCf$L93_Y.name = "L93_Y"
NCf$L93_Y.dimension = "station"
NCf$L93_Y.precision = "double"
NCf$L93_Y.value = 1:length(NCf$station.value)
NCf$L93_Y.01.standard_name = "Y Lambert-93"
NCf$L93_Y.02.long_name = "vertical coordinate in Lambert-93"
NCf$L93_Y.03.units = "m"
NCf$L93_Y.04.axis = "Y"


## 3. LAMBERT-II _____________________________________________________
### 3.1. Lambert-II X ________________________________________________
NCf$LII_X.name = "LII_X"
NCf$LII_X.dimension = "station"
NCf$LII_X.precision = "double"
NCf$LII_X.value = 1:length(NCf$station.value)
NCf$LII_X.01.standard_name = "X Lambert-II"
NCf$LII_X.02.long_name = "horizontal coordinate in Lambert-II"
NCf$LII_X.03.units = "m"
NCf$LII_X.04.axis = "X"

### 3.2. Lambert-II Y ________________________________________________
NCf$LII_Y.name = "LII_Y"
NCf$LII_Y.dimension = "station"
NCf$LII_Y.precision = "double"
NCf$LII_Y.value = 1:length(NCf$station.value)
NCf$LII_Y.01.standard_name = "Y Lambert-II"
NCf$LII_Y.02.long_name = "vertical coordinate in Lambert-II"
NCf$LII_Y.03.units = "m"
NCf$LII_Y.04.axis = "Y"
