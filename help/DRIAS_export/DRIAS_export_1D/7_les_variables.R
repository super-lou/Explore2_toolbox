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
#         FillValue : Spécifie comment sont identifiés les valeurs
#                     manquantes
#
#     missing_value : Similaire
#
#      cell_methods : Fournit l’information concernant le calcul ou
#                     l’extraction de la variable


## 1. DEBIT __________________________________________________________
NCf$debit.name = "debit"
NCf$debit.dimension = "station, time"
NCf$debit.precision = "float"
NCf$debit.value =
    matrix(
        data=round(x=runif(length(NCf$time.value)*length(NCf$station.value)),
                   digits=2),
        ncol=length(NCf$time.value)
    )
NCf$debit.01.standard_name = "debit"
NCf$debit.02.long_name = "debit modcou"
NCf$debit.03.units = "m3.s-1"
NCf$debit.04.missing_value = NaN
NCf$debit.05.cell_methods = "time:sum"
# Publication or an official doc concerning the hydro model
NCf$debit.06.comment = "source : ..."

