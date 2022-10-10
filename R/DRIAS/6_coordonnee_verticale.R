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


#   ___                    _                       
#  / __| ___  ___  _ _  __| | ___  _ _   _ _   ___ 
# | (__ / _ \/ _ \| '_|/ _` |/ _ \| ' \ | ' \ / -_)
#  \___|\___/\___/|_|  \__,_|\___/|_||_||_||_|\___| 
# __   __           _    _            _      
# \ \ / / ___  _ _ | |_ (_) __  __ _ | | ___ 
#  \ V / / -_)| '_||  _|| |/ _|/ _` || |/ -_)
#   \_/  \___||_|   \__||_|\__|\__,_||_|\___| ________________________
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
# Pour exprimer des niveaux d’altitude :
#     double alt(z) ;
#         alt:standard_name = “height”;
#         alt:long_name = "height above mean sea level" ;
#         alt:units = "meter" ;
#         alt:positive = "up" ;
#         alt:axis = "Z"
#
# Pour exprimer des niveaux souterrains :
#     double depth(z) ;
#         depth:standard_name = “depth”;
#         depth:long_name = "depth_below_geoid" ;
#         depth:units = "pascal" ;
#         depth:positive = "down" ;
#         depth:axis = "Z"


