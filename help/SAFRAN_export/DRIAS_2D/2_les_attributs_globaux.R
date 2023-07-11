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
# |___/  Les attributs globaux sont souvent récupérés des fichiers
# sources. Ils renseignent sur la réalisation de la simulation, de la
# descente d’échelle dynamique à la correction de biais, tous
# essentiels à la traçabilité. Il est demandé de recopier sans
# modifier les entrées.
#
# Les informations concernant la modélisation hydrologique : le
# modèle, l’institut, la date de mise en œuvre, les références, ...
# seront spécifiées par de nouveaux attributs avec le préfixe “hy_".
#
# Trois catégories d'attributs globaux sont attendus à propos :
# du couplage GCM/RCM, la correction de biais atmosphérique et la
# modélisation hydrologique :


## 1. SAFRAN _________________________________________________________
### 1.1. projet_id ___________________________________________________
# Identification du projet
# On mettra project_id = "DRIAS-2020" pour les couples de modèles de
# l’ensemble DRIAS-2020 ; pour les couples de modèles ajoutés dans le
# cadre du projet EXPLORE2 (dont tous ceux corrigés par la méthode
# CDF-t) on mettra :project_id = "EXPLORE2"
NCf$global.01.project_id =
    "EXPLORE2"
    # "DRIAS-2020"

### 1.2. observation_id ______________________________________________
# Une chaîne de caractères de la base d’observation utilisée pour
# corriger les données
NCf$global.02.observation = "SAFRAN-France and SAFRAN-Montagne Quintana-Segui P., Le Moigne P., Durand Y., Martin E., Habets F.,
Baillon M., Canellas C., Franchisteguy L., Morel S., 2008, Analysis of Near-Surface Atmospheric Variables : Validation of the
SAFRAN Analysis over France, Journal of Applied Meteorology and Climatology, 47, 92-107.
https://doi.org/10.1175/2007JAMC1636.1 "
NCf$global.03.observation_id = "SAFRAN-France-2022"

### 1.3. institute_id ________________________________________________
# Un nom court du centre de production de la réanalyse SAFRAN
NCf$global.04.institution = "Meteo-France"
NCf$global.05.institute_id = "MF"

### 1.4. frequency ___________________________________________________
# L’intervalle de temps d’échantillonnage de la série de données
NCf$global.06.frequency = "day"

### 1.5. contact _____________________________________________________
# Fournit l’adresse électronique de la personne responsable des
# données
NCf$global.07.contact = "jean-michel.soubeyroux@meteo.fr"

### 1.6. creation_date _______________________________________________
# La date à laquelle la réanalyse SAFRAN-France a été réalisée
NCf$global.08.creation_date = "2022-10-13T14:25:48Z"


## 2. MODÉLISATION HYDROLOGIQUE ______________________________________
### 2.1. product _____________________________________________________
# Une chaîne de caractères indiquant la méthodologie pour créer cet
# ensemble de données
NCf$global.09.product = "hydro-climatique"

### 2.2. hy_projet_id ________________________________________________
# Identification du projet
NCf$global.10.hy_projet_id = "EXPLORE2"

### 2.3. hy_institute_id _____________________________________________
# Un nom d’identification court du centre de modélisation contribuant
# aux données
NCf$global.11.hy_institute_id = "Meteo-France"

### 2.4. hy_model_id _________________________________________________
# Un acronyme qui identifie le modèle hydrologique
NCf$global.12.hy_model_id = "SIM2"

### 2.5. hy_version_id _______________________________________________
NCf$global.13.hy_version_id = "V8F"

### 2.6. hy_creation_date ____________________________________________
# La date à laquelle la simulation a été réalisée
NCf$global.14.hy_creation_date = "2023-01-20T17:53:28Z"

### 2.7. hy_contact __________________________________________________
# Fournit le nom ou l’adresse électronique de la personne responsable
# des données
NCf$global.15.hy_contact = "driascontact@meteo.fr"
