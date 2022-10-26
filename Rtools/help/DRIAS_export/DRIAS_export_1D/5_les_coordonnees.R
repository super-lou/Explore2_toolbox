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
# | | ___  ___
# | |/ -_)(_-<
# |_|\___|/__/
#                        _                                
#  __  ___  ___  _ _  __| | ___  _ _   _ _   ___  ___  ___
# / _|/ _ \/ _ \| '_|/ _` |/ _ \| ' \ | ' \ / -_)/ -_)(_-<
# \__|\___/\___/|_|  \__,_|\___/|_||_||_||_|\___|\___|/__/ ___________
# Les variables de coordonnées sont indispensables à la localisation
# des stations, elles sont donc unidimensionnelles fonction de
# l’élément ‘station’.
#
# Les stations doivent être incluses dans la couverture spatiale
# annoncée dans les métadonnées et nom du fichier.
#
# Paramètres :
#     standard_name : Un nom d’identification court de la coordonnée
#
#         long_name : Un nom d’identification long de la coordonnée
#
#             units : Spécifie l’unité de la variable coordonnée


## 1. LAMBERT-93 _____________________________________________________
### 1.1. Lambert-93 X ________________________________________________
#### 1.1.1. Real _____________________________________________________
NCf$L93_X.name = "L93_X"
NCf$L93_X.dimension = "station"
NCf$L93_X.precision = "double"
NCf$L93_X.value = 1:length(NCf$station.value)
NCf$L93_X.01.standard_name = "X Lambert-93"
NCf$L93_X.02.long_name = "horizontal coordinate in Lambert-93"
NCf$L93_X.03.units = "m"
#### 1.1.2. Model _____________________________________________________
NCf$L93_X_model.name = "L93_X_model"
NCf$L93_X_model.dimension = "station"
NCf$L93_X_model.precision = "double"
NCf$L93_X_model.value = 1:length(NCf$station.value)
NCf$L93_X_model.01.standard_name = "X Lambert-93 model"
NCf$L93_X_model.02.long_name =
    "horizontal coordinate in Lambert-93 in the model world"
NCf$L93_X_model.03.units = "m"

### 1.2. Lambert-93 Y ________________________________________________
#### 1.2.1. Real _____________________________________________________
NCf$L93_Y.name = "L93_Y"
NCf$L93_Y.dimension = "station"
NCf$L93_Y.precision = "double"
NCf$L93_Y.value = 1:length(NCf$station.value)
NCf$L93_Y.01.standard_name = "Y Lambert-93"
NCf$L93_Y.02.long_name = "vertical coordinate in Lambert-93"
NCf$L93_Y.03.units = "m"
#### 1.2.2. Model _____________________________________________________
NCf$L93_Y_model.name = "L93_Y_model"
NCf$L93_Y_model.dimension = "station"
NCf$L93_Y_model.precision = "double"
NCf$L93_Y_model.value = 1:length(NCf$station.value)
NCf$L93_Y_model.01.standard_name = "Y Lambert-93 model"
NCf$L93_Y_model.02.long_name =
    "vertical coordinate in Lambert-93 in the model world"
NCf$L93_Y_model.03.units = "m"


## 2. LAMBERT-II _____________________________________________________
### 2.1. Lambert-II X ________________________________________________
#### 2.1.1. Real _____________________________________________________
NCf$LII_X.name = "LII_X"
NCf$LII_X.dimension = "station"
NCf$LII_X.precision = "double"
NCf$LII_X.value = 1:length(NCf$station.value)
NCf$LII_X.01.standard_name = "X Lambert-II"
NCf$LII_X.02.long_name = "horizontal coordinate in Lambert-II"
NCf$LII_X.03.units = "m"
#### 2.1.2. Model _____________________________________________________
NCf$LII_X_model.name = "LII_X_model"
NCf$LII_X_model.dimension = "station"
NCf$LII_X_model.precision = "double"
NCf$LII_X_model.value = 1:length(NCf$station.value)
NCf$LII_X_model.01.standard_name = "X Lambert-II model"
NCf$LII_X_model.02.long_name =
    "horizontal coordinate in Lambert-II in the model world"
NCf$LII_X_model.03.units = "m"

### 2.2. Lambert-II Y ________________________________________________
#### 2.2.1. Real _____________________________________________________
NCf$LII_Y.name = "LII_Y"
NCf$LII_Y.dimension = "station"
NCf$LII_Y.precision = "double"
NCf$LII_Y.value = 1:length(NCf$station.value)
NCf$LII_Y.01.standard_name = "Y Lambert-II"
NCf$LII_Y.02.long_name = "vertical coordinate in Lambert-II"
NCf$LII_Y.03.units = "m"
#### 2.2.2. Model _____________________________________________________
NCf$LII_Y_model.name = "LII_Y_model"
NCf$LII_Y_model.dimension = "station"
NCf$LII_Y_model.precision = "double"
NCf$LII_Y_model.value = 1:length(NCf$station.value)
NCf$LII_Y_model.01.standard_name = "Y Lambert-II model"
NCf$LII_Y_model.02.long_name =
    "vertical coordinate in Lambert-II in the model world"
NCf$LII_Y_model.03.units = "m"
