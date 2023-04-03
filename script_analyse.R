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


CARD_analyse_data = function () {
    data = read_tibble(filedir=tmppath,
                       filename=paste0("data_",
                                       subset_name,
                                       ".fst"))
    meta = read_tibble(filedir=tmppath,
                       filename=paste0("meta_",
                                       subset_name,
                                       ".fst"))

    Model = levels(factor(data$Model))
    nModel = length(Model)
    
    Code_available = levels(factor(data$Code))
    Code = Code_available[Code_available %in% CodeSUB10]
    nCode = length(Code)

    ID_colnames = names(dplyr::select(data, where(is.character)))    
    data = tidyr::unite(data, "ID", where(is.character), sep="_")

    if (mode == "proj") {
        variable_names = c(Q="Q_sim")
    } else {
        variable_names = NULL
    }

    for (i in 1:length(analyse_data)) {
        
        CARD_dir = analyse_data[[i]][1]
        simplify = as.logical(analyse_data[[i]]["simplify"])
        CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)

        if (simplify) {
            simplify_by = "ID"
        } else {
            simplify_by = NULL
        }
        
        res = CARD_extraction(data,
                              CARD_path=CARD_path,
                              CARD_dir=CARD_dir,
                              period=period_analyse,
                              simplify_by=simplify_by,
                              no_lim=no_lim,
                              variable_names=variable_names,
                              verbose=subverbose)
        
        dataEX = res$dataEX
        metaEX = res$metaEX
        
        if (simplify) {
            dataEX = tidyr::separate(dataEX, col="ID",
                                     into=ID_colnames, sep="_")
            
            dataEX$Model = gsub("[_].*$", "", dataEX$ID)
            dataEX$Code = gsub("^.*[_]", "", dataEX$ID)
            dataEX = dplyr::select(dataEX, -ID)
            dataEX = dplyr::select(dataEX, Model, Code,
                                   dplyr::everything())
            
        } else {
            post(dataEX)
            post(length(dataEX))
            for (j in 1:length(dataEX)) {
                dataEX[[j]] = tidyr::separate(dataEX[[j]],
                                              col="ID",
                                              into=ID_colnames,
                                              sep="_")
            }
        }

        write_tibble(dataEX,
                     filedir=tmppath,
                     filename=paste0("dataEX_", CARD_var,
                                     "_", subset_name, ".fst"))
        write_tibble(metaEX,
                     filedir=tmppath,
                     filename=paste0("metaEX_", CARD_var, ".fst"))
    }
}




# analyse_data_serie = function () {
#     data = read_tibble(filedir=tmppath,
#                        filename=paste0("data_",
#                                        subset_name,
#                                        ".fst"))
#     meta = read_tibble(filedir=tmppath,
#                        filename=paste0("meta_",
#                                        subset_name,
#                                        ".fst"))

#     Model = levels(factor(data$Model))
#     nModel = length(Model)
    
#     Code_available = levels(factor(data$Code))
#     Code = Code_available[Code_available %in% CodeSUB10]
#     nCode = length(Code)

#     ID_colnames = names(dplyr::select(data, where(is.character)))    
#     data = tidyr::unite(data, "ID", where(is.character), sep="_")

#     if (mode == "proj") {
#         variable_names = c(Q="Q_sim")
#     } else {
#         variable_names = NULL
#     }

#     CARD_dir = analyse_data[!sapply(analyse_data, check_simplify)][1] ###
    
#     res = CARD_extraction(data,
#                           CARD_path=CARD_path,
#                           CARD_dir=CARD_dir,
#                           period=period_analyse,
#                           simplify_by=NULL,
#                           no_lim=no_lim,
#                           variable_names=variable_names,
#                           verbose=subverbose)

#     dataEXserie = res$dataEX
#     metaEXserie = res$metaEX

#     for (i in 1:length(dataEXserie)) {
#         dataEXserie[[i]] = tidyr::separate(dataEXserie[[i]],
#                                            col="ID",
#                                            into=ID_colnames,
#                                            sep="_")
#     }
    
#     write_tibble(dataEXserie,
#                  filedir=tmppath,
#                  filename=paste0("dataEXserie_", subset_name, ".fst"))
#     write_tibble(metaEXserie,
#                  filedir=tmppath,
#                  filename="metaEXserie.fst")
# }


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {

    test_path = file.path(tmppath,
                          paste0("data_", subset_name, ".fst"))

    if (file.exists(test_path)) {
        # if (any(sapply(analyse_data, check_simplify))) {
        post("### Analysing data")
        CARD_analyse_data()
        # }

        # if (any(!sapply(analyse_data, check_simplify))) {
        # post("### Analysing data for time series extraction")
        # analyse_data_serie()
        # }
    }
}
