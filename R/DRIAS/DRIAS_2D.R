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


## 1. COHÉRENCE CROISÉE ______________________________________________
# La mise en place d’un double niveau d’information (éléments du nom
# du fichier et métadonnées) nécessite de contrôler la cohérence entre
# les deux, mais est primordiale car contribue à la qualité du jeu de
# données. Tout comme la standardisation des unités et des noms est
# primordiale pour éviter les confusions et simplifier le traitement
# des données par les utilisateurs.
#
#
# Exemple de variables hydrologiques :
#
# ----------+--------+-------------------------+-------+-------------
# Accronyme | Name   | Long name               | Units | Cell methods
# ----------+--------+-------------------------+-------+-------------
# DRAINC     DRAINC   Drainage for tile nature  mm      time:sum 
# EVAPC      EVAPC    Evapotranspiration        mm      time:sum
# RUNOFFC    RUNOFFC  Runoff for tile nature    mm      time:sum
# SWE        SWE      Snow Water Equivalent     mm      time:mean ?
# SWI        SWI      Soil Water Index          -       time:mean ?
# ----------+--------+-------------------------+-------+-------------
#
# Voir aussi :
# CF Standard Name Table = http://cfconventions.org/Data/cf-standard-names/current/build/cf-standard-name-table.html
# IPCC Standard Output from Coupled Ocean-Atmosphere GCMs = https://pcmdi.llnl.gov/mips/cmip3/variableList.html
# CMIP5-CMOR-Tables = https://wcrp-cmip.github.io/WGCM_Infrastructure_Panel//cmor_and_mip_tables.html
# Data Reference Syntax (DRS) for bias-adjusted CORDEX = http://is-enes-data.github.io/CORDEX_adjust_drs.pdf


## 0. LIBRARY ________________________________________________________
library(dplyr)
library(ncdf4)





## 1. NOM DU FICHIER _________________________________________________
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


## 2. LES DIMENSIONS _________________________________________________
### 2.1. Le temps ____________________________________________________
from = as.POSIXct(date_de_debut, tz=fuseau_horaire)
to = as.POSIXct(date_de_fin, tz=fuseau_horaire)
time = seq.POSIXt(from=from, to=to, by=pas_de_temps)
time = as.numeric(time - from) / 86400
time_units = paste0(pas_de_temps, " since ", from)
time_dim = ncdim_def("time",
                     units=time_units,
                     vals=time,
                     unlim=TRUE,
                     calendar="standard",
                     longname="time")

### 2.2. L'axe X _____________________________________________________
X_dim = ncdim_def("projection_x_coordinate",
                  longname="x coordinate of projection",
                  units=unite_de_X,
                  vals=X)

### 2.3. L'axe Y _____________________________________________________
Y_dim = ncdim_def("projection_y_coordinate",
                  longname="y coordinate of projection",
                  units=unite_de_Y,
                  vals=Y)

### 2.4. L'axe Z _____________________________________________________
if (!is.null(Z)) {
    Z_dim = ncdim_def("z_coordinate",
                      longname="z coordinate",
                      units=unite_de_Z,
                      vals=Z)
} else {
    Z_dim = NULL
}


## 3. ATTRIBUTS GLOBAUX ______________________________________________
