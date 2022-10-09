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

#  ___   ___  ___    _    ___    ___  ___  
# |   \ | _ \|_ _|  /_\  / __|  |_  )|   \ 
# | |) ||   / | |  / _ \ \__ \   / / | |) |
# |___/ |_|_\|___|/_/ \_\|___/  /___||___/ ___________________________
# Syntaxe pour les données hydro-climatiques 2D à intégrer dans le
# portail DRIAS

#  ___   ___  ___    _    ___        _          _    _            
# |   \ | _ \|_ _|  /_\  / __|   ___| |_  __ _ | |_ (_) ___  _ _  
# | |) ||   / | |  / _ \ \__ \  (_-<|  _|/ _` ||  _|| |/ _ \| ' \ 
# |___/ |_|_\|___|/_/ \_\|___/  /__/ \__|\__,_| \__||_|\___/|_||_| ___


## 1. NOM DU FICHIER _________________________________________________
# Les éléments composant le nom du fichier fournissent rapidement des
# informations sur la simulation et s’écrit comme ce qui suit :
#
#     Variable_Domain_GCM-Inst-Model_Experiment_Member_
#     RCM-Inst-Model_Version_Bc-Inst-Method-Obs-Period_
#     HYDRO-Inst-Model_TimeFrequency_StartTime-EndTime_Suffix.nc

### 1.1. Variable ____________________________________________________
# Le nom de la variable, sera à la lettre près identique au nom de la
# variable du fichier.
Variable =
    'DRAINC'
    # 'SWE'
    # 'EVAPC'
    # 'SWI'

# Sii les données sont corrigées
Adjust =
    FALSE
    # TRUE

### 1.2. Domaine _____________________________________________________
# Couverture spatiale des données
Domain =
    'France'
    # 'Garonne'
    # 'Loire'
    # 'Seine'

### 1.3. GCM-Inst-Model ______________________________________________
# Identifiant du GCM forçeur = Institut-Modèle
GCM_Inst_Model = 
 'CNRM-CERFACS-CNRM-CM5'
 # 'MOHC-HadGEM2-ES'
 # 'ICHEC-EC-EARTH'
 # 'MPI-M-MPI-ESM-LR'
 # 'IPSL-IPSL-CM5A-MR'
 # 'NCC-NorESM1-M'

### 1.4. Experiment __________________________________________________
# Identifiant de l’expérience historique ou future via le scénario
Experiment =
    'rcp26'
    # 'rcp45'
    # 'rcp85'
    # 'historical'

### 1.5. Member ______________________________________________________
# Numéro du membre de l'ensemble
Member =
    'r1i1p1 '
    # 'r12i1p1'

### 1.6. RCM-Inst-Model ______________________________________________
# Identifiant du RCM = Institut-Modèle
RCM_Inst_Model =
    'CLMcom-CCLM4-8-17'
    # 'IPSL-WRF381P'
    # 'CNRM-ALADIN63'
    # 'KNMI-RACMO22E'
    # 'DMI-HIRHAM5'
    # 'MPI-CSC-REMO2009'
    # 'GERICS-REMO2015'
    # 'SMHI-RCA4'
    # 'ICTP-RegCM4-6'

### 1.7. Version _____________________________________________________
# Identifiant de l’expérience historique ou future via le scénario
# (en minuscule)
Version =
    'v1'
    # 'v2'

### 1.8. Bc-Inst-Method-Obs-Period ___________________________________
# Identifiant de la méthode de correction de biais statistique =
# Institut-Méthode-Réanalyse-Période
Bc_Inst_Method_Obs_Period =
    'MF-ADAMONT-SAFRAN-1980-2011'
    # 'LSCE-R2D2-SAFRAN-1976-2005'

### 1.9. HYDRO-Inst-Model ____________________________________________
# Identifiant du HYDRO = Institut-Modèle
HYDRO_Inst_Model =
    'MF-SIM2'
    # 'BRGM-MONA'
    # '****-ORCHIDEE'
    # 'BRGM-EROS'
    # 'ENS-EauDyssee'
    # 'BRGM-AquiFR'
    # 'BRGM-Marthe'

### 1.10. TimeFrequency ______________________________________________
# Le pas de temps du jeu de données
TimeFrequency =
    'day'
    # '1hr'

### 1.11. Startyear-Endyear __________________________________________
# Couverture temporelle des données sous forme YYYYMMDD-YYYYMMDD en
# année, YYYYMMDDHH-YYYYMMDDHH en heure et YYYYMMDDHHmm-YYYYMMDDHHmm
# en minute
StartTime_EndTime =
    '19700801-20050731'
    # '20060801-21000731'
    # '20060101-20991231'

### 1.12. Suffix _____________________________________________________
# Exceptionnellement – toute information permettant de distinguer des
# fichiers lorsque les éléments précédents ne le permettent pas.
# Exemple sur le calcul de l’ETP par des méthodes de calcul
# différentes.
Suffix = 
    ""
    # 'FAO'
    # 'Hg0175'














if (Adjust) {
    Variable = paste0(Variable, "Adjust")
}

filename = paste(Variable, Domain, GCM_Inst_Model, Experiment, Member,
                 RCM_Inst_Model, Version, Bc_Inst_Method_Obs_Period,
                 HYDRO_Inst_Model, TimeFrequency, StartTime_EndTime,
                 sep="_")

if (Suffix != "") {
    filename = paste0(filename, "_", Suffix)
}

filename = paste0(filename, ".nc")

print("Nom du fichier : ")
print(filename)
