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
# along with Explore2 R toolbox.
# If not, see <https://www.gnu.org/licenses/>.

# create_data_sim = function (p, chain) {
#     if (grepl(".*[.]nc", p)) {
#         data_sim = NetCDF_to_tibble(p,
#                                     chain=chain,
#                                     mode=mode)

#     }
#     if (is.null(data_sim)) {
#         data_sim = dplyr::tibble()
#     } else {
#         data_sim$Code = convert_codeNtoM(data_sim$Code)
#         data_sim = data_sim[data_sim$Code %in% CodeSUB10,]
#         data_sim = data_sim[order(data_sim$Code),]
#     }
#     return (data_sim)
# }

create_data = function () {

    if (length(extract_data) == 0) {
        isObs = TRUE
        isSim = TRUE
        
    } else {
        isObs = FALSE
        isSim = FALSE
        for (i in 1:length(extract_data)) {    
            extract = extract_data[[i]]
            if (is.null(extract$suffix)) {
                isObs = TRUE
                isSim = TRUE
            } else {
                if ("obs" %in% extract$suffix) {
                    isObs = TRUE
                }
                if ("sim" %in% extract$suffix) {
                    isSim = TRUE
                }
            }
        }
    }
    

    if (isSim) {
        post("### Simulated data")
        Chain = c()
        data_sim = tibble()
        
        for (i in 1:length(files)) {    
            file = files[[i]]
            chain = files_name[[i]][1]
            path = file
            
            for (p in path) {
                
                if (file.exists(path)) {
                    Chain = c(Chain, chain)
                    post(paste0("Get simulated data from ", chain,
                                " in ", p))

                    if (grepl(".*[.]nc", p)) {
                        data_sim_tmp = NetCDF_to_tibble(p,
                                                        chain=chain,
                                                        type=type,
                                                        mode=mode)
                    }
                    if (is.null(data_sim_tmp)) {
                        data_sim_tmp = dplyr::tibble()
                    } else {
                        if (type == "hydrologie") {
                            data_sim_tmp$Code =
                                convert_codeNtoM(data_sim_tmp$Code)
                            data_sim_tmp = data_sim_tmp[data_sim_tmp$Code %in%
                                                        CodeSUB10,]
                            data_sim_tmp =
                                data_sim_tmp[order(data_sim_tmp$Code),]
                        }
                    }
                    data_sim = dplyr::bind_rows(data_sim, data_sim_tmp)

                    rm ("data_sim_tmp")
                    gc()
                }
            }
        }

        
        id = match(CodeSUB10, CodeALL10)
        meta_sim =
            dplyr::tibble(
                       Code=CodeSUB10,
                       Nom=codes_selection_data$SuggestionNOM[id],
                       Region_Hydro=
                           iRegHydro()[substr(CodeSUB10, 1, 1)],
                       Source=codes_selection_data$SOURCE[id],
                       Référence=
                           codes_selection_data$Référence[id],
                       XL93_m=
                           as.numeric(codes_selection_data$XL93[id]),
                       YL93_m=
                           as.numeric(codes_selection_data$YL93[id]),
                       Surface_km2=
                           as.numeric(codes_selection_data$S_HYDRO[id]))
        
        meta_sim_tmp = dplyr::summarise(dplyr::group_by(data_sim,
                                                        Model,
                                                        Code),
                                        S=S[1])
        meta_sim_tmp = tidyr::pivot_wider(meta_sim_tmp,
                                          names_from=Model,
                                          values_from=S,
                                          names_glue="Surface_{Model}_km2")

        meta_sim = dplyr::left_join(meta_sim, meta_sim_tmp, by="Code")
        rm ("meta_sim_tmp"); gc()
        
        data_sim = dplyr::select(data_sim, -"S")


        if (grepl("diagnostic", mode)) {
            
            val2check = names(data_sim)[!(names(data_sim) %in%
                                          c("Model", "Code",
                                            "Date", "Q_sim"))]

            Model = Chain
            nModel = length(Model)

            if (!is.null(complete_by)) {
                Model4complete = complete_by[complete_by %in% Model]
                nVal2check = length(val2check)
                
                if (!all(is.na(Model4complete))) {
                    for (model4complete in Model4complete) {
                        data_model4complete =
                            data_sim[data_sim$Model == model4complete,]
                        data_model4complete =
                            dplyr::select(data_model4complete,
                                          -Model)
                        
                        for (model in Model) {
                            data_model = data_sim[data_sim$Model == model,]
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
                            data_model = data_model[names(data_sim)]
                            data_sim[data_sim$Model == model,] = data_model

                            rm ("data_model")
                            gc()
                        }
                    }
                }
            }

            data_sim = dplyr::relocate(data_sim, "T", .before=ET0)            
            if ("Rl" %in% names(data_sim)) {
                data_sim$Rl[!is.finite(data_sim$Rl)] = NA
            }
            if ("Rs" %in% names(data_sim)) {
                data_sim$Rs[!is.finite(data_sim$Rs)] = NA
            }
            if ("R" %in% names(data_sim)) {
                data_sim$R[!is.finite(data_sim$R)] = NA
                data_sim = dplyr::filter(dplyr::group_by(data_sim, Code),
                                         rep(!all(is.na(R)), length(R)))
            }
            
            for (i in 1:length(diag_station_2_remove)) {
                data_sim = dplyr::filter(
                                      data_sim,
                                      !(Model ==
                                        names(diag_station_2_remove)[i] &
                                        grepl(diag_station_2_remove[i],
                                              Code)))
                meta_sim[[paste0("Surface_",
                                 names(diag_station_2_remove)[i],
                                 "_km2")]][
                    grepl(diag_station_2_remove[i], meta_sim$Code)
                ] = NA
            }
        }
    }

    
    # if (nrow(data_sim) > 0 | isObs & !isSim) {
    if (isObs) {
        post("### Observation data")
        
        if (isSim) {
            Code10_available = levels(factor(data_sim$Code))
        } else {
            Code10_available = CodeSUB10
        }
        Code10 = Code10_available[Code10_available %in% CodeSUB10]
        Code8 = CodeALL8[match(Code10, CodeALL10)]
        Code8_filename = paste0(Code8, obs_hydro_format)
        nCode = length(Code10)

        if (length(Code8) > 0) {
            meta_obs = create_meta_HYDRO(computer_data_path,
                                         file.path(type,
                                                   obs_hydro_dir),
                                         Code8_filename,
                                         verbose=subverbose)
            meta_obs$Code = convert_codeNtoM(meta_obs$Code)
        } else {
            meta_obs = dplyr::tibble()
        }
        

        data_obs = create_data_HYDRO(computer_data_path,
                                     file.path(type,
                                               obs_hydro_dir),
                                     Code8_filename,
                                     val2keep=c(val_E2=0),
                                     verbose=subverbose)
        
        data_obs =
            dplyr::filter(
                       data_obs,
                       dplyr::between(
                                  Date,
                                  as.Date(period_extract[1]),
                                  as.Date(period_extract[2])))

        data_obs$Code = convert_codeNtoM(data_obs$Code)
        data_obs = dplyr::arrange(data_obs, Code)
        names(data_obs)[names(data_obs) == "Q"] = "Q_obs"

        meta_obs = get_lacune(dplyr::rename(data_obs, Q=Q_obs),
                              meta_obs)
    }

    
    if (isSim & isObs) {
        meta = dplyr::left_join(meta_sim,
                                dplyr::select(meta_obs,
                                              Code,
                                              Gestionnaire,
                                              Altitude_m,
                                              tLac_pct,
                                              meanLac),
                                by="Code")
        data = dplyr::inner_join(data_sim,
                                 data_obs,
                                 by=c("Code", "Date"))
        
        rm ("data_sim"); gc()
        rm ("data_obs"); gc()
        rm ("meta_obs"); gc()
        rm ("meta_sim"); gc()

        if (propagate_NA) {
            NA_propagation = function (X, Ref) {
                X[is.na(Ref)] = NA
                return (X)
            }
            data =
                dplyr::mutate(
                           data,
                           dplyr::across(
                                      where(is.numeric),
                                      ~NA_propagation(.x,
                                                      Ref=Q_obs)))
        }
        data = dplyr::relocate(data, Q_obs, .before=Q_sim)
        
        for (i in 1:nVal2check) {
            data =
                dplyr::mutate(data,
                              !!paste0(val2check[i],
                                       "_sim"):=get(val2check[i]))
            data = dplyr::select(data, -val2check[i])
        }
        

    } else if (isSim & !isObs) {
        meta = meta_sim
        data = data_sim
        
        rm ("data_sim"); gc()
        rm ("meta_sim"); gc()

        if (grepl("diagnostic", mode)) {
            for (i in 1:nVal2check) {
                data =
                    dplyr::mutate(data,
                                  !!paste0(val2check[i],
                                           "_sim"):=get(val2check[i]))
                data = dplyr::select(data, -val2check[i])
            }
        }
        
    }  else if (!isSim & isObs) {
        meta = meta_obs
        data = data_obs
        
        rm ("data_obs"); gc()
        rm ("meta_obs"); gc()
    }

    
    if (isSim & !is.null(complete_by) & grepl("diagnostic", mode)) {
        Model4complete = complete_by[complete_by %in% Model]
        
        if (!all(is.na(Model4complete))) {
            for (model4complete in Model4complete) {

                if (!exists("data_val_obs")) {
                    data_val_obs = dplyr::filter(data,
                                                 Model ==
                                                 model4complete)
                } else {
                    data_val_obs =
                        dplyr::bind_rows(
                                   data_val_obs,
                                   dplyr::filter(data,
                                                 Model ==
                                                 model4complete &
                                                 !(Code %in%
                                                   data_val_obs$Code)))
                }
            }
            
            data_val_obs = dplyr::select(data_val_obs,
                                         all_of(c("Code", "Date",
                                                  paste0(val2check, "_sim"))))
            names(data_val_obs) = gsub("[_]sim", "_obs", names(data_val_obs))
            data = dplyr::left_join(data, data_val_obs, by=c("Code",
                                                             "Date"))
        }
    }
    
    
    if (nrow(data) > 0) {
        write_tibble(data,
                     filedir=tmppath,
                     filename=paste0("data_",
                                     files_name_opt.,
                                     subset_name, ".fst"))
        rm ("data"); gc()

        meta = dplyr::arrange(meta, Code)
        
        write_tibble(meta,
                     filedir=tmppath,
                     filename=paste0("meta_",
                                     files_name_opt.,
                                     subset_name, ".fst"))
        rm ("meta"); gc()
        
        res = TRUE
        
    } else {
        data = NULL
        res = FALSE
    }
    
    return (res)
}


## 1. CREATION OF DATA 4 DIAG ________________________________________
if ('create_data' %in% to_do) {
    create_ok = create_data()
}
