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


create_data = function () {

    print("### Simulated data")
    Model = c()
    data_sim = tibble()
    for (i in 1:length(files_to_use)) {

        model = names(files_to_use)[[i]]
        model_file = files_to_use[[i]]
        
        model_path = file.path(computer_data_path,
                               diag_dir, model_file)

        for (path in model_path) {
        
            if (file.exists(path)) {
                Model = c(Model, model)

                print(paste0("Get simulated data from ", model,
                             " in ", path))
                
                if (grepl(".*[.]Rdata", path)) {
                    data_tmp = read_tibble(filepath=path)
                    
                } else if (grepl(".*[.]nc", path)) {
                    data_tmp = NetCDF_to_tibble(path,
                                                model=model,
                                                type="diag")
                }

                data_tmp = convert_diag_data(model, data_tmp)
                if (nchar(data_tmp$Code[1]) == 8) {
                    data_tmp$Code = codes10_selection[match(data_tmp$Code,
                                                            codes8_selection)]
                }
                data_tmp = data_tmp[data_tmp$Code %in% CodeSUB10,]
                data_tmp = data_tmp[order(data_tmp$Code),]

                data_sim = dplyr::bind_rows(data_sim, data_tmp)
            }
        }
    }

    if (nrow(data_sim) > 0 & mode == "diag") {
        print("### Observation data")
        
        Code10_available = levels(factor(data_sim$Code))
        Code10 = Code10_available[Code10_available %in% CodeSUB10]
        Code8 = codes8_selection[match(Code10,
                                       codes10_selection)]
        Code8_filename = paste0(Code8, obs_format)
        nCode = length(Code10)
        

        # Extract metadata about selected stations
        meta = extract_meta(computer_data_path,
                            obs_dir,
                            Code8_filename,
                            verbose=FALSE)
        # Extract data about selected stations
        data_obs = extract_data(computer_data_path,
                                obs_dir,
                                Code8_filename,
                                val2keep=c(val_E2=0),
                                verbose=FALSE)

        data_obs =
            dplyr::filter(data_obs,
                          dplyr::between(Date,
                                         as.Date(period_diagnostic[1]),
                                         as.Date(period_diagnostic[2])))

        meta$Code = codes10_selection[match(meta$Code,
                                            codes8_selection)]
        data_obs$Code = codes10_selection[match(data_obs$Code,
                                                codes8_selection)]
        
        meta = meta[order(meta$Code),] 
        data_obs = data_obs[order(data_obs$Code),]
        
        # Time gap
        meta = get_lacune(data_obs, meta)
        
        names(data_obs)[names(data_obs) == "Q"] = "Q_obs"

        data = dplyr::inner_join(data_sim,
                                 data_obs,
                                 by=c("Code", "Date"))
        
        nModel = length(Model)

        if (!is.null(complete_by) & complete_by != "") {
            model4complete = complete_by[complete_by %in% Model][1]
            val2check = c("T", "ET0", "Pl", "Ps", "P")
            nVal2check = length(val2check)
            
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

                    for (i in 1:nVal2check) {
                        col = val2check[i]
                        
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
        
        if (propagate_NA & mode == "diag") {
            NA_propagation = function (X, Ref) {
                X[is.na(Ref)] = NA
                return (X)
            }
            data = dplyr::mutate(data,
                                 dplyr::across(where(is.numeric),
                                               NA_propagation,
                                               Ref=Q_obs))
            data = dplyr::relocate(data, Q_obs, .before=Q_sim)
        }
        
        data = dplyr::relocate(data, T, .before=ET0)

        write_tibble(data,
                     filedir=tmppath,
                     filename=paste0("data_", subset_name, ".fst"))
        write_tibble(meta,
                     filedir=tmppath,
                     filename=paste0("meta_", subset_name, ".fst"))
    } else {
        data = NULL
    }
}


## 1. CREATION OF DATA 4 DIAG ________________________________________
if ('create_data' %in% to_do) {
    create_data()
}
