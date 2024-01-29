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
#     Indicator_TimeFrequency_StartTime-EndTime_Domain_ModelXXX.nc

projection_ok =
    grepl(dataEX$GCM[1], meta_projection$gcm.short) &
    grepl(dataEX$RCM[1], meta_projection$rcm.short)

## 1. Indicateur _____________________________________________________
# Le nom de l’indicateur
NCf$title.01.Indicator = metaEX_var$variable_en
    # 'QAV'
    # 'Q05'
    # 'Q10'
    # 'Q50'
    # 'Q90'
    # 'Q95'

## 2. Pas de temps ___________________________________________________
# Le pas de temps du traitement
NCf$title.02.TimeFrequency = 'yr'
    # 'mon-01'
    # 'mon-02'
    # 'mon-03'
    # 'mon-12'
    # 'seas-DJF'
    # 'seas-MAM' 
    # 'seas-JJA' 
    # 'seas-SON'

## 3. Couverture temporelle __________________________________________
# Couverture temporelle des données sous forme YYYYMMDD-YYYYMMDD
NCf$title.03.StartTime_EndTime = paste0(format(min(Date), "%Y%m%d"),
                                        "-",
                                        format(max(Date), "%Y%m%d"))
# '19710801-20050731'

## 4. Domain _________________________________________________________
#  Couverture spatiale des données 
NCf$title.04.Domain = 'France'

## 5. GCM-Model _________________________________________________
# Identifiant du GCM forçeur
NCf$title.05.GCM_Model = meta_projection$gcm.short[projection_ok]
    # 'CNRM-CM5'
    # 'EC-EARTH'
    # 'IPSL-CM5A'
    # 'HadGEM2'
    # 'MPI-ESM'
    # 'NorESM1'

## 6. Experiment _____________________________________________________
# Identifiant de l’expérience historique ou future via le scénario
NCf$title.06.Experiment = dataEX$EXP[1]
    # 'rcp26'
    # 'rcp45'
    # 'rcp85'
    # 'historical'

## 7. RCM-Model _________________________________________________
# Identifiant du RCM
NCf$title.07.RCM_Model = meta_projection$rcm.short[projection_ok]
# 'CCLM4-8-17'
    # 'ALADIN63'
    # 'HIRHAM5'
    # 'REMO2015'
    # 'RegCM4-6'
    # 'WRF381P'
    # 'RACMO22E'
    # 'REMO2009'
    # 'RCA4'

## 8. Bc-Inst-Method-Obs-Period ______________________________________
# Identifiant de la méthode de correction de biais statistique =
# Institut-Méthode-Réanalyse-Période
BC = c('MF-ADAMONT-SAFRAN-1980-2011', 'LSCE-R2D2-SAFRAN-1976-2005')
NCf$title.08.Bc_Inst_Method_Obs_Period = BC[grepl(dataEX$BC[1], BC)][1]

# ## 9. QXX ________________________________________________________
# # Opération statistique multi-modèles
# NCf$title.09.QXX =
#     'min'
#     # 'Q05'
#     # 'Q10'
#     # 'Q17'
#     # 'Q25'
#     # 'Q50'
#     # 'Q75'
#     # 'Q83'
#     # 'Q90'
#     # 'Q95'
#     # 'max'

## 9. HYDRO-Inst-Model _______________________________________________
# Identifiant du HYDRO = Institut-Modèle
NCf$title.09.HYDRO_Inst_Model = dataEX$HM[1]
    # 'SIM2'
    # 'ORCHIDEE'
    # 'EROS'
    # 'AquiFR'

## 10. nomProjet _____________________________________________________
#  Nom du projet dans lequel ont été produits ces simulations
NCf$title.10.nomProjet = meta_projection$project[projection_ok]
    # 'EXPLORE2'
    # 'DRIAS-2020'
    # 'ADAMONT-2020'
    # 'TRACC-2023'
    
## 11. Suffix ________________________________________________________
# Exceptionnellement – toute information permettant de distinguer des
# fichiers lorsque les éléments précédents ne le permettent pas.
# Exemple sur le calcul de l’ETP par des méthodes de calcul
# différentes.
NCf$title.11.Suffix = 
    ""
    # 'FAO'
    # 'Hg0175'
