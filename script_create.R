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
#         data_sim$code = convert_codeNtoM(data_sim$code)
#         data_sim = data_sim[data_sim$code %in% codeSUB10,]
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

    data = dplyr::tibble()

    if (isSim) {
        post("### Simulated data")
        Chain = c()
        data_sim = tibble()
        
        for (i in 1:length(files)) {    
            file = files[[i]]
            chain = files_name[[i]][1]
            path = file
            
            for (p in path) {
                
                if (file.exists(p)) {
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
                            data_sim_tmp$code =
                                convert_codeNtoM(data_sim_tmp$code)
                            data_sim_tmp = data_sim_tmp[data_sim_tmp$code %in%
                                                        CodeSUB10,]
                            data_sim_tmp =
                                data_sim_tmp[order(data_sim_tmp$code),]
                        }
                    }
                    data_sim = dplyr::bind_rows(data_sim, data_sim_tmp)

                    rm ("data_sim_tmp")
                    gc()
                }
            }
        }

        if (nrow(data_sim) == 0) {
            isSim = FALSE
        } else {
            id = match(CodeSUB10, CodeALL10)
            meta_sim =
                dplyr::tibble(
                           code=CodeSUB10,
                           name=codes_selection_data$SuggestionNOM[id],
                           hydrological_region=
                               iRegHydro()[substr(CodeSUB10, 1, 1)],
                           source=codes_selection_data$SOURCE[id],
                           reference=
                               codes_selection_data$Référence[id],
                           XL93_m=
                               as.numeric(codes_selection_data$XL93[id]),
                           YL93_m=
                               as.numeric(codes_selection_data$YL93[id]),
                           surface_km2=
                               as.numeric(codes_selection_data$S_HYDRO[id]))

            meta_sim_tmp = dplyr::summarise(dplyr::group_by(data_sim,
                                                            HM,
                                                            code),
                                            S=S[1])
            meta_sim_tmp = tidyr::pivot_wider(
                                      meta_sim_tmp,
                                      names_from=HM,
                                      values_from=S,
                                      names_glue="surface_{HM}_km2")

            meta_sim = dplyr::left_join(meta_sim, meta_sim_tmp,
                                        by="code")
            rm ("meta_sim_tmp"); gc()


            cols = names(meta_sim)[grepl("surface", names(meta_sim))]
            cols = cols[cols != "surface_km2"]
            meta_sim =
                dplyr::filter(meta_sim,
                              !if_all(.cols=all_of(cols),
                                      .fns=is.na))

            data_sim = dplyr::select(data_sim, -"S")


            if (grepl("diagnostic", mode)) {
                
                val2check = names(data_sim)[!(names(data_sim) %in%
                                              c("HM", "code",
                                                "date", "Q_sim"))]

                HM = Chain
                nHM = length(HM)

                if (!is.null(complete_by)) {
                    HM4complete = complete_by[complete_by %in% HM]
                    nVal2check = length(val2check)
                    
                    if (!all(is.na(HM4complete))) {
                        for (hm4complete in HM4complete) {
                            data_hm4complete =
                                data_sim[data_sim$HM == hm4complete,]
                            data_hm4complete =
                                dplyr::select(data_hm4complete,
                                              -HM)
                            
                            for (hm in HM) {
                                data_hm = data_sim[data_sim$HM == hm,]
                                data_hm = dplyr::select(data_hm,
                                                           -HM)

                                for (i in 1:nVal2check) {
                                    col = val2check[i]
                                    
                                    if (all(is.na(data_hm[[col]]))) {
                                        data_hm =
                                            dplyr::left_join(
                                                       dplyr::select(data_hm, -col),
                                                       dplyr::select(data_hm4complete,
                                                                     c("date",
                                                                       "code",
                                                                       col)),
                                                       by=c("code", "date"))
                                    }
                                }
                                data_hm = dplyr::bind_cols(HM=hm,
                                                              data_hm)
                                data_hm = data_hm[names(data_sim)]
                                data_sim[data_sim$HM == hm,] = data_hm

                                rm ("data_hm")
                                gc()
                            }
                        }
                    }
                }

                data_sim = dplyr::relocate(data_sim, "T",
                                           .before=ET0)            
                if ("Rl" %in% names(data_sim)) {
                    data_sim$Rl[!is.finite(data_sim$Rl)] = NA
                }
                if ("Rs" %in% names(data_sim)) {
                    data_sim$Rs[!is.finite(data_sim$Rs)] = NA
                }
                if ("R" %in% names(data_sim)) {
                    data_sim$R[!is.finite(data_sim$R)] = NA
                    data_sim = dplyr::filter(dplyr::group_by(data_sim, code),
                                             rep(!all(is.na(R)), length(R)))
                }
                
                for (i in 1:length(diag_station_to_remove)) {
                    data_sim = dplyr::filter(
                                          data_sim,
                                          !(HM ==
                                            names(diag_station_to_remove)[i] &
                                            grepl(diag_station_to_remove[i],
                                                  code)))
                    meta_sim[[paste0("surface_",
                                     names(diag_station_to_remove)[i],
                                     "_km2")]][
                        grepl(diag_station_to_remove[i], meta_sim$code)
                    ] = NA
                }
            }
        }
    }

    
    # if (nrow(data_sim) > 0 | isObs & !isSim) {
    if (isObs) {
        post("### Observation data")
        
        if (isSim) {
            Code10_available = levels(factor(data_sim$code))
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
            meta_obs$code = convert_codeNtoM(meta_obs$code)
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
                                  date,
                                  as.Date(period_extract[1]),
                                  as.Date(period_extract[2])))

        data_obs$code = convert_codeNtoM(data_obs$code)
        data_obs = dplyr::arrange(data_obs, code)
        names(data_obs)[names(data_obs) == "Q"] = "Q_obs"

        meta_obs = get_lacune(dplyr::rename(data_obs, Q=Q_obs),
                              meta_obs)
    }

    
    if (isSim & isObs) {
        meta = dplyr::left_join(meta_sim,
                                dplyr::select(meta_obs,
                                              code,
                                              Gestionnaire,
                                              Altitude_m,
                                              tLac_pct,
                                              meanLac),
                                by="code")
        data = dplyr::inner_join(data_sim,
                                 data_obs,
                                 by=c("code", "date"))
        
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
        HM4complete = complete_by[complete_by %in% HM]
        
        if (!all(is.na(HM4complete))) {
            for (hm4complete in HM4complete) {

                if (!exists("data_val_obs")) {
                    data_val_obs = dplyr::filter(data,
                                                 HM ==
                                                 hm4complete)
                } else {
                    data_val_obs =
                        dplyr::bind_rows(
                                   data_val_obs,
                                   dplyr::filter(data,
                                                 HM ==
                                                 hm4complete &
                                                 !(code %in%
                                                   data_val_obs$code)))
                }
            }
            
            data_val_obs = dplyr::select(data_val_obs,
                                         all_of(c("code", "date",
                                                  paste0(val2check, "_sim"))))
            names(data_val_obs) = gsub("[_]sim", "_obs", names(data_val_obs))
            data = dplyr::left_join(data, data_val_obs, by=c("code",
                                                             "date"))
        }
    }
    
    
    if (nrow(data) > 0) {
        write_tibble(data,
                     filedir=tmppath,
                     filename=paste0("data_",
                                     files_name_opt.,
                                     subset_name, ".fst"))
        rm ("data"); gc()

        meta = dplyr::arrange(meta, code)


        

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
