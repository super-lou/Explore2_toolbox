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

create_data_sim = function (p, chain) {
    if (grepl(".*[.]nc", p)) {
        data_sim = NetCDF_to_tibble(p,
                                    chain=chain,
                                    mode=mode)
        gc()
    }
    if (is.null(data_sim)) {
        data_sim = dplyr::tibble()
    } else {
        data_sim$Code = convert_code8to10(data_sim$Code)
        data_sim = data_sim[data_sim$Code %in% CodeSUB10,]
        data_sim = data_sim[order(data_sim$Code),]
    }
    return (data_sim)
}

create_data = function () {

    post("### Simulated data")
    Chain = c()
    data_sim = tibble()
    
    for (i in 1:length(files)) {    
        file = files[[i]]
        chain = files_name[[i]][1]

        # if (mode == "proj") {
            # path = proj_path
        # } else if (mode == "diag") {
            # path = diag_path
        # }
        # path = file.path(path, file)
        path = file
        
        for (p in path) {
            
            if (file.exists(path)) {
                Chain = c(Chain, chain)
                post(paste0("Get simulated data from ", chain,
                            " in ", p))
                data_sim = dplyr::bind_rows(data_sim,
                                            create_data_sim(p, chain))
            }
        }
    }

    if (nrow(data_sim) > 0) {        
        id = match(CodeSUB10, codes10_selection)
        meta =
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

        meta$Nom = gsub("L[']", "L ", meta$Nom)
        meta$Nom = gsub(" A ", " à ",
                        stringr::str_to_title(meta$Nom))
        meta$Nom = gsub("^L ", "L'", meta$Nom)
        meta$Nom = gsub(" l ", " l'", meta$Nom)

        Code10_available = levels(factor(data_sim$Code))
        Code10 = Code10_available[Code10_available %in% CodeSUB10]
        Code8 = codes8_selection[match(Code10,
                                       codes10_selection)]
        Code8_filename = paste0(Code8, obs_format)
        nCode = length(Code10)

        if (length(Code8) > 0) {
            meta_obs = extract_meta(computer_data_path,
                                    obs_dir,
                                    Code8_filename,
                                    verbose=subverbose)
        } else {
            meta_obs = dplyr::tibble()
        }

        if (nrow(meta_obs) > 0) {
            meta_obs$Code = convert_code8to10(meta_obs$Code)
            meta = dplyr::left_join(meta,
                                    dplyr::select(meta_obs,
                                                  Code,
                                                  Gestionnaire,
                                                  Altitude_m),
                                    by="Code")
        }
        meta = dplyr::arrange(meta, Code)

        meta_S = dplyr::summarise(dplyr::group_by(data_sim,
                                                  Model,
                                                  Code),
                                  S=S[1])
        meta_S = tidyr::pivot_wider(meta_S,
                                    names_from=Model,
                                    values_from=S,
                                    names_glue="Surface_{Model}_km2")
        meta = dplyr::left_join(meta, meta_S, by="Code")
        data_sim = dplyr::select(data_sim, -"S")
        
        if (mode == "diag") {
            post("### Observation data")

            Model = Chain
            
            # Extract data about selected stations
            data_obs = extract_data(computer_data_path,
                                    obs_dir,
                                    Code8_filename,
                                    val2keep=c(val_E2=0),
                                    verbose=subverbose)
            gc()
            data_obs =
                dplyr::filter(
                           data_obs,
                           dplyr::between(
                                      Date,
                                      as.Date(period_analyse[1]),
                                      as.Date(period_analyse[2])))

            # data_obs$Code = codes10_selection[match(data_obs$Code,
            #                                         codes8_selection)]
            data_obs$Code = convert_code8to10(data_obs$Code)
            
            data_obs = dplyr::arrange(data_obs, Code)
            meta = get_lacune(data_obs, meta)
            
            names(data_obs)[names(data_obs) == "Q"] = "Q_obs"

            data = dplyr::inner_join(data_sim,
                                     data_obs,
                                     by=c("Code", "Date"))
            gc()
            
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
                        gc()
                    }
                }
            }
            if (propagate_NA) {
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
            data = dplyr::relocate(data, "T", .before=ET0)

        } else if (mode == "proj") {
            data = data_sim
        }

        # print(meta)
        # print(data)

        # meta = dplyr::left_join(meta,
        #                         dplyr::select(data,
        #                                       c("Code", "S")),
        #                         by="Code")
        # data = dplyr::select(data, -"S")

        # print(meta)
        # print(data)
        # print("")
        
        write_tibble(data,
                     filedir=tmppath,
                     filename=paste0("data_",
                                     files_name_opt.,
                                     subset_name, ".fst"))
        write_tibble(meta,
                     filedir=tmppath,
                     filename=paste0("meta_",
                                     files_name_opt.,
                                     subset_name, ".fst"))
        if (!is.null(wait)) {
            Sys.sleep(wait)
        }
        
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
