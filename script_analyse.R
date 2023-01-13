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


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {

    Model = levels(factor(data$Model))
    nModel = length(Model)
    
    Code_available = levels(factor(data$Code))
    Code = Code_available[Code_available %in% CodeSUB]
    nCode = length(Code)

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

    data$ID = paste0(data$Model, "_", data$Code)
    data = dplyr::select(data, -c(Model, Code))
    data = dplyr::select(data, ID, everything())
    
    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          CARD_dir=var_to_analyse_dir,
                          samplePeriod_by_topic=samplePeriodMOD,
                          simplify_by="ID",
                          verbose=verbose)

    dataEX = res$dataEX
    metaEX = res$metaEX
    
    dataEX$Model = gsub("[_].*$", "", dataEX$ID)
    dataEX$Code = gsub("^.*[_]", "", dataEX$ID)
    dataEX = dplyr::select(dataEX, -ID)
    dataEX = dplyr::select(dataEX, Model, Code, dplyr::everything())
    
    write_tibble(meta,
                 filedir=tmpdir,
                 filename=paste0("meta_", subset, ".fst"))
    write_tibble(dataEX,
                 filedir=tmpdir,
                 filename=paste0("dataEX_", subset, ".fst"))
}
