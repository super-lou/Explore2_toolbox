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
if (!('delete_tmp' %in% to_do)) {
    if ('analyse_data' %in% to_do) {

        if (exists("meta")) {
            rm (meta)
        }
        for (subset in 1:Subsets) {
            meta_tmp = read_tibble(filedir=tmpdir,
                                   filename=paste0("meta_",
                                                   subset,
                                                   ".fst"))
            if (!exists("meta")) {
                meta = meta_tmp
            } else {
                meta = dplyr::bind_rows(meta, meta_tmp)
            }
        }
        rm (meta_tmp)
        meta = meta[order(meta$Code),]
        

        if (any(grepl("indicator", analyse_data))) {

            metaEXind = read_tibble(filedir=tmpdir,
                                    filename="metaEXind.fst")
            
            if (exists("dataEXind")) {
                rm (dataEXind)
            }
            for (subset in 1:Subsets) {
                dataEXind_tmp = read_tibble(filedir=tmpdir,
                                            filename=paste0("dataEXind_",
                                                            subset,
                                                            ".fst"))
                if (!exists("dataEXind")) {
                    dataEXind = dataEXind_tmp
                } else {
                    dataEXind = dplyr::bind_rows(dataEXind, dataEXind_tmp)
                }
            }
            rm (dataEXind_tmp)

            dataEXind = dataEXind[order(dataEXind$Model),]
            
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
                            circular_minus(
                                dataEXind[[paste0(varREL, "_sim")]],
                                dataEXind[[paste0(varREL, "_obs")]],
                                period=365.25)/30.4375

                    } else if (grepl("(Rc)|($epsilon)|($alpha)", varREL)) {
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


        if (any(grepl("serie", analyse_data))) {

            metaEXserie = read_tibble(filedir=tmpdir,
                                      filename="metaEXserie.fst")
            
            if (exists("dataEXserie")) {
                rm (dataEXserie)
            }
            for (subset in 1:Subsets) {
                dataEXserie_tmp = read_tibble(
                    filedir=tmpdir,
                    filename=paste0("dataEXserie_",
                                    subset,
                                    ".fst"))
                if (!exists("dataEXserie")) {
                    dataEXserie = dataEXserie_tmp
                } else {
                    for (i in 1:length(dataEXserie)) {
                        dataEXserie[[i]] =
                            dplyr::bind_rows(dataEXserie[[i]],
                                             dataEXserie_tmp[[i]])
                    }
                }
            }
            rm (dataEXserie_tmp)
            
            for (i in 1:length(dataEXserie)) {
                dataEXserie[[i]] = dataEXserie[[i]][order(dataEXserie[[i]]$Model),]
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
            if (any(grepl("indicator", analyse_data))) {
                write_tibble(metaEXind,
                             filedir=today_resdir,
                             filename=paste0("metaEXind.fst"))
                write_tibble(dataEXind,
                             filedir=today_resdir,
                             filename=paste0("dataEXind.fst"))
            }
            if (any(grepl("serie", analyse_data))) {
                write_tibble(metaEXserie,
                             filedir=today_resdir,
                             filename=paste0("metaEXserie.fst"))
                write_tibble(dataEXserie,
                             filedir=today_resdir,
                             filename=paste0("dataEXserie.fst"))
            }
        }
        if ("Rdata" %in% saving_format) {
            write_tibble(meta,
                         filedir=today_resdir,
                         filename=paste0("meta.Rdata"))
            if (any(grepl("indicator", analyse_data))) {
                write_tibble(metaEXind,
                             filedir=today_resdir,
                             filename=paste0("metaEXind.Rdata"))
                write_tibble(dataEXind,
                             filedir=today_resdir,
                             filename=paste0("dataEXind.Rdata"))
            }
            if (any(grepl("serie", analyse_data))) {
                write_tibble(metaEXserie,
                             filedir=today_resdir,
                             filename=paste0("metaEXserie.Rdata"))
                write_tibble(dataEXserie,
                             filedir=today_resdir,
                             filename=paste0("dataEXserie.Rdata"))
            }
        }    
        if ("txt" %in% saving_format) {
            write_tibble(meta,
                         filedir=today_resdir,
                         filename=paste0("meta.txt"))
            if (any(grepl("indicator", analyse_data))) {
                write_tibble(metaEXind,
                             filedir=today_resdir,
                             filename=paste0("metaEXind.txt"))
                write_tibble(dataEXind,
                             filedir=today_resdir,
                             filename=paste0("dataEXind.txt"))
            }
            if (any(grepl("serie", analyse_data))) {
                write_tibble(metaEXserie,
                             filedir=today_resdir,
                             filename=paste0("metaEXserie.txt"))
                write_tibble(dataEXserie,
                             filedir=today_resdir,
                             filename=paste0("dataEXserie.txt"))
            }
        }  
    }

    if ('read_saving' %in% to_do) {

        print(paste0("Reading extracted data and metadata in ",
                     read_saving))
        
        Filenames = gsub("^.*[/]+", "", read_saving)
        Filenames = gsub("[.].*$", "", Filenames)
        nFile = length(Filenames)
        for (i in 1:nFile) {
            print(paste0(Filenames[i], " reads in ", read_saving[i]))
            assign(Filenames[i], read_tibble(filepath=read_saving[i]))
        } 
    }

    if ('select_var' %in% to_do) {
        res = get_select(dataEXind, metaEXind, select=var_selection)
        dataEXind = res$dataEXind
        metaEXind = res$metaEXind
    }
}

if ('delete_tmp' %in% to_do) {
    if (file.exists(tmpdir)) {
        unlink(tmpdir, recursive=TRUE)
    }
    to_do = to_do[to_do !='delete_tmp']
}
