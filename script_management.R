# \\\
# Copyright 2021-2022 Louis Héraut*1,
#                     Éric Sauquet*2,
#                     Valentin Mansanarez
#
# *1   INRAE, France
#      louis.heraut@inrae.fr
# *2   INRAE, France
#      eric.sauquet@inrae.fr
#
# This file is part of ash R toolbox.
#
# Ash R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ash R toolbox is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.
# ///
#
#
# R/script_management.R
#
# Script that manages the call to the right process in order to
# realise writing and reading.


## 1. MANAGEMENT OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {

    if (exists("meta")) {
        rm (meta)
    }
    if (exists("dataEx")) {
        rm (dataEx)
    }
    for (subset in 1:Subsets) {
        meta_tmp = read_tibble(filedir=tmpdir,
                               filename=paste0("meta_",
                                               subset,
                                               ".fst"))
        dataEx_tmp = read_tibble(filedir=tmpdir,
                                 filename=paste0("dataEx_",
                                                 subset,
                                                 ".fst"))
        if (!exists("dataEx")) {
            meta = meta_tmp
        } else {
            meta = dplyr::bind_rows(meta, meta_tmp)
        }        
        if (!exists("dataEx")) {
            dataEx = dataEx_tmp
        } else {
            dataEx = dplyr::bind_rows(dataEx, dataEx_tmp)
        }
    }
    rm (meta_tmp)
    rm (dataEx_tmp)

    dataEx = dataEx[order(dataEx$Model),]
    meta = meta[order(meta$Code),]

    Vars = colnames(dataEx)
    Vars = Vars[grepl("([_]obs)|([_]sim)", Vars)]
    VarsREL = gsub("([_]obs)|([_]sim)", "", Vars)
    VarsREL = VarsREL[!duplicated(VarsREL)]
    nVarsREL = length(VarsREL)
    
    for (i in 1:nVarsREL) {
        varREL = VarsREL[i]
        if (grepl("^HYP.*", varREL)) {
            dataEx[varREL] =
                dataEx[paste0(varREL, "_sim")] &
                dataEx[paste0(varREL, "_obs")]
        } else {
            dataEx[varREL] =
                dataEx[paste0(varREL, "_sim")] /
                dataEx[paste0(varREL, "_obs")]
        }
    }
}

if ('save_analyse' %in% to_do) {

    print(paste0("Save extracted data and metadata in ",
                 paste0(saving_format, collapse=", ")))
    
    if ("fst" %in% saving_format) {
        write_tibble(meta,
                     filedir=now_resdir,
                     filename=paste0("meta.fst"))
        write_tibble(dataEx,
                     filedir=now_resdir,
                     filename=paste0("dataEx.fst"))
    }
    if ("Rdata" %in% saving_format) {
        write_tibble(meta,
                     filedir=now_resdir,
                     filename=paste0("meta.Rdata"))
        write_tibble(dataEx,
                     filedir=now_resdir,
                     filename=paste0("dataEx.Rdata"))
    }    
    if ("txt" %in% saving_format) {
        write_tibble(meta,
                     filedir=now_resdir,
                     filename=paste0("meta.txt"))
        write_tibble(dataEx,
                     filedir=now_resdir,
                     filename=paste0("dataEx.txt"))
    }  
}

if ('read_saving' %in% to_do) {

    print(paste0("Reading extracted data and metadata in ",
                 read_saving_in))
    
    Filepaths = list.files(read_saving_in, full.names=TRUE)
    Filenames = list.files(read_saving_in, full.names=FALSE)
    nFile = length(Filenames)
    for (i in 1:nFile) {
        assign(read_tibble(filepath=Filepaths[i]), Filenames[i])
    }
}
