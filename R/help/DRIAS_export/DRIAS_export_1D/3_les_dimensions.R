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
# Les séries temporelles de chaque station ayant le même nombre
# d’instance et des valeurs temporelles identiques pour toutes les
# instances, la représentation en tableau bidimensionnel est idéale.
# Celle-ci comporte deux dimensions : celle du temps ‘time’ et celle
# des éléments ici appelé ‘station’. De préférence ces dimensions
# apparaissent dans l’ordre suivant ‘time’, puis ‘station’.
#
# Naturellement les valeurs des dimensions sont croissantes et n’ont
# pas de valeur manquante.


## 1. LE TEMPS _______________________________________________________
# L’axe temporel est défini à partir d’une variable
# unidimensionnelle : time(time), la période couverte coïncide à celle
# annoncée par les métadonnées. Le nombre de valeur vérifie
# l’information sur la fréquence temporelle des données. Attention
# toute fois au type de calendrier et aux variations de début et de
# fin de période, des problèmes récurrents qui sont issus des modèles
# eux-mêmes. D’où l’importance d’une bonne documentation des attributs.
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

NCf$time.name = "time"
NCf$time.value = time
NCf$time.01.standard_name = "time"
NCf$time.02.long_name = "time"
NCf$time.03.units = paste0(pas_de_temps, " since ", from)
NCf$time.04.calendar = "standard"
NCf$time.05.axis = "T"


## 2. LES STATIONS ___________________________________________________
# Chaque élément ‘station’ est identifié à partir d’au moins 2
# variables qui sont des chaînes de caractères de longueur fixe et
# définie :
# station_code(station, code_strlen) : un code unique issu d’une
#                                      banque de données (ex : banque
#                                      HYDRO) qui le rattache à un
#                                      site hydrométrique bien
#                                      identifiés.
#
# station_name(station, name_strlen) : un libellé de la station
#                                      décrivant le cours d’eau, la
#                                      ville la plus proche et un
#                                      complément sur le site en
#                                      question (ex : La Vienne à
#                                      Limoges - Pont-Neuf ).
#
# Il peut être nécessaire d’ajouter des informations complémentaires,
# comme une classification des stations, on pourra alors s’appuyer sur
# la variable station_info(station).
#
#
# Paramètres :
#         long_name : Un nom d’identification long de la variable

### 2.1. Les dimensions associées ____________________________________
NCf$station.name = "station"
NCf$station.value = 1:3

NCf$code_strlen.name = "code_strlen"
NCf$code_strlen.value = 1:8
NCf$code_strlen.is_nchar_dimension = TRUE

NCf$name_strlen.name = "name_strlen"
NCf$name_strlen.value = 1:23
NCf$name_strlen.is_nchar_dimension = TRUE

### 2.2. station_code ________________________________________________
NCf$station_codeHydro.name = "station_codeHydro"
NCf$station_codeHydro.dimension = "station, code_strlen"
NCf$station_codeHydro.precision = "char"
NCf$station_codeHydro.value = c("AAAAAAAA", "BBBBBBBB", "CCCCCCCC")
NCf$station_codeHydro.01.long_name = "code HYDRO"

### 2.3. station_name ________________________________________________
NCf$station_name.name = "station_name"
NCf$station_name.dimension = "name_strlen, station"
NCf$station_name.precision = "char"
NCf$station_name.value = c("La a sur a","La b sur b", "La c sur c")
NCf$station_name.01.long_name = "station name"

### 2.4. station_info ________________________________________________
NCf$station_info.name = "station_info"
NCf$station_info.dimension = "station"
NCf$station_info.precision = "integer"
NCf$station_info.value = 1:3
NCf$station_info.01.long_name = "some kind of station info"


## 3. LES DIMENSIONS VERTICALES ______________________________________
# Si la station représente un site en altitude ou un site souterrain,
# il faudra à ce moment-là définir une variable de dimension
# verticale, à défaut la station sera considérée comme de surface ou
# affleurante.
#
# La dimension verticale doit toujours inclure explicitement
# l’attribut units, car il n’y a pas de valeur par défaut.
# L’attribut ‘positive’, indique la direction dans laquelle les
# valeurs des dimension augmentent, qu’elle soit ascendante ou
# descendante (valeur up ou down). L’attribut units est une chaîne de
# caractères et les unités attendues sont :
# alt:units = "m" ; depth:units = "Pa".
#
#
# Paramètres :
#     standard_name : Un nom d’identification court de la dimension
#
#         long_name : Un nom d’identification long de la dimension
#
#             units : Spécifie l’unité de la variable dimension
#
#          positive : Indique la direction dans laquelle les valeurs
#                     des dimension augmentent, qu’elle soit
#                     ascendante ou descendante (valeur up ou down)
#
#              axis : Axe associé à la variable

### 3.1. L'altitude __________________________________________________
NCf$alt.name = "alt"
NCf$alt.precision = "double"
NCf$alt.value = 1:length(NCf$station.value)
NCf$alt.01.standard_name = "height"
NCf$alt.02.long_name = "height above mean sea level"
NCf$alt.03.units = "meter"
NCf$alt.04.positive = "up"
NCf$alt.05.axis = "Z"

### 3.2. La profondeur _______________________________________________
NCf$depth.name = "depth"
NCf$depth.precision = "double"
NCf$depth.value = 1:length(NCf$station.value)
NCf$depth.01.standard_name = "depth"
NCf$depth.02.long_name = "depth_below_geoid"
NCf$depth.03.units = "pascal"
NCf$depth.04.positive = "down"
NCf$depth.05.axis = "Z"
