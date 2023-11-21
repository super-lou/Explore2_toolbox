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



manage_data = function () {

    for (i in 1:length(extract_data)) {
        extract = extract_data[[i]]

        if (exists("meta")) {
            rm ("meta", envir=.GlobalEnv)
            rm ("meta")
            gc()
        }
        if (exists("metaEX")) {
            rm ("metaEX", envir=.GlobalEnv)
            rm ("metaEX")
            gc()
        }
        if (exists("dataEX")) {
            rm ("dataEX", envir=.GlobalEnv)
            rm ("dataEX")
            gc()
        }
        
        for (j in 1:nSubsets_save) {
            subset_name = names(Subsets_save)[j]

            filename = paste0("meta_", files_name_opt.,
                              subset_name, ".fst")
            if (file.exists(file.path(tmppath, filename))) {
                meta_tmp = read_tibble(filedir=tmppath,
                                       filename=filename)
                
                if (!exists("meta")) {
                    meta = meta_tmp
                } else {
                    meta = dplyr::bind_rows(meta, meta_tmp)
                }
                rm ("meta_tmp")
                gc()
            }

            if (!exists("metaEX")) {
                filename = paste0("metaEX_", extract$name, "_",
                                  files_name_opt.,
                                  subset_name, ".fst")
                if (file.exists(file.path(tmppath, filename))) {
                    metaEX = read_tibble(filedir=tmppath,
                                         filename=filename)
                    
                }
            }
            
            dirname = paste0("dataEX_", extract$name, "_",
                             files_name_opt.,
                             subset_name)
            filename = paste0(dirname, ".fst")
            if (file.exists(file.path(tmppath, dirname)) |
                file.exists(file.path(tmppath, filename))) {
                dataEX_tmp = read_tibble(filedir=tmppath,
                                         filename=filename)

                
                if (!exists("dataEX")) {
                    dataEX = dataEX_tmp
                } else {
                    if (extract$type == "criteria") {
                        dataEX = dplyr::bind_rows(dataEX,
                                                  dataEX_tmp)
                    } else if (extract$type == "serie") {
                        for (k in 1:length(dataEX)) {
                            dataEX[[k]] =
                                dplyr::bind_rows(dataEX[[k]],
                                                 dataEX_tmp[[k]])
                            
                        }
                    }
                }
                rm ("dataEX_tmp"); gc()
            }
        }

        
        if (exists("dataEX")) {
            if (extract$type == "criteria") {

                regexp_bool = "^HYP.*"
                regexp_time =
                    "(^t)|([{]t)|(^debut)|([{]debut)|(^centre)|([{]centre)|(^fin)|([{]fin)"
                regexp_ratio_alpha = "^alpha"
                regexp_ratio = "(Rc)|(^epsilon)|(^a)|(^STD)"
                regexp_diff = "(R.*[_]ratio)|(moyTA)|(moyRA)"
                
                dataEX = dataEX[order(dataEX$Model),]
                
                Vars = colnames(dataEX)
                
                containSO = "([_]obs$)|([_]sim$)"
                Vars = Vars[grepl(containSO, Vars)]
                if (length(Vars) > 0) {
                    VarsREL = gsub(containSO, "", Vars)
                    VarsREL = VarsREL[!duplicated(VarsREL)]
                    nVarsREL = length(VarsREL)
                    
                    for (j in 1:nVarsREL) {
                        varREL = VarsREL[j]
                        
                        if (grepl(regexp_bool, varREL)) {
                            dataEX[[varREL]] =
                                dataEX[[paste0(varREL,
                                               "_sim")]] &
                                dataEX[[paste0(varREL,
                                               "_obs")]]

                            metaEX$glose[metaEX$var == varREL] =
                                paste0(metaEX$glose[metaEX$var == varREL],
                                       " (Comparaison entre les valeurs simulées et observées)")

                        } else if (grepl(regexp_time, varREL)) {
                            dataEX[[varREL]] =
                                circular_minus(
                                    dataEX[[paste0(varREL,
                                                   "_sim")]],
                                    dataEX[[paste0(varREL,
                                                   "_obs")]],
                                    period=365.25)/30.4375

                            metaEX$unit[metaEX$var == varREL] = "mois"
                            metaEX$isDate[metaEX$var == varREL] = FALSE
                            metaEX$glose[metaEX$var == varREL] =
                                paste0(metaEX$glose[metaEX$var == varREL],
                                       " (Écart normalisé entre les valeurs simulées et observées)")
                            

                        } else if (grepl(regexp_ratio_alpha,
                                         varREL)) {
                            
                            dataEX[[varREL]] =
                                dataEX[[paste0(varREL, "_sim")]] /
                                dataEX[[paste0(varREL, "_obs")]]

                            dataEX[[varREL]][
                                !dataEX[[paste0("HYP",
                                                varREL,
                                                "_obs")]]
                            ] = NA
                            
                            metaEX$unit[metaEX$var == varREL] = "sans unité"
                            metaEX$glose[metaEX$var == varREL] =
                                paste0(metaEX$glose[metaEX$var == varREL],
                                       " (Ratio entre les valeurs simulées et observées)")
                            
                        } else if (grepl(regexp_ratio, varREL)) {
                            dataEX[[varREL]] =
                                dataEX[[paste0(varREL, "_sim")]] /
                                dataEX[[paste0(varREL, "_obs")]]

                            metaEX$unit[metaEX$var == varREL] = "sans unité"
                            metaEX$glose[metaEX$var == varREL] =
                                paste0(metaEX$glose[metaEX$var == varREL],
                                       " (Ratio entre les valeurs simulées et observées)")

                        } else if (grepl(regexp_diff, varREL)) {
                            dataEX[[varREL]] =
                                round(dataEX[[paste0(varREL, "_sim")]] -
                                      dataEX[[paste0(varREL, "_obs")]], 5)
                            
                            metaEX$glose[metaEX$var == varREL] =
                                paste0(metaEX$glose[metaEX$var == varREL],
                                       " (Écart entre les valeurs simulées et observées)")

                        } else {
                            dataEX[[varREL]] =
                                (dataEX[[paste0(varREL,
                                                "_sim")]] -
                                 dataEX[[paste0(varREL,
                                                "_obs")]]) /
                                dataEX[[paste0(varREL,
                                               "_obs")]]
                            
                            metaEX$unit[metaEX$var == varREL] = "sans unité"
                            metaEX$glose[metaEX$var == varREL] =
                                paste0(metaEX$glose[metaEX$var == varREL],
                                       " (Ratio relatif entre les valeurs simulées et observées)")
                        }

                        dataEX =
                            dplyr::relocate(dataEX,
                                            !!varREL,
                                            .after=!!paste0(varREL,
                                                            "_sim"))
                    }
                }

            } else if (extract$type == "serie") {
                if ("Model" %in% names(dataEX[[1]])) {
                    for (j in 1:length(dataEX)) {
                        dataEX[[j]] =
                            dataEX[[j]][order(dataEX[[j]]$Model),]       
                    }
                }
            }
        }

        meta = meta[order(meta$Code),]
        write_tibble(meta,
                     filedir=tmppath,
                     filename=paste0("meta_", extract$name,
                                     .files_name_opt,
                                     ".fst"))
        write_tibble(dataEX,
                     filedir=tmppath,
                     filename=paste0("dataEX_", extract$name,
                                     .files_name_opt,
                                     ".fst"))
        write_tibble(metaEX,
                     filedir=tmppath,
                     filename=paste0("metaEX_", extract$name,
                                     .files_name_opt,
                                     ".fst"))
        
        if (exists("meta")) {
            rm ("meta"); gc()
        }
        if (exists("metaEX")) {
            rm ("metaEX"); gc()
        }
        if (exists("dataEX")) {
            rm ("dataEX"); gc()
        }
    }
}


save_data = function () {
    files_name_regexp = gsub("[_]", "[_]",
                             gsub("[-]", "[-]",
                                  files_name_opt))

    if (by_files | MPI == "file") {
        today_resdir_tmp = file.path(today_resdir,
                                     files_name_opt)
        pattern = paste0("data[_]", files_name_regexp,
                         ".*", "[.]fst")
    } else {
        today_resdir_tmp = today_resdir
        pattern = "data[_].*[.]fst"
    }

    if (!(file.exists(today_resdir_tmp))) {
        dir.create(today_resdir_tmp, recursive=TRUE)
    }

    data_paths = list.files(tmppath,
                            pattern=pattern,
                            full.names=TRUE)
    data_files = gsub("[_][_]", "_",
                      gsub(files_name_regexp, "",
                           basename(data_paths)))

    if ("data" %in% var2save) {
        file.copy(data_paths,
                  file.path(today_resdir_tmp, data_files))
    }
    
    for (i in 1:length(extract_data)) {
        extract = extract_data[[i]]

        dirname = paste0("dataEX_", extract$name,
                         .files_name_opt)
        filename = paste0(dirname, ".fst")
        if (file.exists(file.path(tmppath, dirname)) |
            file.exists(file.path(tmppath, filename))) {

            if ("meta" %in% var2save) {
                meta = read_tibble(filedir=tmppath,
                                   filename=paste0(
                                       "meta_",
                                       extract$name,
                                       .files_name_opt,
                                       ".fst"))
                
            }
            
            if ("metaEX" %in% var2save) {
                metaEX = read_tibble(filedir=tmppath,
                                     filename=paste0(
                                         "metaEX_",
                                         extract$name,
                                         .files_name_opt,
                                         ".fst"))
                
            }
            if ("dataEX" %in% var2save) {
                dataEX = read_tibble(filedir=tmppath,
                                     filename=paste0(
                                         "dataEX_",
                                         extract$name,
                                         .files_name_opt,
                                         ".fst"))
            }
        } else {
            next
        }

        if ("meta" %in% var2save) {
            write_tibble(meta,
                         filedir=today_resdir_tmp,
                         filename="meta.fst")
            if ("Rdata" %in% saving_format) {
                write_tibble(meta,
                             filedir=today_resdir_tmp,
                             filename="meta.Rdata")
            }
            if ("txt" %in% saving_format) {
                write_tibble(meta,
                             filedir=today_resdir_tmp,
                             filename="meta.txt")
            }
            if (!is.null(wait)) {
                post("Waiting for saving of meta data")
                Sys.sleep(wait)
            }
        }

        if ("metaEX" %in% var2save) {
            write_tibble(metaEX,
                         filedir=today_resdir_tmp,
                         filename=paste0("metaEX_",
                                         extract$name,
                                         ".fst"))
            if ("Rdata" %in% saving_format) {
                write_tibble(metaEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("metaEX_",
                                             extract$name,
                                             ".Rdata"))
            }
            if ("txt" %in% saving_format) {
                write_tibble(metaEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("metaEX_",
                                             extract$name,
                                             ".txt"))
            }
            if (!is.null(wait)) {
                post("Waiting for saving of extracted meta data")
                Sys.sleep(wait)
            }
        }


        if ("dataEX" %in% var2save) {
            write_tibble(dataEX,
                         filedir=today_resdir_tmp,
                         filename=paste0("dataEX_",
                                         extract$name,
                                         ".fst"))
            if ("Rdata" %in% saving_format) {
                write_tibble(dataEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("dataEX_",
                                             extract$name,
                                             ".Rdata"))
            }
            if ("txt" %in% saving_format) {
                write_tibble(dataEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("dataEX_",
                                             extract$name,
                                             ".txt"))
            }
        }
        
        if (exists("meta")) {
            rm ("meta")
            gc()
        }
        if (exists("metaEX")) {
            rm ("metaEX")
            gc()
        }
        if (exists("dataEX")) {
            rm ("dataEX")
            gc()
        }
    }
}



## 1. MANAGEMENT OF DATA ______________________________________________
if (!read_tmp & !clean_nc & !merge_nc & !delete_tmp) {

    if (MPI == "code") {
        if (rank == 0) {
            Root = rep(0, times=size)
            Root[1] = 1
            post(paste0(gsub("1", "-", 
                             gsub("0", "_",
                                  Root)), collapse=""))
            for (root in 1:(size-1)) {
                Root[root+1] = Rmpi::mpi.recv(as.integer(0),
                                              type=1,
                                              source=root,
                                              tag=1, comm=0)
                post(paste0("End signal for extract received from rank ", root))
                post(paste0(gsub("1", "-", 
                                 gsub("0", "_",
                                      Root)), collapse=""))
            }
        } else {
            Rmpi::mpi.send(as.integer(1), type=1, dest=0, tag=1, comm=0)
            post(paste0("End signal for extract from rank ", rank)) 
        }
    }
        
    if ('extract_data' %in% to_do) {
        if (MPI == "code" & rank == 0 |
            MPI != "code") {
            manage_data()
        }
    }
        
    if ('save_extract' %in% to_do) {
        if (MPI == "code" & rank == 0 |
            MPI != "code") {
            post("### Saving extracts")
            post(paste0("Save extracted data and metadata in ",
                        paste0(saving_format, collapse=", ")))
            
            save_data()
        }
    }


    if ('read_saving' %in% to_do) {
        post("### Reading saving")
        post(paste0("Reading extracted data and metadata in ",
                    read_saving))

        data = dplyr::tibble()
        dataEX_criteria = dplyr::tibble()
        dataEX_serie = dplyr::tibble()
        metaEX_criteria = dplyr::tibble()
        metaEX_serie = dplyr::tibble()

        name_criteria = c()
        name_serie = c()
        
        for (i in 1:length(extract_data)) {
            extract = extract_data[[i]]

            if (grepl("diagnostic", mode)) {
                path2search = file.path(resdir, read_saving)
            } else if (grepl("projection", mode)) {
                path2search = file.path(resdir, read_saving,
                                        Projections$dir)
            }
            
            Paths = list.files(path2search,
                               include.dirs=TRUE,
                               full.names=TRUE)
            Paths = Paths[!duplicated(Paths)]

            pattern = var2search
            pattern = paste0("(", paste0(pattern,
                                         collapse=")|("), ")")

            if (extract$type == "criteria") {
                name_criteria = c(name_criteria, extract$name)
                pattern = gsub("dataEX", paste0("dataEX[_]",
                                                gsub("[_]", "[_]",
                                                     extract$name),
                                                "[.]"),
                               pattern)
            } else if (extract$type == "serie") {
                name_serie = c(name_serie, extract$name)
                pattern = gsub("dataEX", paste0("dataEX[_]",
                                                gsub("[_]", "[_]",
                                                     extract$name),
                                                "$"),
                               pattern)
            }
            pattern = gsub("metaEX", paste0("metaEX[_]",
                                            gsub("[_]", "[_]",
                                                 extract$name),
                                            "[.]"),
                           pattern)
            
            Paths = Paths[grepl(pattern, Paths)]
            Paths = Paths[grepl("[.]fst", Paths) | !grepl("?[.]", Paths)]
            Paths[!grepl("[.]", Paths)] =
                paste0(Paths[!grepl("[.]", Paths)], ".fst")
            Filenames = gsub("^.*[/]+", "", Paths)
            Filenames = gsub("[.].*$", "", Filenames)
            nFile = length(Filenames)
            for (i in 1:nFile) {
                post(paste0(gsub("([_].*)|([.].*)",
                                 "", Filenames[i]), " reads in ", Paths[i]))

                tmp = read_tibble(filepath=Paths[i])
                
                if (grepl("dataEX.*criteria", Filenames[i])) {
                    tmp = dplyr::filter(tmp, Code %in% CodeALL10)
                    
                } else if (grepl("dataEX.*serie", Filenames[i])) {
                    for (k in 1:length(tmp)) {
                        tmp[[k]] =
                            dplyr::filter(tmp[[k]], Code %in% CodeALL10)
                    }
                }
                
                if (selection) {
                    if (grepl("diagnostic", mode)) {
                        if (grepl("criteria", Filenames[i])) {
                            by = names(tmp)[sapply(tmp, is.character)]
                            pattern = paste0("(",
                                             paste0(by, collapse=")|("),
                                             ")|(",
                                             paste0(diag_variable_selection,
                                                    collapse=")|("),
                                             ")")
                        } else if (grepl("serie", Filenames[i])) {
                            pattern = paste0("(",
                                             paste0(diag_variable_selection,
                                                    collapse=")|("),
                                             ")")
                        }

                    } else if (grepl("projection", mode)) {
                        pattern = paste0("(",
                                         paste0(proj_variable_selection,
                                                collapse=")|("),
                                         ")")
                    }

                    if (grepl("dataEX.*criteria", Filenames[i])) {
                        col2keep = sapply(names(tmp), any_grepl,
                                        pattern=pattern)
                        tmp = tmp[col2keep]

                        if (grepl("diagnostic", mode)) {
                            for (j in 1:length(diag_station_selection)) {
                                if (length(diag_station_selection) == 0) {
                                    break
                                }
                                model = names(diag_station_selection)[j]
                                code = diag_station_selection[j]
                                tmp = dplyr::filter(tmp,
                                                    !(Model == model &
                                                      grepl(code, Code)))  
                            }
                        }

                    } else if (grepl("metaEX.*criteria", Filenames[i])) {
                        row2keep = sapply(tmp$var, any_grepl,
                                        pattern=pattern)
                        tmp = tmp[row2keep,]

                        
                    } else if (grepl("dataEX.*serie", Filenames[i])) {
                        if (grepl("diagnostic", mode)) {
                            for (j in 1:length(diag_period_selection)) {
                                model = names(diag_period_selection)[j]
                                period = diag_period_selection[[j]]
                                start = period[1]
                                if (is.na(start)) {
                                    start = min(as.Date(period_extract_diag))
                                }
                                end = period[2]
                                if (is.na(end)) {
                                    end = max(as.Date(period_extract_diag))
                                }                        
                                for (k in 1:length(tmp)) {
                                    if (!("Date" %in% names(tmp[[k]])) |
                                        !any(sapply(tmp[[k]],
                                                    lubridate::is.Date))) {
                                        next
                                    }
                                    tmp[[k]] =
                                        dplyr::filter(tmp[[k]],
                                                      Model != model |
                                                      (Model == model & 
                                                       start < Date &
                                                       Date < end))
                                }

                            }
                            for (j in 1:length(diag_station_selection)) {
                                if (length(diag_station_selection) == 0) {
                                    break
                                }
                                model = names(diag_station_selection)[j]
                                code = diag_station_selection[j]
                                for (k in 1:length(tmp)) {
                                    tmp[[k]] =
                                        dplyr::filter(tmp[[k]],
                                                      !(Model == model &
                                                        grepl(code, Code)))
                                }
                            }
                        }

                        row2keep = sapply(names(tmp), any_grepl,
                                          pattern=pattern)
                        tmp = tmp[row2keep]
                        
                    } else if (grepl("metaEX.*serie", Filenames[i])) {
                        row2keep = sapply(tmp$var, any_grepl,
                                        pattern=pattern)
                        tmp = tmp[row2keep,]
                        
                    } else if (grepl("meta", Filenames[i]) &
                               grepl("diagnostic", mode)) {
                        for (j in 1:length(diag_station_selection)) {
                            if (length(diag_station_selection) == 0) {
                                break
                            }
                            model = names(diag_station_selection)[j]
                            code = diag_station_selection[j]
                            tmp[[paste0("Surface_",
                                        model, "_km2")]][grepl(code,
                                                               tmp$Code)] = NA
                        }
                    }
                }

                
                if (merge_read_saving) {

                    ### /!\ pour proj ###
                    if (grepl("dataEX.*criteria", Filenames[i])) {
                        if (nrow(dataEX_criteria) == 0) {
                            dataEX_criteria = tmp
                        } else {
                            character_cols =
                                names(dataEX_criteria)[sapply(dataEX_criteria,
                                                              is.character)]
                            dataEX_criteria =
                                dplyr::full_join(
                                           dataEX_criteria,
                                           tmp,
                                           by=character_cols)
                        }
                    ### /!\ pour proj ###

                        
                    } else if (grepl("dataEX.*serie", Filenames[i])) {
                        
                        if ("GCM" %in% names(tmp[[1]])) {
                            for (k in 1:length(tmp)) {
                                tmp[[k]] = tidyr::unite(tmp[[k]],
                                                        "climateChain",
                                                        "GCM", "EXP",
                                                        "RCM", "BC",
                                                        sep="|",
                                                        remove=FALSE)
                                tmp[[k]] = tidyr::unite(tmp[[k]],
                                                        "Chain",
                                                        "GCM", "EXP",
                                                        "RCM", "BC",
                                                        "Model",
                                                        sep="|",
                                                        remove=FALSE)
                            }
                        } else {
                            for (k in 1:length(tmp)) {
                                tmp[[k]]$climateChain = "SAFRAN"
                                tmp[[k]] = tidyr::unite(tmp[[k]],
                                                        "Chain",
                                                        "climateChain",
                                                        "Model",
                                                        sep="|",
                                                        remove=FALSE)
                                tmp[[k]] = dplyr::relocate(tmp[[k]],
                                                           climateChain,
                                                           .after=Chain)
                            }
                        }
                        
                        if (grepl("projection", mode)) {
                            names_in = names(tmp)[names(tmp) %in% names(dataEX_serie)]
                            names_out = names(tmp)[!(names(tmp) %in% names(dataEX_serie))]
                            if (length(names_in) > 0) {
                                for (name in names_in) {
                                    dataEX_serie[[name]] =
                                        dplyr::bind_rows(dataEX_serie[[name]],
                                                         tmp[[name]])
                                }
                            }
                            if (length(names_out) > 0) {
                                dataEX_serie =
                                    append(dataEX_serie, tmp[names_out])
                            }

                        } else if (grepl("diagnostic", mode)) {   
                            dataEX_serie =
                                append(dataEX_serie, tmp)
                        }
    
                    } else if (grepl("metaEX.*criteria", Filenames[i])) {
                        metaEX_criteria =
                            dplyr::bind_rows(metaEX_criteria,
                                             tmp[!(tmp$var %in% metaEX_criteria$var),])
                        
                    } else if (grepl("metaEX.*serie", Filenames[i])) {
                        metaEX_serie =
                            dplyr::bind_rows(metaEX_serie,
                                             tmp[!(tmp$var %in% metaEX_serie$var),])
                        
                    } else if (grepl("data[_]", Filenames[i])) {
                        data = dplyr::bind_rows(data, tmp)
                        
                    } else {
                        assign(Filenames[i], tmp)
                    }
                    
                } else {
                    assign(Filenames[i], tmp)
                }
            }
        }





        
        if (merge_read_saving) {
            extract_data_tmp = list()
            if (any(sapply(extract_data, '[[', 'type') == "criteria")) {
                extract_data_tmp =
                    append(extract_data_tmp,
                           list(list(name=name_criteria,
                                     type="criteria",
                                     variables=
                                         metaEX_criteria$var)))
                names(extract_data_tmp)[length(extract_data_tmp)] =
                    "criteria"
            }
            if (any(sapply(extract_data, '[[', 'type') == "serie")) {
                extract_data_tmp =
                    append(extract_data_tmp,
                           list(list(name=name_serie,
                                     type="serie",
                                     variables=metaEX_serie$var)))
                names(extract_data_tmp)[length(extract_data_tmp)] =
                    "serie"
            }
            extract_data = extract_data_tmp
        }

        
        if (!is.null(names(codes_to_use)) & exists("meta")) {
            info = dplyr::tibble(Code=codes_to_use,
                                 info=names(codes_to_use))
            meta = dplyr::left_join(meta, info, by="Code")
        }


        if (type == "piezometrie" & exists("meta")) {
            meta = get_couche_in_meta(meta)
        }
        
    }


    if ('write_warnings' %in% to_do) {
        post("### Writing warnings")
        for (i in 1:length(extract_data)) {
            extract = extract_data[[i]]

            if (extract$type == "criteria") {
                dataEX = get(paste0("dataEX_", extract$type))
                metaEX = get(paste0("metaEX_", extract$type))
                Warnings = find_Warnings(dataEX, metaEX,
                                         resdir=today_resdir,
                                         save=TRUE)
            }
        }
    }

    if ('add_regime_hydro' %in% to_do) {
        post("### Add hydro regime")

        for (i in 1:length(extract_data)) {
            extract = extract_data[[i]]

            if (extract$type == "serie") {
                dataEX = get(paste0("dataEX_", extract$type))
                meta = get("meta")
                meta =
                    dplyr::select(meta,
                                  !dplyr::starts_with("Regime_hydro_"))

                Code = levels(factor(dataEX$Code))
                nCode = length(Code)

                dataEXserieQM_obs =
                    dplyr::summarise(dplyr::group_by(dataEX$QM,
                                                     Code, Date),
                                     QM=median(QM_obs,
                                               na.rm=TRUE),
                                     .groups="drop")

                dataEXserieR_ratio =
                    dplyr::full_join(dataEX$Rl_ratio,
                                     dataEX$Rs_ratio,
                                     by=c("Code", "Model"))
                dataEXserieR_ratio =
                    dplyr::summarise(
                               dplyr::group_by(dataEXserieR_ratio,
                                               Code),
                               Rs_ratio=median(Rs_ratio_obs,
                                               na.rm=TRUE),
                               Rl_ratio=median(Rl_ratio_obs,
                                               na.rm=TRUE),
                               .groups="drop")

                regimeHydro = find_regimeHydro(dataEXserieQM_obs,
                                               lim_number=NULL,
                                               dataEXserieR_ratio)

                ok = names(regimeHydro) != "Code"
                names(regimeHydro)[ok] =
                    paste0("Regime_hydro_", names(regimeHydro)[ok])
                
                meta = dplyr::full_join(meta, regimeHydro, "Code")
                
                write_tibble(meta,
                             filedir=today_resdir,
                             filename="meta.fst")
            }
        }
    }

    
} else {
    if (read_tmp) {
        post("### Reading tmp")
        post(paste0("Reading tmp data in ", tmppath))
        Paths = list.files(tmppath,
                           pattern=paste0("(",
                                          paste0(var2search,
                                                 collapse=")|("),
                                          ")"),
                           include.dirs=TRUE,
                           full.names=TRUE)
        Paths = Paths[grepl("[.]fst", Paths) | !grepl("?[.]", Paths)]
        Paths[!grepl("[.]", Paths)] =
            paste0(Paths[!grepl("[.]", Paths)], ".fst")
        Filenames = gsub("^.*[/]+", "", Paths)
        Filenames = gsub("[.].*$", "", Filenames)
        nFile = length(Filenames)
        for (i in 1:nFile) {
            post(paste0(Filenames[i], " reads in ", Paths[i]))
            assign(Filenames[i], read_tibble(filepath=Paths[i]))
        }
        read_tmp = FALSE
    }


    if (clean_nc) {
        post("### Cleaning NetCDF file")
        proj_clean_dirpath = file.path(computer_data_path,
                                       type,
                                       "projection_clean")
        
        if (!dir.exists(proj_clean_dirpath)) {
            if (rank == 0) {
                dir.create(proj_clean_dirpath)
            } else {
                Sys.sleep(10)  
            }
        }
        
        nProjections = nrow(Projections)

        if (MPI == "file") {
            start = ceiling(seq(1, nProjections,
                                by=(nProjections/size)))
            if (any(diff(start) == 0)) {
                start = 1:nProjections
                end = start
            } else {
                end = c(start[-1]-1, nProjections)
            }
            
            if (rank+1 > nProjections) {
                Projections = dplyr::tibble()
            } else {
                Projections = Projections[start[rank+1]:end[rank+1],]
            }
        } 
        
        nProjections = nrow(Projections)

        if (nProjections > 0) {
        
            for (i in 1:nProjections) {
                proj = Projections[i,]
                proj_path = proj$path
                proj_file = proj$file
                proj_clean_path = file.path(proj_clean_dirpath, proj_file)
                
                post(paste0("#### Cleaning ", proj_file))

                code_rm_data_path = file.path(computer_data_path, type,
                                         code_correction_dir,
                                         paste0(proj$Model, "_rm.csv"))
                code_mv_data_path = file.path(computer_data_path, type,
                                         code_correction_dir,
                                         paste0(proj$Model, "_mv.csv"))
                
                if (file.exists(code_rm_data_path) &
                    file.exists(code_mv_data_path)) {

                    system(paste0("cp ", proj_path, " ", proj_clean_path))
                    
                    NC = ncdf4::nc_open(proj_clean_path,
                                        write=TRUE)

                    if (!("code_new" %in% names(NC$var))) {
                        dim = ncdf4::ncdim_def("code_strlen_new",
                                               "", 1:10,
                                               create_dimvar=FALSE,
                                               longname=NULL)
                        var = ncdf4::ncvar_def("code_new", "",
                                               list(dim,
                                                    NC$dim$station),
                                               longname="code of stations",
                                               prec="char")
                        NC = ncdf4::ncvar_add(NC, var)
                    }
                    
                    ncdf4::ncvar_put(NC, "code_new",
                                     substr(ncdf4::ncvar_get(NC, "code"),
                                            1, 10))


                    Code = ncdf4::ncvar_get(NC, "code")
                    nCode = length(Code)
                    XL93 = ncdf4::ncvar_get(NC, "L93_X")
                    YL93 = ncdf4::ncvar_get(NC, "L93_Y")

                    code_rm_data = read_tibble(code_rm_data_path)
                    code_mv_data = read_tibble(code_mv_data_path)
                    
                    if (nrow(code_mv_data) > 0) {
                        Code_mv_input = code_mv_data$AncienNom
                        XL93_mv = code_mv_data$AncienX
                        YL93_mv = code_mv_data$AncienY
                        Code_mv_output = code_mv_data$NouveauNom

                        Id_mv = c()
                        for (j in 1:length(Code_mv_input)) {
                            if (!is.na(XL93_mv[j]) & !is.na(YL93_mv[j])) {
                                id_mv = which(Code_mv_input[j] == Code &
                                              XL93_mv[j] == XL93 &
                                              YL93_mv[j] == YL93)
                            } else {
                                id_mv = which(Code_mv_input[j] == Code)
                            }
                            if (identical(id_mv, integer(0))) {
                                id_mv = NA
                            }
                            Id_mv = c(Id_mv, id_mv)
                        }

                        Code[Id_mv[!is.na(Id_mv)]] =
                            Code_mv_output[!is.na(Id_mv)]
                        ncdf4::ncvar_put(NC, "code", Code)
                        ncdf4::ncvar_put(NC, "code_new", Code)
                    }

                    if (nrow(code_rm_data) > 0) {
                        Code_rm = code_rm_data$AncienNom
                        XL93_rm = code_rm_data$AncienX
                        YL93_rm = code_rm_data$AncienY

                        Id_rm = c()
                        for (j in 1:length(Code_rm)) {
                            if (!is.na(XL93_rm[j]) &
                                !is.na(YL93_rm[j])) {
                                id_rm = which(Code_rm[j] == Code &
                                              XL93_rm[j] == XL93 &
                                              YL93_rm[j] == YL93)
                            } else {
                                id_rm = which(Code_rm[j] == Code)
                            }
                            Id_rm = c(Id_rm, max(id_rm))
                        }
                        
                        nDate = length(ncdf4::ncvar_get(NC, "time"))
                        Var = c("topologicalSurface",
                                "topologicalSurface_model",
                                "WGS84_lon", "WGS84_lat",
                                "WGS84_lon_model", "WGS84_lat_model",
                                "LII_Y", "LII_X",
                                "LII_Y_model", "LII_X_model",
                                "L93_Y", "L93_X",
                                "L93_Y_model", "L93_X_model")
                        Var_chr = c("name",  "network_origin",
                                    "code_type", "code", "code_new")

                        for (var in Var) {
                            if (!(var %in% names(NC$var))) {
                                next
                            }
                            value = ncdf4::ncvar_get(NC, var)
                            value[Id_rm] = NaN
                            ncdf4::ncvar_put(NC, var, value)
                            ncdf4::ncvar_change_missval(NC,
                                                        var,
                                                        NaN)
                        }

                        for (var in Var_chr) {
                            if (!(var %in% names(NC$var))) {
                                next
                            }
                            value = ncdf4::ncvar_get(NC, var)

                            print(value)
                            
                            n = max(nchar(value, allowNA=TRUE), na.rm=TRUE)
                            value[Id_rm] = strrep("X", n)
                            ncdf4::ncvar_put(NC, var, value)
                            ncdf4::ncvar_change_missval(NC,
                                                        var,
                                                        strrep("X", n))
                        }
                        
                        for (id_rm in Id_rm) {
                            ncdf4::ncvar_put(NC, "debit",
                                             start=c(id_rm, 1),
                                             count=c(1, -1),
                                             rep(NaN, nDate))
                        }
                    }

                    ncdf4::nc_close(NC)

                    proj_clean_path_tmp = gsub("[.]nc", "_tmp.nc", proj_clean_path)
                    
                    ncoCmd = paste0("ncks -h -x -C -v", " ",
                                    "code", " ",
                                    proj_clean_path, " ",
                                    proj_clean_path_tmp)
                    system(ncoCmd)
                    system(paste0("rm -f ", proj_clean_path))
                    system(paste0("mv ", proj_clean_path_tmp, " ",
                                  proj_clean_path))

                    ncoCmd = paste0("ncrename -h -d", " ",
                                    "code_strlen_new,code_strlen", " ",
                                    "-v code_new,code", " ",
                                    proj_clean_path, " ",
                                    proj_clean_path_tmp)
                    system(ncoCmd)
                    system(paste0("rm -f ", proj_clean_path))
                    system(paste0("mv ", proj_clean_path_tmp, " ",
                                  proj_clean_path))
                }
            }
        }
        
        clean_nc = FALSE
    }

    
    if (merge_nc) {
        post("### Merging NetCDF file by time for projection")
        proj_merge_dirpath = file.path(computer_data_path,
                                       type,
                                       "projection_merge")
        if (!dir.exists(proj_merge_dirpath)) {
            if (rank == 0) {
                dir.create(proj_merge_dirpath)
            } else {
                Sys.sleep(10)  
            }
        }

        Historicals =
            Projections[Projections$EXP ==
                        "historical" &
                        Projections$Model %in%
                        models_to_use,]
        nHistoricals = nrow(Historicals)

        if (MPI == "file") {
            start = ceiling(seq(1, nHistoricals,
                                by=(nHistoricals/size)))
            # end = c(start[-1]-1, nHistoricals)
            if (any(diff(start) == 0)) {
                start = 1:nHistoricals
                end = start
            } else {
                end = c(start[-1]-1, nHistoricals)
            }
            
            # Historicals = Historicals[start[rank+1]:end[rank+1],]
            if (rank+1 > nHistoricals) {
                Historicals = dplyr::tibble()
            } else {
                Historicals = Historicals[start[rank+1]:end[rank+1],]
            }
        } 
        
        nHistoricals = nrow(Historicals)
        flag = dplyr::tibble()

        if (nHistoricals > 0) {
        
            for (i in 1:nHistoricals) {
                historical = Historicals[i,]
                historical_path = historical$path
                NC_historical = ncdf4::nc_open(historical_path)
                Date = NetCDF_extrat_time(NC_historical)
                ncdf4::nc_close(NC_historical)
                minDate_historical = min(Date)
                maxDate_historical = max(Date)

                projs =
                    Projections[Projections$GCM ==
                                historical$GCM &
                                Projections$RCM ==
                                historical$RCM &
                                Projections$EXP !=
                                "historical" &
                                Projections$BC ==
                                historical$BC &
                                Projections$Model ==
                                historical$Model,]

                # jehfezoifjezoifjezoifjezoiji EROS
                projs = projs[substr(projs$file, "1", "15") ==
                              substr(historical$file, "1", "15"),]
                
                for (j in 1:nrow(projs)) {
                    proj = projs[j,]
                    proj_path = proj$path
                    proj_file = proj$file
                    proj_merge_file =
                        gsub("[_]rcp", "_historical-rcp", proj_file)
                    proj_merge_path =
                        file.path(proj_merge_dirpath,
                                  proj_merge_file)
                    
                    post(paste0("#### Merging ",
                                historical$file, " with ",
                                proj$file, " in ",
                                proj_merge_file))

                    # cdoCmd = paste0("cdo", " ",
                                    # "--sortname --history -O mergetime", " ",
                                    # historical_path, " ",
                                    # proj_path, " ", 
                                    # proj_merge_path)
                    # system(cdoCmd)

                    # ncoCmd = paste0("ncks -h -A -O -v", " ",
                    # "code,code_type,L93,LII,name,network_origin", " ",
                    # historical_path, " ",
                    # proj_merge_path)
                    # system(ncoCmd)

                    ncoCmd = paste0("ncrcat -h", " ",
                                    historical_path, " ",
                                    proj_path, " ",
                                    "-O ", proj_merge_path)
                    system(ncoCmd)

                    NC_proj = ncdf4::nc_open(proj_path)
                    Date = NetCDF_extrat_time(NC_proj)
                    minDate_proj = min(Date)
                    maxDate_proj = max(Date)
                    ncdf4::nc_close(NC_proj)

                    flag = dplyr::bind_rows(
                                      flag,
                                      dplyr::tibble(Chain=proj$Chain,
                                                    start_historical=
                                                        minDate_historical,
                                                    end_historical=
                                                        maxDate_historical,
                                                    start_proj=
                                                        minDate_proj,
                                                    end_proj=
                                                        maxDate_proj,
                                                    gap=minDate_proj -
                                                        maxDate_historical))
                }
            }
        }
        
        if (nrow(flag) > 0) {            
            flag = tidyr::separate(flag, col="Chain",
                                   into=c("GCM", "EXP", "RCM",
                                          "BC", "Model"), sep="[|]")
            write_tibble(flag, tmppath,
                         paste0("flag_", rank , ".fst"))
        }

        if (MPI == "file" & rank == 0) {
            Root = rep(0, times=size)
            Root[1] = 1
            post("Waiting for rank 1 : ")
            post(paste0(gsub("1", "-", 
                             gsub("0", "_",
                                  Root)), collapse=""))
            for (root in 1:(size-1)) {
                Root[root+1] = Rmpi::mpi.recv(as.integer(0),
                                              type=1,
                                              source=root,
                                              tag=1, comm=0)
                post(paste0("End signal received from rank ", root))
                post(paste0("Waiting for rank ", root+1, " : "))
                post(paste0(gsub("1", "-", 
                                 gsub("0", "_",
                                      Root)), collapse=""))
            }

            flag = dplyr::tibble()
            for (root in 0:(size-1)) {
                path = file.path(tmppath, paste0("flag_", root , ".fst"))
                if (file.exists(path)) {
                    flag_tmp = read_tibble(path)
                    flag = dplyr::bind_rows(flag, flag_tmp)
                }
            }
            write_tibble(flag, today_resdir, "flag.txt")
            
        } else if (MPI == "file") {
            Rmpi::mpi.send(as.integer(1), type=1, dest=0, tag=1, comm=0)
            post(paste0("End signal from rank ", rank))

        } else {
            write_tibble(flag, today_resdir, "flag.txt")
        }
        
        merge_nc = FALSE
    }

    
    if (delete_tmp) {
        post("### Deleting tmp")
        if (file.exists(tmppath) & rank == 0) {
            unlink(tmppath, recursive=TRUE)
        }
        delete_tmp = FALSE
    }
}
