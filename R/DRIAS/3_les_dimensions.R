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


#  _               ___   _                        _                
# | |    ___  ___ |   \ (_) _ __   ___  _ _   ___(_) ___  _ _   ___
# | |__ / -_)(_-< | |) || || '  \ / -_)| ' \ (_-<| |/ _ \| ' \ (_-<
# |____|\___|/__/ |___/ |_||_|_|_|\___||_||_|/__/|_|\___/|_||_|/__/ __
# Au moins 3 dimensions sont attendus : celles de l’espace et du
# temps. Dans certaines circonstances, on peut avoir besoin de plus
# d’une quatrième dimension, pour représenter les niveaux verticaux
# par exemple.
#
# On interprétera comme "date ou heure" : T, "altitude ou
# profondeur" : Z, "latitude" : Y ou "longitude" : X. De préférence
# ces dimensions apparaissent dans l'ordre relatif T, puis Z, puis Y,
# puis X. Naturellement les valeurs des dimensions sont croissantes et
# n’ont pas de valeur manquante.
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
# Un exemple :
#
# dimensions:
#     time = UNLIMITED ; // (34698 currently)
#     x = 143 ;
#     y = 134 ;
# variables:
#     double time(time) ;
#         time:standard_name = "time" ;
#         time:long_name = "time" ;
#         time:units = "days since 1950-01-01 00:00:00" ;
#         time:calendar = "standard" ;
#         time:axis = "T" ;
#     double x(x) ;
#         x:standard_name = "projection_x_coordinate" ;
#         x:long_name = "x coordinate of projection" ;
#         x:units = "m" ;
#         x:axis = "X" ;
#     double y(y) ;
#         y:standard_name = "projection_y_coordinate" ;
#         y:long_name = "y coordinate of projection" ;
#         y:units = "m" ;
#         y:axis = "Y" ;


## 1. LE TEMPS _______________________________________________________
# Paramètre du vecteur temps
date_de_debut = "1950-01-01"
date_de_fin = "2005-12-31"
fuseau_horaire = "UTC"
pas_de_temps =
    # "hours"
    # "sec"
    # "10 min"
    # "hours"
    "days"
    # "3 weeks"
    # "months"

## 2. L'AXE X ________________________________________________________
# Vecteur de données et son unité
X = seq(from=0, to=100, by=1)
unite_de_X = "m"

## 3. L'AXE Y ________________________________________________________
# Vecteur de données et son unité
Y = seq(from=0, to=100, by=1)
unite_de_Y = "m"

## 4. L'AXE Z ________________________________________________________
# Vecteur de données et son unité (si il y a aucun vecteur Z,
# sélectionner 'NULL' pour 'Z')
Z =
    NULL
    # c(0, 10, 100)
    # seq(from=0, to=100, by=1)
unite_de_Z = "m" 
