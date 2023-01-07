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


## 1. MANAGEMENT OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {

    # print(dataEX[dataEX$Code == "W2832020",])
    
    if (exists("meta")) {
        rm (meta)
    }
    if (exists("dataEX")) {
        rm (dataEX)
    }
    for (subset in 1:Subsets) {
        meta_tmp = read_tibble(filedir=tmpdir,
                               filename=paste0("meta_",
                                               subset,
                                               ".fst"))
        dataEX_tmp = read_tibble(filedir=tmpdir,
                                 filename=paste0("dataEX_",
                                                 subset,
                                                 ".fst"))

        # print(dataEX_tmp[dataEX_tmp$Code == "W2832020",])
        
        if (!exists("dataEX")) {
            meta = meta_tmp
        } else {
            meta = dplyr::bind_rows(meta, meta_tmp)
        }        
        if (!exists("dataEX")) {
            dataEX = dataEX_tmp
        } else {
            dataEX = dplyr::bind_rows(dataEX, dataEX_tmp)
        }
        # print(dataEX[dataEX$Code == "W2832020",])
    }
    rm (meta_tmp)
    rm (dataEX_tmp)

    dataEX = dataEX[order(dataEX$Model),]
    meta = meta[order(meta$Code),]

    Vars = names(dataEX)
    containSEA = grepl("SEA", Vars)
    if (any(containSEA)) {
        Vars_SEA = Vars[containSEA]
        SEAofVars = gsub("^.*[_]+", "", Vars_SEA)
        Vars_SEA = stringr::str_extract(Vars_SEA, "^.*[_]+")
        Vars_SEA = gsub("[_]$", "", Vars_SEA)
        for (i in 1:length(Vars_SEA)) {
            Vars_SEA[i] = gsub("SEA", SEAofVars[i], Vars_SEA[i])
        }
        Vars[containSEA] = Vars_SEA
    }
    names(dataEX) = Vars

    containSEA = grepl("SEA", metaEX$var)
    if (any(containSEA)) {
        Vars_SEA = metaEX$var[containSEA]
        SEAofVars = gsub("^.*[_]+", "", Vars_SEA)
        Vars_SEA = stringr::str_extract(Vars_SEA, "^.*[_]+")
        Vars_SEA = gsub("[_]$", "", Vars_SEA)
        for (i in 1:length(Vars_SEA)) {
            Vars_SEA[i] = gsub("SEA", SEAofVars[i], Vars_SEA[i])
        }
        metaEX$var[containSEA] = Vars_SEA
    }
    
    containSO = "([_]obs$)|([_]sim$)"
    Vars = Vars[grepl(containSO, Vars)]
    if (length(Vars) > 0) {
        VarsREL = gsub(containSO, "", Vars)
        VarsREL = VarsREL[!duplicated(VarsREL)]
        nVarsREL = length(VarsREL)
        
        for (i in 1:nVarsREL) {
            varREL = VarsREL[i]
            # print(varREL)
            if (grepl("^HYP.*", varREL)) {
                dataEX[[varREL]] =
                    dataEX[[paste0(varREL, "_sim")]] &
                    dataEX[[paste0(varREL, "_obs")]]

            } else if (grepl("(^t)|([{]t)", varREL)) {
                dataEX[[varREL]] =
                    circular_divided(
                        circular_minus(dataEX[[paste0(varREL, "_sim")]],
                                       dataEX[[paste0(varREL, "_obs")]],
                                       period=365.25),
                        dataEX[[paste0(varREL, "_obs")]],
                        period=365.25)
                
            } else {
                dataEX[[varREL]] =
                    (dataEX[[paste0(varREL, "_sim")]] -
                     dataEX[[paste0(varREL, "_obs")]]) /
                    dataEX[[paste0(varREL, "_obs")]]
            }
            dataEX = dplyr::relocate(dataEX,
                                     !!varREL,
                                     .after=!!paste0(varREL, "_sim"))
        }
    }

    # print(dataEX[dataEX$Code == "W2832020",])
    
}

if ('save_analyse' %in% to_do) {

    print(paste0("Save extracted data and metadata in ",
                 paste0(saving_format, collapse=", ")))
    
    if ("fst" %in% saving_format) {
        write_tibble(meta,
                     filedir=today_resdir,
                     filename=paste0("meta.fst"))
        write_tibble(metaEX,
                     filedir=today_resdir,
                     filename=paste0("metaEX.fst"))
        write_tibble(dataEX,
                     filedir=today_resdir,
                     filename=paste0("dataEX.fst"))
    }
    if ("Rdata" %in% saving_format) {
        write_tibble(meta,
                     filedir=today_resdir,
                     filename=paste0("meta.Rdata"))
        write_tibble(metaEX,
                     filedir=today_resdir,
                     filename=paste0("metaEX.Rdata"))
        write_tibble(dataEX,
                     filedir=today_resdir,
                     filename=paste0("dataEX.Rdata"))
    }    
    if ("txt" %in% saving_format) {
        write_tibble(meta,
                     filedir=today_resdir,
                     filename=paste0("meta.txt"))
        write_tibble(metaEX,
                     filedir=today_resdir,
                     filename=paste0("metaEX.txt"))
        write_tibble(dataEX,
                     filedir=today_resdir,
                     filename=paste0("dataEX.txt"))
    }  
}

if ('read_saving' %in% to_do) {

    print(paste0("Reading extracted data and metadata in ",
                 read_saving))
    
    Filenames = gsub("^.*[/]+", "", read_saving)
    Filenames = gsub("[.].*$", "", Filenames)
    nFile = length(Filenames)
    for (i in 1:nFile) {
        print(paste0(Filenames[i], " saves in ", read_saving[i]))
        assign(Filenames[i], read_tibble(filepath=read_saving[i]))
    }
}
