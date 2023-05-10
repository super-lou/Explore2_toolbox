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


# import of install useful package
if (!require(ASHE)) remotes::install_github("super-lou/ASHE")


## 1. INFO ___________________________________________________________
### 1.1. Data directory ______________________________________________
data_dir = "./"
projs_path = "projs_selection.txt"

### 1.2. Chain _______________________________________________________
GCM = "CNRM-CM5"
EXP = "rcp26"
RCM = "ALADIN63"
BC = "ADAMONT"
Model = "J2000"

### 1.3. Which analyse _______________________________________________
# Explore2_proj_serie :
#     Sélection de critères pour QUALYPSO
# Explore2_proj_check :
#     tQJXA et tVCN10 pour vérifier que les événements de crue et
#     d'étiage soient bien centrés dans les années hydrologiques
#     (i.e. début fixé au mois du minimum des débits pour les crues
#     et du 1er mai au 30 novembre pour les étiages).
#     Le début de l'année hydrologique pour chaque variable de crue de
#     l'analyse Explore2_proj_serie est donnée par le mois des dates
#     de chaque année. 
analyse =
    "Explore2_proj_serie"
    # "Explore2_proj_check"


## 3. EXECUTION (do not modify if you are not aware) _________________
chain_dir = file.path(Model,
                      paste(GCM, EXP, RCM, BC, Model, sep="_"))
meta_path = file.path(data_dir,
                      chain_dir,
                      "meta.fst")
dataEX_path = file.path(data_dir,
                        chain_dir,
                        paste0("dataEX_", analyse, ".fst"))
metaEX_path = file.path(data_dir,
                        chain_dir,
                        paste0("metaEX_", analyse, ".fst"))

if (file.exists(projs_path)) {
    projs = ASHE::read_tibble(filepath=projs_path)
}
meta = ASHE::read_tibble(filepath=meta_path)
dataEX = ASHE::read_tibble(filepath=dataEX_path)
metaEX = ASHE::read_tibble(filepath=metaEX_path)

print(projs)
print(meta)
print(dataEX)
print(metaEX)
