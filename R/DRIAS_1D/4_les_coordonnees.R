# \\\
# Copyright 2022 Louis Héraut (louis.heraut@inrae.fr)*1
#
# *1   INRAE, France
#
# This file is part of Ex2D R toolbox.
#
# Ex2D R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ex2D R toolbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ex2D R toolbox.
# If not, see <https://www.gnu.org/licenses/>.
# ///


#  _ 
# | |    ___  ___
# | |__ / -_)(_-<
# |____|\___|/__/
#   ___                    _                                
#  / __| ___  ___  _ _  __| | ___  _ _   _ _   ___  ___  ___
# | (__ / _ \/ _ \| '_|/ _` |/ _ \| ' \ | ' \ / -_)/ -_)(_-<
#  \___|\___/\___/|_|  \__,_|\___/|_||_||_||_|\___|\___|/__/ _________
# Les variables de coordonnées sont indispensables à la localisation
# des stations, elles sont donc unidimensionnelles fonction de
# l’élément ‘station’.
#
# Les stations doivent être incluses dans la couverture spatiale
# annoncée dans les métadonnées et nom du fichier.
#
# Les variables représentant la latitude ou la longitude doivent
# toujours inclure l’attribut units ; il n’y a pas de valeur par
# défaut. L’attribut units est une chaîne de caractères et les
# unités attenues sont les suivantes :
# lat:units = "degrees_north" ; lon:units = "degrees_east".
#
#
# Paramètres :
#     standard_name : Un nom d’identification court de la coordonnée
#
#         long_name : Un nom d’identification long de la coordonnée
#
#             units : Spécifie l’unité de la variable coordonnée


## 1. LONGITUDE ______________________________________________________
lon.name = "lon"
lon.dimension = "station"
lon.precision = "double"
lon.value = 1:length(station.value)
lon.01.standard_name = "longitude"
lon.02.long_name = "station longitude"
lon.03.units = "degrees_east"


## 2. LATITUDE _______________________________________________________
lat.name = "lat"
lat.dimension = "station"
lat.precision = "double"
lat.value = 1:length(station.value)
lat.01.standard_name = "latitude"
lat.02.long_name = "station latitude"
lat.03.units = "degrees_north"
