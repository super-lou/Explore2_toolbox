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
# Les coordonnées spatiales acceptées :
# • en 2 ou 3 dimensions : lat(y, x) lon(y, x) / lat(z, y, x)
#                          lon(z, y, x) alt(z, y, x) →
#                          var(time, y, x) / var(time, z, y, x)
#
# Éviter tout autre format (comme lat(y), lon(x) → var(time, y, x))
# qui ne sera pas lu correctement par les scripts de traitement et
# logiciel graphique. La couverture spatiale est conforme aux
# déclarations, enfin le nombre de point concorde avec la grille de
# projection utilisée.
#
# Les variables représentant la latitude ou la longitude doivent
# toujours inclure explicitement l’attribut units ; il n’y a pas de
# valeur par défaut. L’attribut units est une chaîne de caractères et
# les unités attendues sont les suivantes : lat:units =
# "degrees_north" ; lon:units = "degrees_east".
#
#
# Paramètres :
#         standard_name : Un nom d’identification court de la
#                         coordonnée
#
#             long_name : Un nom d’identification long de la
#                         coordonnée
#
#                 units : Spécifie l’unité de la variable coordonnée
#
#     CoordinateAxisType: Spécifie s’il s’agit d’une coordonnée
#                         spatiale (et laquelle) ou temporelle


## 1. LONGITUDE ______________________________________________________
NCf$lon.name = "lon"
NCf$lon.dimension = "y, x"
NCf$lon.precision = "double"
NCf$lon.value = matrix(rep(NCf$x.value, length(NCf$y.value)),
                       ncol=length(NCf$x.value), byrow=TRUE)
NCf$lon.01.standard_name = "longitude"
NCf$lon.02.long_name = "longitude coordinate"
NCf$lon.03.units = "degrees_east"
NCf$lon.04.CoordinateAxisType = "Lon"


## 2. LATITUDE _______________________________________________________
NCf$lat.name = "lat"
NCf$lat.dimension = "y, x"
NCf$lat.precision = "double"
NCf$lat.value = matrix(rep(NCf$y.value, length(NCf$x.value)),
                       ncol=length(NCf$x.value), byrow=FALSE)
NCf$lat.01.standard_name = "latitude"
NCf$lat.02.long_name = "latitude coordinate"
NCf$lat.03.units = "degrees_north"
NCf$lat.04.CoordinateAxisType = "Lat"
