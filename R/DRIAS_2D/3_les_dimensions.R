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


#  _                ___   _                        _                
# | |    ___  ___  |   \ (_) _ __   ___  _ _   ___(_) ___  _ _   ___
# | |__ / -_)(_-<  | |) || || '  \ / -_)| ' \ (_-<| |/ _ \| ' \ (_-<
# |____|\___|/__/  |___/ |_||_|_|_|\___||_||_|/__/|_|\___/|_||_|/__/ _
# Au moins 3 dimensions sont attendus : celles de l’espace et du
# temps. Dans certaines circonstances, on peut avoir besoin de plus
# d’une quatrième dimension, pour représenter les niveaux verticaux
# par exemple.
#
# On interprétera comme "date ou heure" : T, "altitude ou
# profondeur" : Z, "latitude" : Y ou "longitude" : X. De préférence
# ces dimensions apparaissent dans l'ordre relatif T, puis Z, puis Y,
# puis X.
#
# Naturellement les valeurs des dimensions sont croissantes et
# n’ont pas de valeur manquante.


## 1. LE TEMPS _______________________________________________________
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
#              axis : Axe associé à la variable

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
time = seq.POSIXt(from=from, to=to, by=pas_de_temps)
time = as.numeric(time - from) / 86400

time.name = "time"
time.value = time
time.01.standard_name = "time"
time.02.long_name = "time"
time.03.units = paste0(pas_de_temps, " since ", from)
time.04.calendar = "standard"
time.05.axis = "T"


## 2. L'ESPACE _______________________________________________________
### 2.1. L'axe x _____________________________________________________
x.name = "x"
x.value = seq(from=0, to=9, by=1)
x.01.standard_name = "projection_x_coordinate"
x.02.long_name = "x coordinate of projection"
x.03.units = "m"
x.04.axis = "X"

### 2.2. L'axe y _____________________________________________________
y.name = "y"
y.value = seq(from=0, to=9, by=1)
y.01.standard_name = "projection_y_coordinate"
y.02.long_name = "y coordinate of projection"
y.03.units = "m"
y.04.axis = "Y"

### 2.3. L'axe z _____________________________________________________
# S’il existe une coordonnée verticale, elle sera définie selon l’axe
# ‘z’, elle doit toujours inclure explicitement l’attribut units,
# car il n’y a pas de valeur par défaut.
# L’attribut ‘positive’, indique la direction dans laquelle les
# valeurs des coordonnées augmentent, qu’elle soit ascendante ou
# descendante (valeur up ou down). L’attribut units est une chaîne de
# caractères et les unités attendues sont :
# alt:units = "m" ; depth:units = "Pa".
#
#
# Paramètres :
#     standard_name : Un nom d’identification court de la coordonnée
#
#         long_name : Un nom d’identification long de la coordonnée
#
#             units : Spécifie l’unité de la variable coordonnée
#
#          positive : Indique la direction dans laquelle les valeurs
#                     des coordonnées augmentent, qu’elle soit
#                     ascendante ou descendante (valeur up ou down)
#
#              axis : Axe associé à la variable

#### 2.3.1. L'altitude _______________________________________________
alt.name = "alt"
alt.precision = "double"
alt.value = seq(from=0, to=9, by=1)
alt.01.standard_name = "height"
alt.02.long_name = "height above mean sea level"
alt.03.units = "meter"
alt.04.positive = "up"
alt.05.axis = "Z"

#### 2.3.2. La profondeur ____________________________________________
depth.name = "depth"
depth.precision = "double"
depth.value = seq(from=0, to=9, by=1)
depth.01.standard_name = "depth"
depth.02.long_name = "depth_below_geoid"
depth.03.units = "pascal"
depth.04.positive = "down"
depth.05.axis = "Z"
