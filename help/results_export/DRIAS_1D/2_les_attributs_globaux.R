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


#  _                   _    _         _  _           _       
# | | ___  ___   __ _ | |_ | |_  _ _ (_)| |__  _  _ | |_  ___
# | |/ -_)(_-<  / _` ||  _||  _|| '_|| || '_ \| || ||  _|(_-<
# |_|\___|/__/  \__,_| \__| \__||_|  |_||_.__/ \_,_| \__|/__/
#        _       _                     
#  __ _ | | ___ | |__  __ _  _  _ __ __
# / _` || |/ _ \| '_ \/ _` || || |\ \ /
# \__, ||_|\___/|_.__/\__,_| \_,_|/_\_\ ______________________________
# |___/ Les attributs globaux sont souvent récupérés des fichiers
# sources. Ils renseignent sur la réalisation de la simulation, s’il
# s’agit d’une descente d’échelle dynamique ils contiennent les
# informations sur le forçage aux conditions aux limites (GCM) qui
# sont essentiels à la traçabilité. Les informations concernant la
# correction de biais (méthode, institut, date de mise en œuvre,
# référence) sont spécifiés dans les attributs avec le préfixe "bc_".


## 1. COUPLAGE GCM/RCM _______________________________________________
### 1.1. projet_id ___________________________________________________
# Identification du projet
NCf$global.01.project_id = "DRIAS-2020"

### 1.2. forcing _____________________________________________________
# Une chaîne de caractères indiquant le modèle de forçage de cette
# simulation
NCf$global.02.forcing = paste0(dataEX$RCM[1], " with ",
                               dataEX$GCM[1], " forcing data")

### 1.3. driving_* ___________________________________________________
# Des chaînes de caractères caractérisant le modèle forçeur dans la
# descente d’échelle dynamique
NCf$global.03.driving_model_id = 
    meta_projection$gcm[projection_ok]
    #"CNRM-CERFACS-CNRM-CM5"
NCf$global.04.driving_model_ensemble_member =
    meta_projection$member[projection_ok]
    # "r1i1p1"
NCf$global.05.driving_experiment_name =
    dataEX$EXP[1]
    # "rcp85"
NCf$global.06.driving_experiment =
    paste0(NCf$global.03.driving_model_id, ", ",
           NCf$global.05.driving_experiment_name, ", ",
           NCf$global.04.driving_model_ensemble_member)
    # "CNRM-CERFACS-CNRM-CM5, rcp85, r1i1p1"

### 1.4. institute_id ________________________________________________
# Un nom court du centre de modélisation contribuant aux données avant
# correction
NCf$global.07.institution =
    meta_projection$institution[projection_ok]
# "CNRM (Centre National de Recherches Meteorologiques, Toulouse 31057, France)"
NCf$global.08.institute_id =
    meta_projection$institution.id[projection_ok]
    # "CNRM"

### 1.5. model_id ____________________________________________________
# Un acronyme qui identifie le modèle utilisé pour générer les
# données avant correction
NCf$global.09.model_id =
    meta_projection$rcm[projection_ok]
    # "CNRM-ALADIN63"
NCf$global.10.rcm_version_id =
    meta_projection$version[projection_ok]
    # "v2"

### 1.6. experiment_id _______________________________________________
# Un nom d’identification court de l’expérience (scénario ou historique)
RCP = toupper(gsub(".*[-]", "", dataEX$EXP[1]))
RCP = paste0(substr(RCP, 1, 4), ".", substr(RCP, 5, 5))
NCf$global.11.experiment = paste0("historical+", RCP,
                                  " run with GCM forcing")
NCf$global.12.experiment_id = dataEX$EXP[1]

### 1.7. frequency ___________________________________________________
# L’intervalle de temps d’échantillonnage de la série de données
NCf$global.13.frequency = "day"

### 1.8. contact _____________________________________________________
# Fournit l’adresse électronique de la personne responsable des
# données
NCf$global.14.contact = meta_projection$contact[projection_ok]
    # "contact.aladin-cordex@meteo.fr"

### 1.9. creation_date _______________________________________________
# La date à laquelle la simulation a été réalisée
NCf$global.15.creation_date = meta_projection$creation[projection_ok]
    # "2018-11-19T14:35:23Z"
    
### 1.10. comment ____________________________________________________
# Informations sur l’initialisation de la simulation ou fournit des
# références littéraires
NCf$global.16.comment = "CORDEX Europe EUR-11 CNRM-ALADIN 6.3 L91 CNRM-CERFACS-CNRM-CM5: EUC12v63-3.02. Reference : Daniel M., Lemonsu A., Déqué M., Somot S., Alias A., Masson V. (2018) Benefits of explicit urban parametrization in regional climate modelling to study climate and city interactions. Climate Dynamics, 1-20, doi:10.1007/s00382-018-4289-x"
NCf$global.17.driving_experiment_comment = "Known issue correction: this simulation (named v2) is not affected by the error previously identified in the lateral boundary conditions files of CNRM-CERFACS-CNRM-CM5"


## 2. CORRECTION DE BIAIS ATMOSPHÉRIQUE ______________________________
### 2.1. product _____________________________________________________
# Une chaîne de caractères indiquant la méthodologie pour créer cet
# ensemble de données.
NCf$global.18.product = "bias-correction"

### 2.2. bc_institute_id _____________________________________________
# Un nom d’identification court du centre qui a mis en œuvre la
# correction de biais
NCf$global.19.bc_institute_id = "Meteo-France"

### 2.3. bc_contact_id _______________________________________________
# Fournit l’adresse électronique de la personne responsable des données
NCf$global.20.bc_contact = "driascontact@meteo.fr"

### 2.4. bc_creation_date ____________________________________________
# La date à laquelle la correction de biais a été faite
NCf$global.21.bc_creation_date = "2022-01-26T17:59:46Z"

### 2.5. bc_method_id ________________________________________________
# Une chaîne de caractères indiquant la méthode de correction de biais
NCf$global.22.bc_method = "ADAMONT method - Verfaillie, D., Déqué, M., Morin, S., and Lafaysse, M. : The method ADAMONT v1.0 for statistical adjustment of climate projections applicable to energy balance land surface models, Geosci. Model Dev., 10, 4257-4283, https://doi.org/10.5194/gmd-10-4257-2017, 2017."
NCf$global.23.bc_method_id = "ADAMONT-France"

### 2.6. bc_observation_id ___________________________________________
# Une chaîne de caractères de la base d’observation utilisée pour
# corriger les données
NCf$global.24.bc_observation = "SAFRAN-France and SAFRAN-Montagne Quintana-Segui P., Le Moigne P., Durand Y., Martin E., Habets F., Baillon M., Canellas C., Franchisteguy L., Morel S., 2008, Analysis of Near-Surface Atmospheric Variables : Validation of the SAFRAN Analysis over France, Journal of Applied Meteorology and Climatology, 47, 92-107. https://doi.org/10.1175/2007JAMC1636.1"
NCf$global.25.bc_observation_id = "SAFRAN-France-2016"

### 2.7. bc_domain ___________________________________________________
# Une chaîne de caractères indiquant le domaine d’application de la
# méthode de correction
NCf$global.26.bc_domain = "FR-France"

### 2.8. bc_period ___________________________________________________
# Période sur laquelle a été appliqué la phase d’apprentissage de la
# méthode de correction
NCf$global.27.bc_period_ref = "1980-2011"
NCf$global.28.bc_period_rcm = "1974-2005"

### 2.9. bc_info _____________________________________________________
# Une compilation des attributs : bc_institute_id "-" bc_method_id
# "-" bc_observation_id en accord avec Bc-Inst-Method
NCf$global.29.bc_info = "Météo-France-ADAMONT-France_SAFRAN-France-2016"

### 2.10. bc_comment _________________________________________________
# Complément d’information sur la méthode de correction ou fournit
# des références littéraires
NCf$global.30.bc_comment = "Weather Regime dependant BC methode"
NCf$global.31.Conventions = "CF-1.6"


## 3. MODÉLISATION HYDROLOGIQUE ______________________________________
### 3.1. product _____________________________________________________
# Une chaîne de caractères indiquant la méthodologie pour créer cet
# ensemble de données
NCf$global.31.product = "hydro-climatique"

### 3.2. hy_projet_id ________________________________________________
# Identification du projet
NCf$global.32.hy_projet_id = "EXPLORE2"

### 3.3. hy_institute_id _____________________________________________
# Un nom d’identification court du centre de modélisation contribuant
# aux données
NCf$global.33.hy_institute_id = "Meteo-France"

### 3.4. hy_model_id _________________________________________________
# Un acronyme qui identifie le modèle hydrologique
NCf$global.34.hy_model_id = "SIM2"

### 3.5. hy_version_id _______________________________________________
NCf$global.35.hy_version_id = "V8F"

### 3.6. hy_creation_date ____________________________________________
# La date à laquelle la simulation a été réalisée
NCf$global.36.hy_creation_date = "2021-01-20T17:53:28Z"

### 3.7. hy_contact __________________________________________________
# Fournit le nom ou l’adresse électronique de la personne responsable
# des données
NCf$global.37.hy_contact = "driascontact@meteo.fr"


## 4. INDICATEUR HYDROLOGIQUE ________________________________________
### 4.1. indicator_institute _________________________________________
# Un nom d’identification court du centre de modélisation contribuant
# aux données
NCf$global.31.indicator_institute = "Meteo-France, DCSC"

### 4.2. indicator_frequency _________________________________________
# L’intervalle de temps d’échantillonnage de la série de données
NCf$global.32.indicator_frequency = "mon"

### 4.3. indicator_statistics_id _____________________________________
# Opération d’agrégation temporelle ou spatiale
NCf$global.33.indicator_statistics_id = "TimMEAN"
NCf$global.34.indicator_statistics_comment = "time average over the time period"

### 4.4. indicator_ref _______________________________________________
# Période de la référence. (si approprié)
NCf$global.35.indicator_ref = "19760101-20051231"

### 4.5. indicator_creation_date _____________________________________
# La date à laquelle on a calculé l’indicateur
NCf$global.36.indicator_creation_date = "2023-06-16T17:59:46Z"
