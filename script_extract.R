# \\\
# Copyright 2021-2022 Louis Héraut*1,
#                     Éric Sauquet*2,
#                     Valentin Mansanarez
#
# *1   INRAE, France
#      louis.heraut@inrae.fr
# *2   INRAE, France
#      eric.sauquet@inrae.fr
#
# This file is part of ash R toolbox.
#
# Ash R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ash R toolbox is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.
# ///
#
#
# R/script_extract.R
#
# Script that manages the call to the right process in order to
# realise extraction of data.


## 1. EXTRACTION OF HYDROMETRIC STATIONS _____________________________
if ('station_extraction' %in% to_do) {

    codes_to_diag_SHP = read_shp(file.path(computer_data_path,
                                           codes_to_diag_SHPdir))
    codes_to_diag = as.character(codes_to_diag_SHP$Code)

    if (all(code_filenames_to_use == "")) {
        stop ("No station selected")
    }

    code_filenames_to_use = convert_regexp(computer_data_path,
                                  obs_dir, code_filenames_to_use)
    codes_to_use = gsub("[_].*$", "", code_filenames_to_use)
    okCode = codes_to_use %in% codes_to_diag
    Code = codes_to_use[okCode]
    code_filenames_to_use = code_filenames_to_use[okCode]
    
    
    # Extract metadata about selected stations
    meta_obs = extract_meta(computer_data_path,
                            obs_dir, code_filenames_to_use)
    # Extract data about selected stations
    data_obs = extract_data(computer_data_path,
                            obs_dir, code_filenames_to_use)

    meta_obs = meta_obs[order(meta_obs$Code),]      
    data_obs = data_obs[order(data_obs$Code),]

    Model = c()
    data_sim = tibble()

    

    for (i in 1:length(models_to_diag)) {

        model = names(models_to_diag)[i]
        model_file = models_to_diag[i]
        
        model_path = file.path(computer_data_path,
                               diag_dir, model_file)
        
        if (file.exists(model_path)) {
            Model = c(Model, model)

            if (grepl(".*[.]Rdata", model_path)) {
                data_tmp = loadRData(model_path)
                    
            } else if (grepl(".*[.]nc", model_path)) {
                data_tmp = NetCDF_to_tibble(model_path)
            }

            data_tmp = data_tmp[data_tmp$Code %in% Code,]
            data_tmp = data_tmp[order(data_tmp$Code),]
            data_tmp = convert_diag_data(model, data_tmp)
            
            data_sim = dplyr::bind_rows(data_sim, data_tmp)
        }
    }
    
    



    


    # Get all different stations code
    Code = rle(data$Code)$value
    
    # Time gap
    meta = get_lacune(data, meta)
    # Hydrograph
    if (!is.null(mean_period[[1]])) {
        period = mean_period[[1]]
    } else {
        period = trend_period[[1]] 
    }
    meta = get_hydrograph(data, meta,
                          period=period)$meta
}
