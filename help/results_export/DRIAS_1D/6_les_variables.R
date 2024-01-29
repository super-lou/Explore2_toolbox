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
NCf$debit.name = "variable"
NCf$debit.dimension = "station, time"
NCf$debit.precision = "float"
NCf$debit.value = data_matrix
NCf$debit.01.standard_name = "debit"
NCf$debit.02.long_name = "debit modcou"
NCf$debit.03.units = "m3.s-1"
NCf$debit.04.missing_value = NaN
# Décrit et détaille la méthode de calcul de l’indicateur
NCf$debit.06.comment = "Count the number of days from November 1 of year N to April 30 of year N+1 fulfilling the conditions “Snowdepth ≥ 50 cm” (using natural snow simulations)"
