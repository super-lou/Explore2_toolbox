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
#     Variable_Domain_GCM-Inst-Model_Experiment_Member_
#     RCM-Inst-Model_Version_Bc-Inst-Method-Obs-Period_
#     HYDRO-Inst-Model_TimeFrequency_StartTime-EndTime_Suffix.nc


## 1. Variable _______________________________________________________
# Le nom de la variable (avec Adjust si les données sont corrigées),
# sera à la lettre près identique au nom de la variable du fichier
NCf$title.01.Variable =
    'DRAINC'
    # 'SWE'
    # 'EVAPC'
    # 'SWI'

## 2. Domaine ________________________________________________________
# Couverture spatiale des données
NCf$title.02.Domain =
    'France'
    # 'Garonne'
    # 'Loire'
    # 'Seine'

## 3. GCM-Inst-Model _________________________________________________
# Identifiant du GCM forçeur = Institut-Modèle
NCf$title.03.GCM_Inst_Model = 
 'CNRM-CERFACS-CNRM-CM5'
 # 'MOHC-HadGEM2-ES'
 # 'ICHEC-EC-EARTH'
 # 'MPI-M-MPI-ESM-LR'
 # 'IPSL-IPSL-CM5A-MR'
 # 'NCC-NorESM1-M'

## 4. Experiment _____________________________________________________
# Identifiant de l’expérience historique ou future via le scénario
NCf$title.04.Experiment =
    'rcp26'
    # 'rcp45'
    # 'rcp85'
    # 'historical'

## 5. Member _________________________________________________________
# Numéro du membre de l'ensemble
NCf$title.05.Member =
    'r1i1p1 '
    # 'r12i1p1'

## 6. RCM-Inst-Model _________________________________________________
# Identifiant du RCM = Institut-Modèle
NCf$title.06.RCM_Inst_Model =
    'CLMcom-CCLM4-8-17'
    # 'IPSL-WRF381P'
    # 'CNRM-ALADIN63'
    # 'KNMI-RACMO22E'
    # 'DMI-HIRHAM5'
    # 'MPI-CSC-REMO2009'
    # 'GERICS-REMO2015'
    # 'SMHI-RCA4'
    # 'ICTP-RegCM4-6'

## 7. Version ________________________________________________________
# Identifiant de l’expérience historique ou future via le scénario
# (en minuscule)
NCf$title.07.Version =
    'v1'
    # 'v2'

## 8. Bc-Inst-Method-Obs-Period ______________________________________
# Identifiant de la méthode de correction de biais statistique =
# Institut-Méthode-Réanalyse-Période
NCf$title.08.Bc_Inst_Method_Obs_Period =
    'MF-ADAMONT-SAFRAN-1980-2011'
    # 'LSCE-R2D2-SAFRAN-1976-2005'

## 9. HYDRO-Inst-Model _______________________________________________
# Identifiant du HYDRO = Institut-Modèle
NCf$title.09.HYDRO_Inst_Model =
    'MF-SIM2'
    # 'BRGM-MONA'
    # '****-ORCHIDEE'
    # 'BRGM-EROS'
    # 'ENS-EauDyssee'
    # 'BRGM-AquiFR'
    # 'BRGM-Marthe'

## 10. TimeFrequency _________________________________________________
# Le pas de temps du jeu de données
NCf$title.10.TimeFrequency =
    'day'
    # '1hr'

## 11. Startyear-Endyear _____________________________________________
# Couverture temporelle des données sous forme YYYYMMDD-YYYYMMDD en
# année, YYYYMMDDHH-YYYYMMDDHH en heure et YYYYMMDDHHmm-YYYYMMDDHHmm
# en minute
NCf$title.11.StartTime_EndTime =
    '19700801-20050731'
    # '20060801-21000731'
    # '20060101-20991231'

## 12. Suffix ________________________________________________________
# Exceptionnellement – toute information permettant de distinguer des
# fichiers lorsque les éléments précédents ne le permettent pas.
# Exemple sur le calcul de l’ETP par des méthodes de calcul
# différentes.
NCf$title.12.Suffix = 
    ""
    # 'FAO'
    # 'Hg0175'
