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

    # print(dataEXind[dataEXind$Code == "W2832020",])

    indOK = grepl("indicator", analyse_data)
    if (any(indOK)) {
        
        if (exists("meta")) {
            rm (meta)
        }
        if (exists("dataEXind")) {
            rm (dataEXind)
        }
        for (subset in 1:Subsets) {
            meta_tmp = read_tibble(filedir=tmpdir,
                                   filename=paste0("meta_",
                                                   subset,
                                                   ".fst"))
            dataEXind_tmp = read_tibble(filedir=tmpdir,
                                        filename=paste0("dataEXind_",
                                                        subset,
                                                        ".fst"))
            if (!exists("dataEXind")) {
                meta = meta_tmp
            } else {
                meta = dplyr::bind_rows(meta, meta_tmp)
            }        
            if (!exists("dataEXind")) {
                dataEXind = dataEXind_tmp
            } else {
                dataEXind = dplyr::bind_rows(dataEXind, dataEXind_tmp)
            }
        }
        rm (meta_tmp)
        rm (dataEXind_tmp)

        dataEXind = dataEXind[order(dataEXind$Model),]
        meta = meta[order(meta$Code),]

        Vars = colnames(dataEXind)
        
        containSO = "([_]obs$)|([_]sim$)"
        Vars = Vars[grepl(containSO, Vars)]
        if (length(Vars) > 0) {
            VarsREL = gsub(containSO, "", Vars)
            VarsREL = VarsREL[!duplicated(VarsREL)]
            nVarsREL = length(VarsREL)
            
            for (i in 1:nVarsREL) {
                varREL = VarsREL[i]
                if (grepl("^HYP.*", varREL)) {
                    dataEXind[[varREL]] =
                        dataEXind[[paste0(varREL, "_sim")]] &
                        dataEXind[[paste0(varREL, "_obs")]]

                } else if (grepl("(^t)|([{]t)", varREL)) {
                    dataEXind[[varREL]] =
                        circular_divided(
                            circular_minus(dataEXind[[paste0(varREL, "_sim")]],
                                           dataEXind[[paste0(varREL, "_obs")]],
                                           period=365.25),
                            dataEXind[[paste0(varREL, "_obs")]],
                            period=365.25)
                    
                } else if (grepl("(Rc)|(epsilon)", varREL)) {
                    dataEXind[[varREL]] =
                        dataEXind[[paste0(varREL, "_sim")]] /
                        dataEXind[[paste0(varREL, "_obs")]]
                    
                } else {
                    dataEXind[[varREL]] =
                        (dataEXind[[paste0(varREL, "_sim")]] -
                         dataEXind[[paste0(varREL, "_obs")]]) /
                        dataEXind[[paste0(varREL, "_obs")]]
                }
                dataEXind = dplyr::relocate(dataEXind,
                                            !!varREL,
                                            .after=!!paste0(varREL, "_sim"))
            }
        }
    }
}

if ('save_analyse' %in% to_do) {

    print(paste0("Save extracted data and metadata in ",
                 paste0(saving_format, collapse=", ")))
    
    if ("fst" %in% saving_format) {
        write_tibble(meta,
                     filedir=today_resdir,
                     filename=paste0("meta.fst"))
        write_tibble(metaEXind,
                     filedir=today_resdir,
                     filename=paste0("metaEXind.fst"))
        write_tibble(dataEXind,
                     filedir=today_resdir,
                     filename=paste0("dataEXind.fst"))
    }
    if ("Rdata" %in% saving_format) {
        write_tibble(meta,
                     filedir=today_resdir,
                     filename=paste0("meta.Rdata"))
        write_tibble(metaEXind,
                     filedir=today_resdir,
                     filename=paste0("metaEXind.Rdata"))
        write_tibble(dataEXind,
                     filedir=today_resdir,
                     filename=paste0("dataEXind.Rdata"))
    }    
    if ("txt" %in% saving_format) {
        write_tibble(meta,
                     filedir=today_resdir,
                     filename=paste0("meta.txt"))
        write_tibble(metaEXind,
                     filedir=today_resdir,
                     filename=paste0("metaEXind.txt"))
        write_tibble(dataEXind,
                     filedir=today_resdir,
                     filename=paste0("dataEXind.txt"))
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

if ('select_var' %in% to_do) {
    res = get_select(dataEXind, metaEXind, select=var_selection)
    dataEXind = res$dataEXind
    metaEXind = res$metaEXind
}
