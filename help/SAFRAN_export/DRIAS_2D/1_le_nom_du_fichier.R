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


#  _                          
# | | ___    _ _   ___  _ __  
# | |/ -_)  | ' \ / _ \| '  \ 
# |_|\___|  |_||_|\___/|_|_|_|                      
#     _           __  _      _     _           
#  __| | _  _    / _|(_) __ | |_  (_) ___  _ _ 
# / _` || || |  |  _|| |/ _|| ' \ | |/ -_)| '_|
# \__,_| \_,_|  |_|  |_|\__||_||_||_|\___||_|   ______________________
# Les éléments composant le nom du fichier fournissent rapidement des
# informations sur la simulation et s’écrit comme ce qui suit :
#
#     Variable_Domain_Reanalysis_HYDRO-Inst-Model_
#     TimeFrequency_StartTime-EndTime_Suffix.nc

## 1. Variable _______________________________________________________
# Le nom de la variable (avec Adjust si les données sont corrigées),
# sera à la lettre près identique au nom de la variable du fichier
NCf$title.01.Variable =
    'debit'
    # 'debitAdjust'

## 2. Domaine ________________________________________________________
# Couverture spatiale des données
NCf$title.02.Domain =
    'France'
    # 'Garonne'
    # 'Loire'
    # 'Seine'

## 3. Reanalysis _________________________________________________
# Nom de la Réanalyse utilisée en entrée
NCf$title.03.Reanalysis =
    'SAFRAN-France-2022'

## 4. HYDRO-Inst-Model _______________________________________________
# Identifiant du HYDRO = Institut-Modèle
NCf$title.04.HYDRO_Inst_Model =
    'MF-SIM2'
    # 'BRGM-Marthe'
    # 'IPSL-ORCHIDEE'
    # 'BRGM-EROS'
    # 'INRAE-J2000'
    # 'BRGM-AquiFR'

## 5. TimeFrequency _________________________________________________
# Le pas de temps du jeu de données
NCf$title.05.TimeFrequency =
    'day'
    # '1hr'

## 6. Startyear-Endyear _____________________________________________
# Couverture temporelle des données sous forme YYYYMMDD-YYYYMMDD. Les
# fichiers doivent être en année hydro et couvrir la période
# 01/08/1976-31/07/2022
NCf$title.06.StartTime_EndTime =
     '19760801-20220731'

## 7. Suffix ________________________________________________________
# Exceptionnellement – toute information permettant de distinguer des
# fichiers lorsque les éléments précédents ne le permettent pas.
# Exemple sur le calcul de l’ETP par des méthodes de calcul
# différentes.
NCf$title.07.Suffix = 
    ""
    # 'FAO'
    # 'Hg0175'
