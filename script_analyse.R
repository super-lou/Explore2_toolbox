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



CARD_analyse_data_hide = function (data, CARD_path, tmppath,
                                   analyse, period_analyse,
                                   files_name_opt., subset_name,
                                   subverbose) {
    
    res = CARD_extraction(data,
                          CARD_path=CARD_path,
                          CARD_dir=paste0(analyse$name, "_", rank),
                          CARD_tmp=tmppath,
                          period=period_analyse,
                          simplify=analyse$simplify,
                          suffix=analyse$suffix,
                          cancel_lim=analyse$cancel_lim,
                          # parameters=analyse$parameters,
                          verbose=subverbose)
    dataEX = res$dataEX
    metaEX = res$metaEX
    gc()

    write_tibble(dataEX,
                 filedir=tmppath,
                 filename=paste0("dataEX_", analyse$name, "_",
                                 files_name_opt.,
                                 subset_name, ".fst"))
    write_tibble(metaEX,
                 filedir=tmppath,
                 filename=paste0("metaEX_", analyse$name, "_",
                                 files_name_opt.,
                                 subset_name, ".fst"))
}


CARD_analyse_data = function () {
    data = read_tibble(filedir=tmppath,
                       filename=paste0("data_",
                                       files_name_opt.,
                                       subset_name, ".fst"))
    gc()
    meta = read_tibble(filedir=tmppath,
                       filename=paste0("meta_",
                                       files_name_opt.,
                                       subset_name, ".fst"))

    Model = levels(factor(data$Model))
    nModel = length(Model)
    
    Code_available = levels(factor(data$Code))
    Code = Code_available[Code_available %in% CodeSUB10]
    nCode = length(Code)

    for (i in 1:length(analyse_data)) {
        analyse = analyse_data[[i]]

        CARD_management(CARD=CARD_path,
                        tmp=tmppath,
                        layout=c(paste0(analyse$name, "_", rank), "[",
                                 analyse$variables, "]"),
                        overwrite=FALSE)

        CARD_analyse_data_hide(data, CARD_path, tmppath,
                               analyse, period_analyse,
                               files_name_opt., subset_name,
                               subverbose)
        gc()
        if (!is.null(wait)) {
            Sys.sleep(wait)
        }
    }
}


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {
    post("### Analysing data")
    CARD_analyse_data()
}
