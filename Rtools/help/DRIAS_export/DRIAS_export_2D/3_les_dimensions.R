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


#  _                _  _                        _                
# | | ___  ___   __| |(_) _ __   ___  _ _   ___(_) ___  _ _   ___
# | |/ -_)(_-<  / _` || || '  \ / -_)| ' \ (_-<| |/ _ \| ' \ (_-<
# |_|\___|/__/  \__,_||_||_|_|_|\___||_||_|/__/|_|\___/|_||_|/__/ ____
# Au moins 3 dimensions sont attendus : celles de l’espace et du
# temps. Dans certaines circonstances, on peut avoir besoin de plus
# d’une quatrième dimension, pour représenter les niveaux verticaux
# par exemple.
#
# On interprétera comme "date ou heure" : T, " profondeur" : Z,
# "veticale" : Y et "horizontale" : X. De préférence ces dimensions
# apparaissent dans l'ordre relatif T, puis Z, puis Y, puis X.
#
# Naturellement les valeurs des dimensions sont croissantes et
# n’ont pas de valeur manquante.
#
#
# L’axe temporel est toujours sous le format : time(time), la période
# couverte coïncide à celle annoncée par les métadonnées. Le nombre de
# valeur vérifie l’information sur la fréquence temporelle des
# données. Attention toute fois au type de calendrier et aux
# variations de début et de fin de période, des problèmes récurrents
# qui sont issus des modèles eux-mêmes. D’où l’importance d’une bonne
# documentation des attributs.
#
# L’axe temporel doit être défini comme « UNLIMITED », c’est-à-dire de
# dimension 1 et sans restriction. Cela permet de pouvoir concaténer
# des fichiers NetCDF si besoin. Pour cela, il est possible de les
# générer sans dimension fixée (record) et de les « degenerate ».
# Une commande ncks existe pour cela :
#
# ncks -O --mk_rec_dmn time in.nc out.nc # Change "time" to record
#                                        # dimension
#
# Le temps doit toujours inclure explicitement l’attribut "units" ; il
# n'y a pas de valeur par défaut. L’unité de temps attendue est :
# "days since YYYY-MM-DD hh:mm:ss" ; où YYYY définit l’année, MM le
# mois, DD le jour, hh l'heure, mm les minutes et ss les secondes.
# L’attribut "units" prend une valeur selon de codage suivant : "days
# since 1950-01-01 00:00:00" qui indique les jours depuis le 1er
# janvier 1950.
# La chaîne date/heure de référence (qui apparaît après
# l’identifiant since) est obligatoire. Elle peut inclure la date
# seule, ou la date et l’heure, ou la date, l’heure et le fuseau
# horaire. Si le fuseau horaire est omis, la valeur par défaut est
# UTC, et si l’heure et le fuseau horaire sont omis, la valeur par
# défaut est 00:00:00 UTC.
#
# Le choix du calendrier définit l’ensemble des dates (combinaisons
# année-mois-jour) qui sont autorisées. Il spécifie donc le nombre de
# jours entre deux dates quelconques. Le calendrier de temps attendu
# est : "standard" ; c’est le calendrier par défaut le calendrier
# grégorien. Dans ce calendrier, les dates/heures sont dans le
# calendrier grégorien, dans lequel une année est bissextile si (i)
# elle est divisible par 4 mais pas par 100 ou (ii) elle est
# divisible par 400.
#
#
# Paramètres :
#     standard_name : Un nom d’identification court de la dimension
#
#         long_name : Un nom d’identification long de la dimension
#
#             units : Spécifie l’unité de la dimension
#
#          calendar : Indique le type de calendrier utilisé
#
#          positive : Indique la direction dans laquelle les valeurs
#                     des coordonnées augmentent, qu’elle soit
#                     ascendante ou descendante (valeur up ou down)
#
#              axis : Axe associé à la variable


# 1. LE TEMPS ________________________________________________________
date_de_debut = "2000-01-01"
date_de_fin = "2000-01-31"
fuseau_horaire = "UTC"
pas_de_temps =
    # "hours"
    # "sec"
    # "10 min"
    # "hours"
    "days"
    # "3 weeks"
    # "months"

from = as.POSIXct(date_de_debut, tz=fuseau_horaire)
to = as.POSIXct(date_de_fin, tz=fuseau_horaire)
origin = as.POSIXct("1950-01-01", tz=fuseau_horaire)
units = paste0(pas_de_temps, " since ", origin)
time = seq.POSIXt(from=from, to=to, by=pas_de_temps)
time = as.numeric(time - origin)

NCf$time.name = "time"
NCf$time.value = time
NCf$time.01.standard_name = "time"
NCf$time.02.long_name = "time"
NCf$time.03.units = units
NCf$time.04.calendar = "standard"
NCf$time.05.axis = "T"


## 2. L'ESPACE _______________________________________________________
### 2.1. L'axe x _____________________________________________________
NCf$x.name = "x"
NCf$x.value = seq(from=0, to=9, by=1)
NCf$x.01.standard_name = "x_coordinate"
NCf$x.02.long_name = "horizontal coordinate"
NCf$x.03.units = "m"
NCf$x.04.axis = "X"

### 2.2. L'axe y _____________________________________________________
NCf$y.name = "y"
NCf$y.value = seq(from=0, to=9, by=1)
NCf$y.01.standard_name = "y_coordinate"
NCf$y.02.long_name = "vertical coordinate"
NCf$y.03.units = "m"
NCf$y.04.axis = "Y"

### 2.3. L'axe z _____________________________________________________
NCf$z.name = "z"
NCf$z.precision = "double"
NCf$z.value = seq(from=0, to=2, by=1)
NCf$z.01.standard_name = "z_coordinate"
NCf$z.02.long_name = "NGF depth"
NCf$z.03.units = "m"
NCf$z.04.positive = "down"
NCf$z.05.axis = "Z"

#### 2.4. Layer ______________________________________________________
NCf$layer.name = "layer"
NCf$layer.dimension = "z, layer_strlen"
NCf$layer.precision = "char"
NCf$layer.value = c("couche affleurante", "couche A", "couche B")
NCf$layer.01.long_name = "name of hydro-geological layer"
NCf$layer_strlen.name = "layer_strlen"
NCf$layer_strlen.value = 1:max(nchar(NCf$layer.value))
NCf$layer_strlen.is_nchar_dimension = TRUE
