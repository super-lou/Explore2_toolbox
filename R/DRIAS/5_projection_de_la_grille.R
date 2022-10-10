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


#  _            ___              _           _    _            
# | |    __ _  | _ \ _ _  ___   (_) ___  __ | |_ (_) ___  _ _  
# | |__ / _` | |  _/| '_|/ _ \  | |/ -_)/ _||  _|| |/ _ \| ' \ 
# |____|\__,_| |_|  |_|  \___/ _/ |\___|\__| \__||_|\___/|_||_|
#                             |__/                           
#  ___         _             ___       _  _  _      
# |   \  ___  | |    __ _   / __| _ _ (_)| || | ___ 
# | |) |/ -_) | |__ / _` | | (_ || '_|| || || |/ -_)
# |___/ \___| |____|\__,_|  \___||_|  |_||_||_|\___| _________________
# La projection de la grille doit être référencée par une variable de
# données afin de déclarer explicitement le système de référence des
# coordonnées (CRS) utilisé pour les valeurs des coordonnées spatiales
# horizontales. Par exemple, si les coordonnées spatiales horizontales
# sont la latitude et la longitude, la variable de projection de la
# grille peut être utilisée pour déclarer la figure de la terre
# (ellipsoïde WGS84, sphère, etc.) sur laquelle elles sont basées. Si
# les coordonnées spatiales horizontales sont des abscisses et des
# ordonnées dans une projection cartographique, la variable de
# projection de la grille déclare la projection cartographique CRS
# utilisée et fournit les informations nécessaires pour calculer la
# latitude et la longitude à partir des abscisses et des ordonnées.
#
# La variable de projection de la grille LambertParisII (grille à
# privilégier – sinon veuillez contacter le service DRIAS) contient
# les paramètres de mappage en tant qu’attributs, et est associée à la
# variable Température via son attribut grid_mapping.
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
#     int LambertParisII ;
#         LambertParisII:grid_mapping_name = "lambert_conformal_conic_1SP" ;
#         LambertParisII:latitude_of_origin = 52.f ;
#         LambertParisII:central_meridian = 0.f ;
#         LambertParisII:scale_factor = 0.9998774f ;
#         LambertParisII:false_easting = 600000.f ;
#         LambertParisII:false_northing = 2200000.f ;
#         LambertParisII:epsg = "27572" ;
#         LambertParisII:references = "https://spatialreference.org/ref/epsg/ntf-paris-lambert-zone-ii/" ;

