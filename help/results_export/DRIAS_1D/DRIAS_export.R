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


#  ___   ___  ___    _    ___                               _   
# |   \ | _ \|_ _|  /_\  / __|    ___ __ __ _ __  ___  _ _ | |_ 
# | |) ||   / | |  / _ \ \__ \   / -_)\ \ /| '_ \/ _ \| '_||  _|
# |___/ |_|_\|___|/_/ \_\|___/   \___|/_\_\| .__/\___/|_|   \__| ______
# Export pour le portail DRIAS des données |_| hydro-climatiques 

if (!require (remotes)) install.packages("remotes")
if (!require (NCf)) remotes::install_github("super-lou/NCf")

meta_projection_file = "tableau_metadata_EXPLORE2.csv"
meta_projection = ASHE::read_tibble(meta_projection_file)

data_dirpath = "/home/louis/Documents/bouleau/INRAE/data/Explore2/hydrologie/projection"
data_Paths = list.files(data_dirpath,
                        pattern="[.]nc$",
                        full.names=TRUE,
                        recursive=TRUE)

results_dirpath = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/results/projection/hydrologie"
Projection_path = file.path(results_dirpath, "projections_selection.csv")
Projection = ASHE::read_tibble(Projection_path)

Chain_dirpath = list.dirs(results_dirpath, recursive=FALSE)
Chain_dirpath = list.dirs(Chain_dirpath, recursive=FALSE)
Chain_dirpath = Chain_dirpath[!grepl("^SAFRAN[_]",
                                     basename(Chain_dirpath))]

# cut_date = as.Date("2004-07-31")

for (chain_dirpath in Chain_dirpath) {
    
    ###
    chain_dirpath = Chain_dirpath[1]
    ###

    regexp = gsub("historical[[][-][]]", "",
                  Projection$regexp[Projection$dir ==
                                    basename(chain_dirpath)])
    data_path = data_Paths[grepl(regexp, basename(data_Paths))]
    NC = ncdf4::nc_open(data_path)

    
    Var_path = list.files(chain_dirpath,
                          pattern="[.]fst",
                          full.names=TRUE,
                          recursive=TRUE)
    Var_path = Var_path[!grepl("meta", basename(Var_path))]
    
    for (var_path in Var_path) {

        ###
        var_path = Var_path[1]
        ###
        var = gsub("[.]fst", "", basename(var_path))

        dataEX = ASHE::read_tibble(var_path)
        dataEX = dplyr::arrange(dataEX, code)
        
        metaEX_path =
            file.path(dirname(dirname(var_path)),
                      paste0(gsub("data", "meta",
                                  basename(dirname(var_path))),
                             ".fst"))
        metaEX = ASHE::read_tibble(metaEX_path)
        metaEX_var = metaEX[metaEX$variable_en == var,]
        
        meta_path = file.path(dirname(dirname(var_path)), "meta.fst")
        meta = ASHE::read_tibble(meta_path)
        meta = dplyr::arrange(meta, code)

        Date = as.Date(levels(factor(dataEX$date)))
        Date = seq.Date(as.Date(paste0(lubridate::year(min(Date)),
                                       "-01-01")),
                        as.Date(paste0(lubridate::year(max(Date)),
                                       "-01-01")),
                        by="years")
        
        Code = levels(factor(dataEX$code))
        Date = as.Date(levels(factor(dataEX$date)))

        dataEX_matrix = dplyr::select(dataEX, code, date,
                                      dplyr::all_of(var))
        dataEX_matrix =
            tidyr::pivot_wider(dataEX_matrix,
                               names_from=code,
                               values_from=dplyr::all_of(var))
        dataEX_matrix = dplyr::select(dataEX_matrix, -date)
        dataEX_matrix = t(as.matrix(dataEX_matrix))

        
        
        initialise_NCf()

        list_path = list.files(getwd(), pattern='*.R$', full.names=TRUE)
        list_path = list_path[!grepl("DRIAS_export.R", list_path)]
        for (path in list_path) {
            source(path, encoding='UTF-8')    
        }

        out_dir = "NetCDF"
        if (!(file.exists(out_dir))) {
            dir.create(out_dir)
        }

        generate_NCf(out_dir=out_dir, verbose=TRUE)
    }

    ncdf4::nc_close(NC)
}
