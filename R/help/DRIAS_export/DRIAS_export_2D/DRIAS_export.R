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


#  ___   ___  ___    _    ___                               _   
# |   \ | _ \|_ _|  /_\  / __|    ___ __ __ _ __  ___  _ _ | |_ 
# | |) ||   / | |  / _ \ \__ \   / -_)\ \ /| '_ \/ _ \| '_||  _|
# |___/ |_|_\|___|/_/ \_\|___/   \___|/_\_\| .__/\___/|_|   \__| ______
# Export pour le portail DRIAS des données |_| hydro-climatiques 


if (!require (NCf)) remotes::github_install("super-lou/NCf")

initialise_NCf()

list_path = list.files(getwd(), pattern='*.R$', full.names=TRUE)
list_path = list_path[!grepl("DRIAS_export.R", list_path)]
for (path in list_path) {
    source(path, encoding='UTF-8')    
}

data_dir = "data_NetCDF"
if (!(file.exists(data_dir))) {
    dir.create(data_dir)
}

generate_NCf(out_dir=data_dir)
