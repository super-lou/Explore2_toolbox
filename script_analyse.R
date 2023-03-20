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


analyse_data_indicator = function () {
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
    
    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          CARD_dir=
                              analyse_data[grepl("(indicator)|(WIP)",
                                                 analyse_data)][1],
                          period=period_diagnostic,
                          simplify_by="ID",
                          no_lim=no_lim,
                          variable_names=variable_names,
                          verbose=verbose)

    dataEXind = res$dataEX
    metaEXind = res$metaEX

    dataEXind = tidyr::separate(dataEXind, col="ID",
                                into=ID_colnames, sep="_")
        
    dataEXind$Model = gsub("[_].*$", "", dataEXind$ID)
    dataEXind$Code = gsub("^.*[_]", "", dataEXind$ID)
    dataEXind = dplyr::select(dataEXind, -ID)
    dataEXind = dplyr::select(dataEXind, Model, Code, dplyr::everything())
    
    write_tibble(dataEXind,
                 filedir=tmppath,
                 filename=paste0("dataEXind_", subset_name, ".fst"))
    write_tibble(metaEXind,
                 filedir=tmppath,
                 filename="metaEXind.fst")
}


analyse_data_serie = function () {
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
    
    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          CARD_dir=
                              analyse_data[grepl("serie",
                                                 analyse_data)][1],
                          period=period_diagnostic,
                          simplify_by=NULL,
                          no_lim=no_lim,
                          variable_names=variable_names,
                          verbose=verbose)

    dataEXserie = res$dataEX
    metaEXserie = res$metaEX

    for (i in 1:length(dataEXserie)) {
        dataEXserie[[i]] = tidyr::separate(dataEXserie[[i]],
                                           col="ID",
                                           into=ID_colnames,
                                           sep="_")
        # dataEXserie[[i]]$Model = gsub("[_].*$", "",
        #                               dataEXserie[[i]]$ID)
        # dataEXserie[[i]]$Code = gsub("^.*[_]", "",
        #                              dataEXserie[[i]]$ID)
        # dataEXserie[[i]] = dplyr::select(dataEXserie[[i]], -ID)
        # dataEXserie[[i]] = dplyr::select(dataEXserie[[i]],
        #                                  Model, Code,
        #                                  dplyr::everything())
    }
    
    write_tibble(dataEXserie,
                 filedir=tmppath,
                 filename=paste0("dataEXserie_", subset_name, ".fst"))
    write_tibble(metaEXserie,
                 filedir=tmppath,
                 filename="metaEXserie.fst")
}


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {
    
    if (any(grepl("(indicator)|(WIP)", analyse_data))) {
        print("### Analysing data for criteria extraction")
        analyse_data_indicator()
    }

    if (any(grepl("serie", analyse_data))) {
        print("### Analysing data for time series extraction")
        analyse_data_serie()
    }
}
