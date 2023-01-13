# Copyright 2021-2023 Louis Héraut (louis.heraut@inrae.fr)*1,
#                     Éric Sauquet (eric.sauquet@inrae.fr)*1
#
# *1   INRAE, France
#
# This file is part of Ex2D_toolbox R toolbox.
#
# Ex2D_toolbox R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ex2D_toolbox R toolbox is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ex2D_toolbox R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


## 1. CREATION OF DATA 4 DIAG ________________________________________
if ('create_data' %in% to_do) {

    Model = c()
    data_sim = tibble()

    for (i in 1:length(models_to_diag)) {

        model = names(models_to_diag)[i]
        model_file = models_to_diag[i]
        
        model_path = file.path(computer_data_path,
                               diag_dir, model_file)
        
        if (file.exists(model_path)) {
            Model = c(Model, model)

            print(paste0("Get simulated data from ", model,
                         " in ", model_path))
            
            if (grepl(".*[.]Rdata", model_path)) {
                data_tmp = read_tibble(filepath=model_path)
                    
            } else if (grepl(".*[.]nc", model_path)) {
                data_tmp = NetCDF_to_tibble(model_path,
                                       type="diag")
            }
            
            data_tmp = convert_diag_data(model, data_tmp)
            data_tmp = data_tmp[data_tmp$Code %in% CodeSUB,]
            data_tmp = data_tmp[order(data_tmp$Code),]

            data_sim = dplyr::bind_rows(data_sim, data_tmp)
        }
    }
    rm (data_tmp)

    if (nrow(data_sim) > 0) {

        Code_available = levels(factor(data_sim$Code))
        Code = Code_available[Code_available %in% CodeSUB]
        Code_filename = paste0(Code, obs_format)
        nCode = length(Code)
        
        # Extract metadata about selected stations
        meta = extract_meta(computer_data_path,
                            obs_dir,
                            Code_filename)
        # Extract data about selected stations
        data_obs = extract_data(computer_data_path,
                                obs_dir,
                                Code_filename)

        meta = meta[order(meta$Code),]      
        data_obs = data_obs[order(data_obs$Code),]
        
        # Time gap
        meta = get_lacune(data_obs, meta)
        # Hydrograph
        meta = get_hydrograph(data_obs, meta,
                              period=period)$meta
        
        names(data_obs)[names(data_obs) == "Q"] = "Q_obs"
        
        
        data = dplyr::inner_join(data_sim,
                                 data_obs,
                                 by=c("Date", "Code"))

        nModel = length(Model)

        if (!is.null(complete_by) & complete_by != "") {
            model4complete = complete_by[complete_by %in% Model][1]
            col2check = c("T", "Pl", "ET0", "Ps")
            nCol2check = length(col2check)
            
            if (!is.na(model4complete)) {
                data_model4complete =
                    data[data$Model == model4complete,]
                data_model4complete =
                    dplyr::select(data_model4complete,
                                  -Model)
                
                for (model in Model) {
                    data_model = data[data$Model == model,]
                    data_model = dplyr::select(data_model,
                                               -Model)

                    for (i in 1:nCol2check) {
                        col = col2check[i]
                        
                        if (all(is.na(data_model[[col]]))) {
                            data_model =
                                dplyr::left_join(
                                           dplyr::select(data_model, -col),
                                           dplyr::select(data_model4complete,
                                                         c("Date",
                                                           "Code",
                                                           col)),
                                           by=c("Code", "Date"))
                        }
                    }
                    data_model = dplyr::bind_cols(Model=model,
                                                  data_model)
                    data_model = data_model[names(data)]
                    data[data$Model == model,] = data_model
                }
            }
        }

        if (propagate_NA) {
            data$Q_sim[is.na(data$Q_obs)] = NA
        }
        
        data = dplyr::relocate(data, Q_obs, .before=Q_sim)
        data = dplyr::relocate(data, T, .before=ET0)
    } else {
        data = NULL
    }
}


## 2. CREATION OF DATA 4 PROJ ________________________________________
if ('create_data_proj' %in% to_do) {

    Model = c()
    data_sim = tibble()

    for (i in 1:length(models_to_proj)) {

        model = names(models_to_proj)[i]
        model_file = models_to_proj[i]
        
        model_path = file.path(computer_data_path,
                               proj_dir, model_file)
        
        if (file.exists(model_path)) {
            Model = c(Model, model)

            print(paste0("Get simulated data from ", model,
                         " in ", model_path))
            
            if (grepl(".*[.]Rdata", model_path)) {
                data_tmp = read_tibble(filepath=model_path)
                
            } else if (grepl(".*[.]nc", model_path)) {
                data_tmp = NetCDF_to_tibble(model_path,
                                            type="proj")
            }

            data_tmp = data_tmp[data_tmp$Code %in% Code,]
            data_tmp = data_tmp[order(data_tmp$Code),]
            data_tmp = convert_diag_data(model, data_tmp)

            data_sim = dplyr::bind_rows(data_sim, data_tmp)
        }
    }
}
