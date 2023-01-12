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


#  _                             _        _     _          
# | | ___  ___  __ __ __ _  _ _ (_) __ _ | |__ | | ___  ___
# | |/ -_)(_-<  \ V // _` || '_|| |/ _` || '_ \| |/ -_)(_-<
# |_|\___|/__/   \_/ \__,_||_|  |_|\__,_||_.__/|_|\___|/__/ __________
# Les dimensions de la variable sont au même nombre que les axes
# spécifiés précédemment et sont définies de la même manière (nom et
# grandeur). L’ordre des indices souhaité dépend du type des
# dimensions : var (time, z, y, x)
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
#             units : Spécifie l’unité de la variable coordonnée
#
#      grid_mapping : Indique le nom de la ‘Projection’ (exemple
#                     ‘LambertParisII’) pour assurer la connexion
#
#       coordinates : Fournit l’information de dimension scalaire ou
#                     le label d’une sous-région géographique
#
#     missing_value : Spécifie comment sont identifiés les valeurs
#                     manquantes
#
#         FillValue : Similaire
#
#      cell_methods : Fournit l’information concernant le calcul ou
#                     l’extraction de la variable
#
#           comment : Complément d’information sur l’extraction, le
#                     calcul de la variable


## 1. SWI ____________________________________________________________
NCf$SWI.name = "SWI"
NCf$SWI.dimension = "time, y, x"
NCf$SWI.precision = "float"
NCf$SWI.value = array(data=round(runif(length(NCf$x.value) *
                                       length(NCf$y.value) *
                                       length(NCf$time.value), 0, 10)),
                      dim=c(length(NCf$x.value),
                            length(NCf$y.value),
                            length(NCf$time.value)))
NCf$SWI.01.standard_name = "SWI"
NCf$SWI.02.long_name = "Soil Water Index"
NCf$SWI.03.grid_mapping = "LambertParisII"
NCf$SWI.04.units = " "
NCf$SWI.05.coordinates = "lat lon"
NCf$SWI.06.missing_value = NaN
NCf$SWI.07.cell_methods = "time:mean"
# Publication or an official doc concerning the hydro model
NCf$SWI.08.comment = "Potential evapotranspiration calculated using the Hargreaves method with unique coefficient 0.175 from DRIAS-2020 corrected data set (the variable rsdsAdjust is not used). Source : ........."
