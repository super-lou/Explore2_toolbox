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



#  ___   ___  ___    _    ___    _  ___  
# |   \ | _ \|_ _|  /_\  / __|  / ||   \ 
# | |) ||   / | |  / _ \ \__ \  | || |) |
# |___/ |_|_\|___|/_/ \_\|___/  |_||___/ 

library(dplyr)
library(ncdf4)


## 1. NOM DU FICHIER _________________________________________________
# Les éléments composant le nom du fichier fournissent rapidement des
# informations sur la simulation et s’écrit comme ce qui suit :
#
#     Variable_Domain_GCM-Inst-Model_Experiment_Member_
#     RCM-Inst-Model_Version_Bc-Inst-Method-Obs-Period_
#     HYDRO-Inst-Model_TimeFrequency_StartTime-EndTime_Suffix.nc

### 1.1. Variable ____________________________________________________
# Le nom de la variable, sera à la lettre près identique au nom de la
# variable du fichier
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


## 2. ATTRIBUTS GLOBAUX ______________________________________________
# Les attributs globaux sont souvent récupérés des fichiers sources.
# Ils renseignent sur la réalisation de la simulation, de la descente
# d’échelle dynamique à la correction de biais, tous essentiels à la
# traçabilité. Il est demandé de recopier sans modifier les entrées.
# Les informations concernant la modélisation hydrologique : le
# modèle, l’institut, la date de mise en œuvre, les références, ...
# seront spécifiées par de nouveaux attributs avec le préfixe “hy_"
# (attributs repérés en vert).
#
# Les attributs globaux attendus concernent, en bleu le couplage
# GCM/RCM, en orange la correction de biais atmosphérique et en vert
# la modélisation hydrologique :

### 2.1. Couplage GCM/RCM ____________________________________________
#### 2.1.1. projet_id ________________________________________________
# Identification du projet
project_id =
    "DRIAS-2020"

#### 2.1.2. forcing __________________________________________________
# Une chaîne de caractères indiquant le modèle de forçage de cette
# simulation
forcing =
    "ALADIN63 with CNRM-CM5 forcing data"

#### 2.1.3. driving_* ________________________________________________
# Des chaînes de caractères caractérisant le modèle forçeur dans la
# descente d’échelle dynamique
driving_model_id =
    "CNRM-CERFACS-CNRM-CM5"
driving_model_ensemble_member =
    "r1i1p1"
driving_experiment_name =
    "rcp85"
driving_experiment =
    "CNRM-CERFACS-CNRM-CM5, rcp85, r1i1p1"

#### 2.1.4. institute_id _____________________________________________
# Un nom court du centre de modélisation contribuant aux données avant
# correction
institution =
    "CNRM (Centre National de Recherches Meteorologiques, Toulouse 31057, France)"
institute_id =
    "CNRM"

#### 2.1.5. model_id _________________________________________________
# Un acronyme qui identifie le modèle utilisé pour générer les
# données avant correction
model_id =
    "CNRM-ALADIN63"
rcm_version_id =
    "v2"

#### 2.1.6. experiment_id ____________________________________________
# Un nom d’identification court de l’expérience (scénario ou historique)
experiment =
    "RCP8.5 run with GCM forcing"
experiment_id =
    "rcp85"

#### 2.1.7. frequency ________________________________________________
# L’intervalle de temps d’échantillonnage de la série de données
frequency =
    "day"

#### 2.1.8. contact __________________________________________________
# Fournit l’adresse électronique de la personne responsable des
# données
contact =
    "contact.aladin-cordex@meteo.fr"

#### 2.1.9. creation_date ____________________________________________
# La date à laquelle la simulation a été réalisée
creation_date =
    "2018-11-19T14:35:23Z"

#### 2.1.10. comment _________________________________________________
# Informations sur l’initialisation de la simulation ou fournit des
# références littéraires
comment =
    "CORDEX Europe EUR-11 CNRM-ALADIN 6.3 L91 CNRM-CERFACS-CNRM-CM5: EUC12v63-3.02. Reference : Daniel M., Lemonsu A., Déqué M., Somot S., Alias A., Masson V. (2018) Benefits of explicit urban parametrization in regional climate modelling to study climate and city interactions. Climate Dynamics, 1-20, doi:10.1007/s00382-018-4289-x"
driving_experiment_comment =
    "Known issue correction: this simulation (named v2) is not affected by the error previously identified in the lateral boundary conditions files of CNRM-CERFACS-CNRM-CM5"

### 2.2. Correction de biais atmosphérique ___________________________
#### 2.2.1. bc_institute_id __________________________________________
# Un nom d’identification court du centre qui a mis en œuvre la
# correction de biais
bc_institute_id =
    "Meteo-France"

#### 2.2.2. bc_contact_id ____________________________________________
# Fournit l’adresse électronique de la personne responsable des données
bc_contact =
    "driascontact@meteo.fr"

#### 2.2.3. bc_creation_date _________________________________________
# La date à laquelle la correction de biais a été faite
bc_creation_date =
    "2022-01-26T17:59:46Z"

#### 2.2.4. bc_method_id _____________________________________________
# Une chaîne de caractères indiquant la méthode de correction de biais
bc_method =
    "ADAMONT method - Verfaillie, D., Déqué, M., Morin, S., and Lafaysse, M. : The method ADAMONT v1.0 for statistical adjustment of climate projections applicable to energy balance land surface models, Geosci. Model Dev., 10, 4257-4283, https://doi.org/10.5194/gmd-10-4257-2017, 2017."
bc_method_id =
    "ADAMONT-France"

#### 2.2.5. bc_observation_id ________________________________________
# Une chaîne de caractères de la base d’observation utilisée pour
# corriger les données
bc_observation =
    "SAFRAN-France and SAFRAN-Montagne Quintana-Segui P., Le Moigne P., Durand Y., Martin E., Habets F., Baillon M., Canellas C., Franchisteguy L., Morel S., 2008, Analysis of Near-Surface Atmospheric Variables : Validation of the SAFRAN Analysis over France, Journal of Applied Meteorology and Climatology, 47, 92-107. https://doi.org/10.1175/2007JAMC1636.1"
bc_observation_id =
    "SAFRAN-France-2016"

#### 2.2.6. bc_domain ________________________________________________
# Une chaîne de caractères indiquant le domaine d’application de la
# méthode de correction
bc_domain =
    "FR-France"

#### 2.2.7. bc_period ________________________________________________
# Période sur laquelle a été appliqué la phase d’apprentissage de la
# méthode de correction
bc_period_ref =
    "1980-2011"
bc_period_rcm =
    "1974-2005"

#### 2.2.8. bc_info __________________________________________________
# Une compilation des attributs : bc_institute_id "-" bc_method_id
# "-" bc_observation_id en accord avec Bc-Inst-Method
bc_info =
    "Météo-France-ADAMONT-France_SAFRAN-France-2016"

#### 2.2.9. bc_comment _______________________________________________
# Complément d’information sur la méthode de correction ou fournit
# des références littéraires
bc_comment =
    "Weather Regime dependant BC methode"
Conventions =
    "CF-1.6"

### 2.3. Modélisation hydrologique ___________________________________
#### 2.3.1. product __________________________________________________
# Une chaîne de caractères indiquant la méthodologie pour créer cet
# ensemble de données
product =
    "hydro-climatique"

#### 2.3.2. hy_projet_id _____________________________________________
# Identification du projet
hy_projet_id =
    "EXPLORE2-2021"

#### 2.3.3. hy_institute_id __________________________________________
# Un nom d’identification court du centre de modélisation contribuant
# aux données
hy_institute_id =
    "Meteo-France"

#### 2.3.4. hy_model_id ______________________________________________
# Un acronyme qui identifie le modèle hydrologique
hy_model_id =
    "SIM2"

#### 2.3.5. hy_version_id ____________________________________________
hy_version_id =
    "V8F"

#### 2.3.6. hy_creation_date _________________________________________
# La date à laquelle la simulation a été réalisée
hy_creation_date =
    "2021-01-20T17:53:28Z"

#### 2.3.7. hy_contact _______________________________________________
# Fournit le nom ou l’adresse électronique de la personne responsable
# des données
hy_contact =
    "driascontact@meteo.fr"


## 3. LES DIMENSIONS _________________________________________________
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
#         y:units = "m" ;
#         y:axis = "Y" ;


## 4. LES COORDONNÉES ________________________________________________
# Les coordonnées spatiales acceptées :
# • en 2 ou 3 dimensions : lat(y, x) lon(y, x) / lat(z, y, x)
#                          lon(z, y, x) alt(z, y, x) →
#                          var(time, y, x) / var(time, z, y, x)
#
# Éviter tout autre format (comme lat(y), lon(x) → var(time, y, x))
# qui ne sera pas lu correctement par les scripts de traitement et
# logiciel graphique. La couverture spatiale est conforme aux
# déclarations, enfin le nombre de point concorde avec la grille de
# projection utilisée.
#
# Les variables représentant la latitude ou la longitude doivent
# toujours inclure explicitement l’attribut units ; il n’y a pas de
# valeur par défaut. L’attribut units est une chaîne de caractères et
# les unités attendues sont les suivantes : lat:units =
# "degrees_north" ; lon:units = "degrees_east" ;
#
# Naturellement les valeurs des dimensions sont croissantes et n’ont
# pas de valeur manquante.
#
# Les attributs des coordonnées attendus :
# - standard_name, un nom d’identification court de la coordonnée.
# - units, spécifie l’unité de la variable coordonnée.
# - _CoordinateAxisType ou axis, spécifie s’il s’agit d’une coordonnée
#   spatiale (et laquelle) ou temporelle.



## 5. LA PROJECTION DE LA GRILLE _____________________________________
# La projection de la grille doit être référencée par une variable de
# données afin de déclarer explicitement le système de référence des
# coordonnées (CRS) utilisé pour les valeurs des coordonnées spatiales
# horizontales. Par exemple, si les coordonnées spatiales horizontales
# sont la latitude et la longitude, la variable de projection de la
# grille peut être utilisée pour déclarer la figure de la terre
# (ellipsoïde WGS84, sphère, etc.) sur laquelle elles sont basées. Si
# les coordonnées spatiales horizontales sont des abscisses et des
# ordonnées dans une projection cartographique, la variable de
# projection de la grille déclare la projection cartographique CRS
# utilisée et fournit les informations nécessaires pour calculer la
# latitude et la longitude à partir des abscisses et des ordonnées.
#
# La variable de projection de la grille LambertParisII (grille à
# privilégier – sinon veuillez contacter le service DRIAS) contient
# les paramètres de mappage en tant qu’attributs, et est associée à la
# variable Température via son attribut grid_mapping.
#
#
# Un exemple :
#
# variables:
#     double lon(y, x) ;
#         lon:standard_name = "longitude" ;
#         lon:long_name = "longitude coordinate" ;
#         lon:units = "degrees_east" ;
#         lon:_CoordinateAxisType = "Lon" ;
#     double lat(y, x) ;
#         lat:standard_name = "latitude" ;
#         lat:long_name = "latitude coordinate" ;
#         lat:units = "degrees_north" ;
#         lat:_CoordinateAxisType = "Lat" ;
#     int LambertParisII ;
#         LambertParisII:grid_mapping_name = "lambert_conformal_conic_1SP" ;
#         LambertParisII:latitude_of_origin = 52.f ;
#         LambertParisII:central_meridian = 0.f ;
#         LambertParisII:scale_factor = 0.9998774f ;
#         LambertParisII:false_easting = 600000.f ;
#         LambertParisII:false_northing = 2200000.f ;
#         LambertParisII:epsg = "27572" ;
#         LambertParisII:references = "https://spatialreference.org/ref/epsg/ntf-paris-lambert-zone-ii/" ;




## 6. COORDONNÉE VERTICALE (ALTITUDE OU PROFONDEUR) __________________
# S’il existe une variable de coordonnée verticale, elle sera définie
# selon l’axe ‘z’, elle doit toujours inclure explicitement l’attribut
# units, car il n’y a pas de valeur par défaut.
# L’attribut ‘positive’, indique la direction dans laquelle les
# valeurs des coordonnées augmentent, qu’elle soit ascendante ou
# descendante (valeur up ou down). L’attribut units est une chaîne de
# caractères et les unités attendues sont :
# unité de longueur : alt:units = "meter" ;       :units = "m" ;
# unité de pression : depth:units = "pascal" ;    :units = "Pa" ;
#
# Naturellement les valeurs des dimensions sont croissantes et n’ont
# pas de valeur manquante.
#
# Pour exprimer des niveaux d’altitude :
#     double alt(z) ;
#         alt:standard_name = “height”;
#         alt:long_name = "height above mean sea level" ;
#         alt:units = "meter" ;
#         alt:positive = "up" ;
#         alt:axis = "Z"
#
# Pour exprimer des niveaux souterrains :
#     double depth(z) ;
#         depth:standard_name = “depth”;
#         depth:long_name = "depth_below_geoid" ;
#         depth:units = "pascal" ;
#         depth:positive = "down" ;
#         depth:axis = "Z"






## 7. LA VARIABLE ____________________________________________________
# Les dimensions de la variable sont au même nombre que les axes spécifiés précédemment et sont définies de la même manière (nom et grandeur). L’ordre des indices souhaité dépend du type des dimensions :
# • var (time, z, y, x)

# Le nom de la variable est typiquement un acronyme qui suit les références des tables MIP et auquel est associé un nom court ou long et une unité standard. Bien sûr il est identique au nom de la variable dans le nom du fichier.

    
# Les attributs de la variable attendus :

- standard_name, un nom d’identification court de la variable.
• SWI:standard_name = "SWI" ;
• SWI:long_name = "Soil Water Index" ;
- units, spécifie l’unité de la variable coordonnée.
• SWI:units = " " ;
- grid_mapping, indique le nom de la ‘Projection’ (exemple ‘LambertParisII’) pour assurer la connexion.
• SWI:grid_mapping = "LambertParisII" ;
7/9
- coordinates, fournit l’information de dimension scalaire ou le label d’une sous-région géographique.
• SWI:coordinates = "lat lon" ;
- missing_value et _Fillvalue, spécifie comment sont identifiés les valeurs manquantes.
• SWI:_FillValue = NaNf ;
• SWI:missing_value = NaNf ;
- cell_methods, fournit l’information concernant le calcul ou l’extraction de la variable.
• SWI:cell_methods = "time: mean" ;
- comment, complément d’information sur l’extraction, le calcul de la variable
• evspsblpotAdjust:comment =
      "Potential evapotranspiration calculated using the Hargreaves method with
unique coefficient 0.175 from DRIAS-2020 corrected data set (the variable rsdsAdjust is not used).
Source : ........."
#
#
# Un exemple :
#
# variables:
#     float SWI(time, y, x) ;
#         SWI:standard_name = "SWI" ;
#         SWI:long_name = "Soil Water Index" ;
#         SWI:units = " " ;
#         SWI:grid_mapping = "LambertParisII" ;
#         SWI:coordinates = "lat lon" ;
#         SWI:_FillValue = NaNf ;
#         SWI:missing_value = NaNf ;
#         SWI:cell_methods = "time:mean" ;





7. Cohérence croisée :
La mise en place d’un double niveau d’information (éléments du nom du fichier et métadonnées) nécessite de contrôler la
cohérence entre les deux, mais est primordiale car contribue à la qualité du jeu de données. Tout comme la standardisation
des unités et des noms est primordiale pour éviter les confusions et simplifier le traitement des données par les utilisateurs.
Exemple de variables hydrologiques :
Accronyme
 standard name
 long name
DRAINC
 DRAINC
 Drainage for tile nature
EVAPC
 EVAPC
 Evapotranspiration
RUNOFFC
 RUNOFFC
 Runoff for tile nature
SWE
 SWE
 Snow Water Equivalent
SWI
 SWI
 Soil Water Index
units
mm
mm
mm
mm
-
cell_methods
time:sum
time:sum
time:sum
time:mean ?
time:mean ?
8/9
CF Standard Name Table = http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
IPCC Standard Output from Coupled Ocean-Atmosphere GCMs = https://pcmdi.llnl.gov/mips/cmip3/variableList.html
CMIP5-CMOR-Tables = https://wcrp-cmip.github.io/WGCM_Infrastructure_Panel//cmor_and_mip_tables.html
Data Reference Syntax (DRS) for bias-adjusted CORDEX = http://is-enes-data.github.io/CORDEX_adjust_drs.pdf






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



data = list()
# create netCDF file and put arrays
NCdata = nc_create(filename, data, force_v4=TRUE)
