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

CARD_extract_data = function () {
    data = read_tibble(filedir=tmppath,
                       filename=paste0("data", sep,
                                       files_name_opt.,
                                       subset_name, ".fst"))
    
    meta = read_tibble(filedir=tmppath,
                       filename=paste0("meta", sep,
                                       files_name_opt.,
                                       subset_name, ".fst"))

    if (type == "piezometrie") {
        data = dplyr::rename(data, Q_obs=H_obs, Q_sim=H_sim)
    }


    for (i in 1:length(extract_data)) {
        
        extract = extract_data[[i]]

        CARD_management(CARD=CARD_path,
                        tmp=tmppath,
                        layout=c(paste0(extract$name, "_", rank), "[",
                                 extract$variables, "]"),
                        overwrite=TRUE,
                        verbose=subverbose)

        if (extract$type == "criteria") {
            simplify = TRUE
            expand = FALSE
        } else if (extract$type == "serie") {
            simplify = FALSE
            expand = TRUE
        }

        if (grepl("diagnostic", mode)) {
            cancel_lim = TRUE
        } else if (grepl("projection", mode)) {
            cancel_lim = FALSE
        }

        res = CARD_extraction(data,
                              CARD_path=CARD_path,
                              CARD_dir=paste0(extract$name, "_", rank),
                              CARD_tmp=tmppath,
                              period=period_extract,
                              simplify=simplify,
                              suffix=extract$suffix,
                              expand_overwrite=expand,
                              cancel_lim=cancel_lim,
                              rm_duplicates=TRUE,
                              dev=FALSE,
                              verbose=subverbose)
        
        write_tibble(res$dataEX,
                     filedir=tmppath,
                     filename=paste0("dataEX_", extract$name, sep,
                                     files_name_opt.,
                                     subset_name, ".fst"))
        write_tibble(res$metaEX,
                     filedir=tmppath,
                     filename=paste0("metaEX_", extract$name, sep,
                                     files_name_opt.,
                                     subset_name, ".fst"))
        rm ("res")
        gc()
    }

    rm ("data")
    gc()
    rm ("meta")
    gc()
}


## 1. EXTRACTION OF DATA ______________________________________________
if ('extract_data' %in% to_do) {
    post("### Extracting data")
    CARD_extract_data()    
}
