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






# Syntaxe pour les données hydro-climatiques 2D à intégrer dans le
# portail DRIAS


library(dplyr)
library(ncdf4)











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
