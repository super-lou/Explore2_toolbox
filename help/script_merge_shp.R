# Copyright 2021-2024 Louis Héraut (louis.heraut@inrae.fr)*1,
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
# Explore2 R toolbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Explore2 R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


## SHP EXPLORE2 ______________________________________________________
shp_Explore2_dirpath = "/home/louis/Documents/bouleau/INRAE/data/Explore2/hydrologie/entiteHydro"

shp_GRSD_path = file.path(shp_Explore2_dirpath,
                          "GRSD", "entiteHydro_GRSD.shp")
shp_GRSD = sf::st_read(shp_GRSD_path)

shp_SMASH_path = file.path(shp_Explore2_dirpath,
                           "SMASH", "entiteHydro_SMASH.shp")
shp_SMASH = sf::st_read(shp_SMASH_path)

Code_SMASH = shp_SMASH$CODE
Code_GRSD = shp_GRSD$CODE


## SHP HYDRO _________________________________________________________
shp_HYDRO_dirpath = "/home/louis/Documents/bouleau/INRAE/data/map/entiteHydro"
shp_HYDRO_path = file.path(shp_HYDRO_dirpath, "BV_4207_stations.shp")
shp_HYDRO = sf::st_read(shp_HYDRO_path)

Code8_HYDRO = shp_HYDRO$Code

code_selection_path = "/home/louis/Documents/bouleau/INRAE/data/Explore2/hydrologie/Selection_points_simulation.csv"
code_selection = ASHE::read_tibble(code_selection_path)

Code8_HYDRO_match = match(Code8_HYDRO, code_selection$CODE)
Code8_HYDRO_match = Code8_HYDRO_match[!is.na(Code8_HYDRO_match)]
Code_HYDRO = code_selection$SuggestionCode[Code8_HYDRO_match]


## MERGE SHP EXPLORE2 ________________________________________________
Code_from_SMASH = Code_SMASH[!(Code_SMASH %in% Code_GRSD)]
Code = c(Code_GRSD, Code_from_SMASH)

shp_GRSD$MODEL = "GRSD"
shp_GRSD$XL93 = as.numeric(shp_GRSD$XL93)
shp_GRSD$YL93 = as.numeric(shp_GRSD$YL93)
shp_GRSD$XL93_MODEL = as.numeric(shp_GRSD$XL93_MODEL)
shp_GRSD$YL93_MODEL = as.numeric(shp_GRSD$YL93_MODEL)
shp_SMASH$MODEL = "SMASH"

shp_from_SMASH = dplyr::filter(shp_SMASH, CODE %in% Code_from_SMASH)
shp = dplyr::bind_rows(shp_GRSD, shp_from_SMASH)
shp = dplyr::arrange(shp, CODE)

shp_out_path = "/home/louis/Documents/bouleau/INRAE/data/Explore2/hydrologie/entiteHydro/unified/entiteHydro_Explore2.shp"
sf::st_write(shp, shp_out_path)

# library(ggplot2)
# map = ggplot() + theme_minimal() + coord_sf() + 
#     geom_sf(data=shp, fill=NA, color="grey20")

# ggsave(filename="map.png", plot=map, width=20, height=20, units="cm")
