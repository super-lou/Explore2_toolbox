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
#
#
# Un exemple :
#
# variables:
#     double lon(y, x) ;
#         lon:standard_name = "longitude" ;
#         lon:long_name = "longitude coordinate" ;
#         lon:units = "degrees_east" ;
#         lon:_CoordinateAxisType = "Lon" ;
#     double lat(y, x) ;
#         lat:standard_name = "latitude" ;
#         lat:long_name = "latitude coordinate" ;
#         lat:units = "degrees_north" ;
#         lat:_CoordinateAxisType = "Lat" ;
#
#
# S’il existe une variable de coordonnée verticale, elle sera définie
# selon l’axe ‘z’, elle doit toujours inclure explicitement l’attribut
# units, car il n’y a pas de valeur par défaut.
# L’attribut ‘positive’, indique la direction dans laquelle les
# valeurs des coordonnées augmentent, qu’elle soit ascendante ou
# descendante (valeur up ou down). L’attribut units est une chaîne de
# caractères et les unités attendues sont :
# unité de longueur : alt:units = "meter" ;       :units = "m" ;
# unité de pression : depth:units = "pascal" ;    :units = "Pa" ;
#
# Naturellement les valeurs des dimensions sont croissantes et n’ont
# pas de valeur manquante.
#
#
# Un exemple pour exprimer des niveaux d’altitude :
#
# variables:
#     double alt(z) ;
#         alt:standard_name = “height”;
#         alt:long_name = "height above mean sea level" ;
#         alt:units = "meter" ;
#         alt:positive = "up" ;
#         alt:axis = "Z"
#
# Ou pour exprimer des niveaux souterrains :
# variables:
#     double depth(z) ;
#         depth:standard_name = “depth”;
#         depth:long_name = "depth_below_geoid" ;
#         depth:units = "pascal" ;
#         depth:positive = "down" ;
#         depth:axis = "Z"


# Si il y a un axe Z, donc Z n'est pas fixé à NULL
what_is_Z =
    "niveaux d’altitude"
    # "niveaux souterrains"

    

