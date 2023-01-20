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
    data = read_tibble(filedir=tmpdir,
                       filename=paste0("data_",
                                       subset,
                                       ".fst"))
    meta = read_tibble(filedir=tmpdir,
                       filename=paste0("meta_",
                                       subset,
                                       ".fst"))

    Model = levels(factor(data$Model))
    nModel = length(Model)
    
    Code_available = levels(factor(data$Code))
    Code = Code_available[Code_available %in% CodeSUB]
    nCode = length(Code)
            
    data$ID = paste0(data$Model, "_", data$Code)
    data = dplyr::select(data, -c(Model, Code))
    data = dplyr::select(data, ID, everything())

    samplePeriodMOD = samplePeriod_opti
    
    if (!is.null(samplePeriodMOD)) {
        nTopic = length(samplePeriodMOD)        
        
        for (i in 1:nTopic) {
            
            spMOD = samplePeriodMOD[[i]]
            
            if (identical(spMOD, "min") | identical(spMOD, "max")) {

                Code_opti = c()
                sp_opti = c()
                for (j in 1:nCode) {
                    Code_opti = c(Code_opti,
                                  paste0(Model, "_", Code[j]))
                    sp_opti =
                        c(sp_opti,
                          rep(paste0(formatC(meta[[paste0(spMOD,
                                                          "QM")]][j],
                                             width=2, flag="0"), '-01'),
                              nModel))
                }
                sp = tibble(Code=Code_opti,
                            sp=sp_opti)
                
            } else {
                if (length(spMOD) == 2) {
                    spMOD = list(spMOD)
                }
                Code_opti = c()
                sp_opti = c()
                for (j in 1:nCode) {
                    Code_opti = c(Code_opti,
                                  paste0(Model, "_", Code[j]))
                    sp_opti =
                        c(sp_opti, rep(spMOD, nModel))
                }
                sp = tibble(Code=Code_opti,
                            sp=sp_opti)
            }
            samplePeriodMOD[[i]] = sp
        }
    }

    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          CARD_dir=
                              analyse_data[grepl("indicator",
                                                 analyse_data)][1],
                          samplePeriod_by_topic=samplePeriodMOD,
                          simplify_by="ID",
                          verbose=verbose)

    dataEXind = res$dataEX
    metaEXind = res$metaEX
    
    dataEXind$Model = gsub("[_].*$", "", dataEXind$ID)
    dataEXind$Code = gsub("^.*[_]", "", dataEXind$ID)
    dataEXind = dplyr::select(dataEXind, -ID)
    dataEXind = dplyr::select(dataEXind, Model, Code, dplyr::everything())
    
    write_tibble(dataEXind,
                 filedir=tmpdir,
                 filename=paste0("dataEXind_", subset, ".fst"))
    write_tibble(metaEXind,
                 filedir=tmpdir,
                 filename="metaEXind.fst")
}


analyse_data_serie = function () {
    data = read_tibble(filedir=tmpdir,
                       filename=paste0("data_",
                                       subset,
                                       ".fst"))
    meta = read_tibble(filedir=tmpdir,
                       filename=paste0("meta_",
                                       subset,
                                       ".fst"))

    Model = levels(factor(data$Model))
    nModel = length(Model)
    
    Code_available = levels(factor(data$Code))
    Code = Code_available[Code_available %in% CodeSUB]
    nCode = length(Code)
        
    data$ID = paste0(data$Model, "_", data$Code)
    data = dplyr::select(data, -c(Model, Code))
    data = dplyr::select(data, ID, everything())

    samplePeriodMOD = samplePeriod_opti
    
    if (!is.null(samplePeriodMOD)) {
        nTopic = length(samplePeriodMOD)        
        
        for (i in 1:nTopic) {
            
            spMOD = samplePeriodMOD[[i]]
            
            if (identical(spMOD, "min") | identical(spMOD, "max")) {

                Code_opti = c()
                sp_opti = c()
                for (j in 1:nCode) {
                    Code_opti = c(Code_opti,
                                  paste0(Model, "_", Code[j]))
                    sp_opti =
                        c(sp_opti,
                          rep(paste0(formatC(meta[[paste0(spMOD,
                                                          "QM")]][j],
                                             width=2, flag="0"), '-01'),
                              nModel))
                }
                sp = tibble(Code=Code_opti,
                            sp=sp_opti)
                
            } else {
                if (length(spMOD) == 2) {
                    spMOD = list(spMOD)
                }
                Code_opti = c()
                sp_opti = c()
                for (j in 1:nCode) {
                    Code_opti = c(Code_opti,
                                  paste0(Model, "_", Code[j]))
                    sp_opti =
                        c(sp_opti, rep(spMOD, nModel))
                }
                sp = tibble(Code=Code_opti,
                            sp=sp_opti)
            }
            samplePeriodMOD[[i]] = sp
        }
    }
    
    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          CARD_dir=
                              analyse_data[grepl("serie",
                                                 analyse_data)][1],
                          samplePeriod_by_topic=samplePeriodMOD,
                          simplify_by=NULL,
                          verbose=verbose)

    dataEXserie = res$dataEX
    metaEXserie = res$metaEX

    for (i in 1:length(dataEXserie)) {
        dataEXserie[[i]]$Model = gsub("[_].*$", "",
                                      dataEXserie[[i]]$ID)
        dataEXserie[[i]]$Code = gsub("^.*[_]", "",
                                     dataEXserie[[i]]$ID)
        dataEXserie[[i]] = dplyr::select(dataEXserie[[i]], -ID)
        dataEXserie[[i]] = dplyr::select(dataEXserie[[i]],
                                         Model, Code,
                                         dplyr::everything())
    }
    
    write_tibble(dataEXserie,
                 filedir=tmpdir,
                 filename=paste0("dataEXserie_", subset, ".fst"))
    write_tibble(metaEXserie,
                 filedir=tmpdir,
                 filename="metaEXserie.fst")
}


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {
    
    if (any(grepl("indicator", analyse_data))) {
        analyse_data_indicator()
    }

    if (any(grepl("serie", analyse_data))) {
        analyse_data_serie()
    }
}
