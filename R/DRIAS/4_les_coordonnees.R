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


#  _ 
# | |    ___  ___
# | |__ / -_)(_-<
# |____|\___|/__/
#   ___                    _                           
#  / __| ___  ___  _ _  __| | ___  _ _   _ _   ___  ___
# | (__ / _ \/ _ \| '_|/ _` |/ _ \| ' \ | ' \ / -_)(_-<
#  \___|\___/\___/|_|  \__,_|\___/|_||_||_||_|\___|/__/ ______________
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
# "degrees_north" ; lon:units = "degrees_east" ;
#
# Naturellement les valeurs des dimensions sont croissantes et n’ont
# pas de valeur manquante.
#
# Les attributs des coordonnées attendus :
# - standard_name, un nom d’identification court de la coordonnée.
# - units, spécifie l’unité de la variable coordonnée.
# - _CoordinateAxisType ou axis, spécifie s’il s’agit d’une coordonnée
#   spatiale (et laquelle) ou temporelle.


## 1. LONGITUDE ______________________________________________________
lon.name = "lon"
lon.dimension = "y, x"
lon.standard_name = "longitude"
lon.long_name = "longitude coordinate"
lon.units = "degrees_east"
lon.precision = "double"
lon.value = matrix(rep(x.value, length(y.value)),
                   ncol=length(x.value), byrow=TRUE)

## 2. LATITUDE _______________________________________________________
lat.name = "lat"
lat.dimension = "y, x"
lat.standard_name = "latitude"
lat.long_name = "latitude coordinate"
lat.units = "degrees_north"
lat.precision = "double"
lat.value = matrix(rep(y.value, length(x.value)),
                   ncol=length(x.value), byrow=FALSE)
