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
#        _FillValue : Spécifie comment sont identifiés les non réelles
#
#     missing_value : Spécifie comment sont identifiés les valeurs
#                     manquantes
#
#      cell_methods : Fournit l’information concernant le calcul ou
#                     l’extraction de la variable


## 1. VARIABLES ______________________________________________________
NCf$variable.name = metaEX_var$variable_en
NCf$variable.dimension = "station, time"
NCf$variable.precision = "float"
NCf$variable.value = dataEX_matrix
NCf$variable.01.standard_name = metaEX_var$variable_en
NCf$variable.02.long_name = metaEX_var$name_en
NCf$variable.03.units = metaEX_var$unit_en
NCf$variable.04.missing_value = NaN
NCf$variable.05.description = metaEX_var$description_en
NCf$variable.06.method = metaEX_var$method_en
NCf$variable.07.sampling_period = metaEX_var$sampling_period_en
