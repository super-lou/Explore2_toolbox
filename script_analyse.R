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


    samplePeriodMOD = samplePeriod_opti
    
    if (!is.null(samplePeriod_opti)) {
        nTopic = length(samplePeriod_opti)

        for (i in 1:nTopic) {
            sp = samplePeriodMOD[[i]]
            
            if (identical(sp, "min") | identical(sp, "max")) {
                sp = tibble(Code=meta$Code,
                            sp=paste0(formatC(meta[[paste0(sp,
                                                           "QM")]],
                                              width=2,
                                              flag="0"),
                                      '-01'))
            } else {
                if (length(sp) == 2) {
                    sp = list(sp)
                }
                sp = tibble(Code=meta$Code, sp=sp)
            }
            samplePeriodMOD[[i]] = sp
        }
    }
    
    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          WIP_dir=var_to_analyse_dir,
                          samplePeriod_by_topic=samplePeriodMOD,
                          simplify=TRUE,
                          verbose=TRUE)

    dataEX = res$dataEX
    metaEX = res$metaEX

    # vars = names(Xex)[!(names(Xex) %in% c("ID", "Date"))]
    # vars = gsub("([_]obs)|([_]sim)", "", vars)
    # vars = vars[!duplicated(vars)]
    
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
