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
                
                dataEX = dataEX[order(dataEX$HM),]
                
                Variables = colnames(dataEX)
                
                containSO = "([_]obs$)|([_]sim$)"
                Variables = Variables[grepl(containSO, Variables)]
                if (length(Variables) > 0) {
                    VariablesREL = gsub(containSO, "", Variables)
                    VariablesREL = VariablesREL[!duplicated(VariablesREL)]
                    nVariablesREL = length(VariablesREL)
                    
                    for (j in 1:nVariablesREL) {
                        variableREL = VariablesREL[j]
                        
                        if (grepl(regexp_bool, variableREL)) {
                            dataEX[[variableREL]] =
                                dataEX[[paste0(variableREL,
                                               "_sim")]] &
                                dataEX[[paste0(variableREL,
                                               "_obs")]]

                            metaEX$glose[metaEX$variable_en == variableREL] =
                                paste0(metaEX$glose[metaEX$variable_en == variableREL],
                                       " (Comparaison entre les valeurs simulées et observées)")

                        } else if (grepl(regexp_time, variableREL)) {
                            dataEX[[variableREL]] =
                                circular_minus(
                                    dataEX[[paste0(variableREL,
                                                   "_sim")]],
                                    dataEX[[paste0(variableREL,
                                                   "_obs")]],
                                    period=365.25)/30.4375

                            metaEX$unit[metaEX$variable_en == variableREL] = "mois"
                            metaEX$isDate[metaEX$variable_en == variableREL] = FALSE
                            metaEX$glose[metaEX$variable_en == variableREL] =
                                paste0(metaEX$glose[metaEX$variable_en == variableREL],
                                       " (Écart normalisé entre les valeurs simulées et observées)")
                            

                        } else if (grepl(regexp_ratio_alpha,
                                         variableREL)) {
                            
                            dataEX[[variableREL]] =
                                dataEX[[paste0(variableREL, "_sim")]] /
                                dataEX[[paste0(variableREL, "_obs")]]

                            dataEX[[variableREL]][
                                !dataEX[[paste0("HYP",
                                                variableREL,
                                                "_obs")]]
                            ] = NA
                            
                            metaEX$unit[metaEX$variable_en == variableREL] = "sans unité"
                            metaEX$glose[metaEX$variable_en == variableREL] =
                                paste0(metaEX$glose[metaEX$variable_en == variableREL],
                                       " (Ratio entre les valeurs simulées et observées)")
                            
                        } else if (grepl(regexp_ratio, variableREL)) {
                            dataEX[[variableREL]] =
                                dataEX[[paste0(variableREL, "_sim")]] /
                                dataEX[[paste0(variableREL, "_obs")]]

                            metaEX$unit[metaEX$variable_en == variableREL] = "sans unité"
                            metaEX$glose[metaEX$variable_en == variableREL] =
                                paste0(metaEX$glose[metaEX$variable_en == variableREL],
                                       " (Ratio entre les valeurs simulées et observées)")

                        } else if (grepl(regexp_diff, variableREL)) {
                            dataEX[[variableREL]] =
                                round(dataEX[[paste0(variableREL, "_sim")]] -
                                      dataEX[[paste0(variableREL, "_obs")]], 5)
                            
                            metaEX$glose[metaEX$variable_en == variableREL] =
                                paste0(metaEX$glose[metaEX$variable_en == variableREL],
                                       " (Écart entre les valeurs simulées et observées)")

                        } else {
                            dataEX[[variableREL]] =
                                (dataEX[[paste0(variableREL,
                                                "_sim")]] -
                                 dataEX[[paste0(variableREL,
                                                "_obs")]]) /
                                dataEX[[paste0(variableREL,
                                               "_obs")]]
                            
                            metaEX$unit[metaEX$variable_en == variableREL] = "sans unité"
                            metaEX$glose[metaEX$variable_en == variableREL] =
                                paste0(metaEX$glose[metaEX$variable_en == variableREL],
                                       " (Ratio relatif entre les valeurs simulées et observées)")
                        }

                        dataEX =
                            dplyr::relocate(dataEX,
                                            !!variableREL,
                                            .after=!!paste0(variableREL,
                                                            "_sim"))
                    }
                }

            } else if (extract$type == "serie") {
                if ("HM" %in% names(dataEX[[1]])) {
                    for (j in 1:length(dataEX)) {
                        if (nrow(dataEX[[j]]) == 0) {
                            next
                        }
                        dataEX[[j]] =
                            dataEX[[j]][order(dataEX[[j]]$HM),]       
                    }
                }
            }
        }
        
        if (exists("meta")) {
            meta = meta[order(meta$code),]
            write_tibble(meta,
                         filedir=tmppath,
                         filename=paste0("meta_", extract$name,
                                         .files_name_opt,
                                         ".fst"))
            rm ("meta"); gc()
        }
        if (exists("dataEX")) {
            write_tibble(dataEX,
                         filedir=tmppath,
                         filename=paste0("dataEX_", extract$name,
                                         .files_name_opt,
                                         ".fst"))
            rm ("dataEX"); gc()
        }
        if (exists("metaEX")) {
            write_tibble(metaEX,
                         filedir=tmppath,
                         filename=paste0("metaEX_", extract$name,
                                         .files_name_opt,
                                         ".fst"))
            rm ("metaEX"); gc()
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

    if ("data" %in% variable2save) {
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

            if ("meta" %in% variable2save) {
                meta = read_tibble(filedir=tmppath,
                                   filename=paste0(
                                       "meta_",
                                       extract$name,
                                       .files_name_opt,
                                       ".fst"))
                
            }
            
            if ("metaEX" %in% variable2save) {
                metaEX = read_tibble(filedir=tmppath,
                                     filename=paste0(
                                         "metaEX_",
                                         extract$name,
                                         .files_name_opt,
                                         ".fst"))
                
            }
            if ("dataEX" %in% variable2save) {
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

        if ("meta" %in% variable2save) {
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
        }

        if ("metaEX" %in% variable2save) {
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
        }


        if ("dataEX" %in% variable2save) {
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
    
    if ('create_data' %in% to_do | 'extract_data' %in% to_do) {
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

        # stop()
        
        post("### Reading saving")
        post(paste0("Reading extracted data and metadata in ",
                    read_saving))

        data = dplyr::tibble()
        meta = dplyr::tibble()
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
                # path2search = file.path(resdir, read_saving,
                # Projections$dir)
                path2search = Projections$path
            }
            
            Paths = list.files(path2search,
                               include.dirs=TRUE,
                               full.names=TRUE,
                               recursive=TRUE)
            Paths = Paths[!duplicated(Paths)]

            pattern = variable2search
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

            dataEX_criteria_extract = dplyr::tibble()
            
            for (ii in 1:nFile) {
                post(paste0(gsub("([_].*)|([.].*)",
                                 "", Filenames[ii]), " reads in ",
                            Paths[ii]))

                
                if (grepl("projection", mode) &
                    grepl("dataEX.*serie", Filenames[ii]) &
                    selection_before_reading_for_projection) {
                    print("selection before reading for projection")

                    metaEX_tmp = read_tibble(filepath=gsub("dataEX",
                                                           "metaEX",
                                                           Paths[ii]))
                    variables_to_read =
                        metaEX_tmp$variable_en[sapply(metaEX_tmp$variable_en,
                                                      any_grepl, pattern=variables_regexp)]

                    tmp = list()
                    if (length(variables_to_read) > 0) {
                        Paths_variable = file.path(gsub("[.]fst", "", Paths[ii]),
                                                   paste0(variables_to_read, ".fst"))
                        
                        for (j in 1:length(Paths_variable)) {
                            tmp = append(tmp,
                                         list(read_tibble(filepath=Paths_variable[j])))
                            names(tmp)[length(tmp)] = variables_to_read[j]
                        }
                    }
                } else {
                    tmp = read_tibble(filepath=Paths[ii])
                }
                

                if (tibble::is_tibble(tmp)) {
                    if (nrow(tmp) == 0) {
                        next
                    }
                } else {
                    if (length(tmp) == 0) {
                        next
                    }
                }
                

                if (grepl("dataEX.*criteria", Filenames[ii])) {
                    tmp = dplyr::filter(tmp, code %in% Code_selection)

                    by = names(tmp)[sapply(tmp, is.character)]
                    pattern_by = paste0("(",
                                        paste0(by, collapse=")|("),
                                        ")|", variables_regexp)

                    col2keep = sapply(names(tmp), any_grepl,
                                      pattern=pattern_by)
                    tmp = tmp[col2keep]

                    if (grepl("diagnostic", mode)) {
                        for (j in 1:length(diag_station_selection)) {
                            if (length(diag_station_selection) == 0) {
                                break
                            }
                            hm_selection =
                                names(diag_station_selection)[j]
                            code_selection = diag_station_selection[j]
                            tmp = dplyr::filter(tmp,
                                                !(HM == hm_selection &
                                                  grepl(code_selection,
                                                        code)))  
                        }
                    }

                    
                } else if (grepl("dataEX.*serie", Filenames[ii])) {
                    for (k in 1:length(tmp)) {
                        if (nrow(tmp[[k]]) == 0) {
                            next
                        }
                        tmp[[k]] =
                            dplyr::filter(tmp[[k]],
                                          code %in% Code_selection)
                    }
                    
                    row2keep = sapply(names(tmp), any_grepl,
                                      pattern=variables_regexp)
                    tmp = tmp[row2keep]
                    
                    if (grepl("diagnostic", mode)) {
                        for (j in 1:length(diag_period_selection)) {
                            hm = names(diag_period_selection)[j]
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
                                if (!("date" %in% names(tmp[[k]])) |
                                    !any(sapply(tmp[[k]],
                                                lubridate::is.Date))) {
                                    next
                                }
                                tmp[[k]] =
                                    dplyr::filter(tmp[[k]],
                                                  HM != hm |
                                                  (HM == hm & 
                                                   start < date &
                                                   date < end))
                            }
                        }
                        for (j in 1:length(diag_station_selection)) {
                            if (length(diag_station_selection) == 0) {
                                break
                            }
                            hm_selection = names(diag_station_selection)[j]
                            code_selection = diag_station_selection[j]
                            for (k in 1:length(tmp)) {
                                tmp[[k]] =
                                    dplyr::filter(tmp[[k]],
                                                  !(HM == hm_selection &
                                                    grepl(code_selection,
                                                          code)))
                            }
                        }
                    }

                    
                } else if (grepl("metaEX.*criteria", Filenames[ii])) {
                    row2keep = sapply(tmp$variable_en, any_grepl,
                                      pattern=variables_regexp)
                    tmp = tmp[row2keep,]

                
                } else if (grepl("metaEX.*serie", Filenames[ii])) {
                    row2keep = sapply(tmp$variable_en, any_grepl,
                                      pattern=variables_regexp)
                    tmp = tmp[row2keep,]
                

                } else if (grepl("meta", Filenames[ii])) {
                    tmp = dplyr::filter(tmp, code %in% Code_selection)

                    if (grepl("diagnostic", mode)) {
                        for (j in 1:length(diag_station_selection)) {
                            if (length(diag_station_selection) == 0) {
                                break
                            }
                            hm = names(diag_station_selection)[j]
                            code = diag_station_selection[j]
                            tmp[[paste0("surface_",
                                        hm, "_km2")]][grepl(code,
                                                            tmp$code)] = NA
                        }
                    }
                }


                if (length(tmp) > 0) {

                    ### /!\ pour proj ###
                    if (grepl("dataEX.*criteria", Filenames[ii])) {
                        # if (nrow(dataEX_criteria) == 0) {
                        #     dataEX_criteria = tmp

                        # } else {
                            # character_cols =
                            #     names(tmp)[sapply(tmp, is.character)]

                            # cols2join = names(tmp)[!(names(tmp) %in%
                            #                          names(dataEX_criteria))]
                            # cols2join = cols2join[!(cols2join %in%
                            #                         character_cols)]

                            # if (length(cols2join) > 0) {
                            #     print("join")
                            #     stop()
                                
                            #     dataEX_criteria =
                            #         dplyr::full_join(
                            #                    dataEX_criteria,
                            #                    dplyr::select(tmp,
                            #                                  dplyr::all_of(c(character_cols,
                            #                                                  cols2join))),
                            #                    by=character_cols)
                            # }

                            # cols2bind = names(tmp)[(names(tmp) %in%
                            #                          names(dataEX_criteria))]
                            # cols2bind = cols2bind[!(cols2bind %in%
                            #                         character_cols)]

                            # if (length(cols2bind) > 0) {
                            #     print("bind")
                            #     # stop()
                                
                            #     dataEX_criteria =
                            #         dplyr::bind_rows(
                            #                    dataEX_criteria,
                            #                    dplyr::select(tmp,
                            #                                  dplyr::all_of(c(character_cols,
                            #                                                  cols2bind))))
                            # }

                            
                            # dataEX_criteria =
                            #     dplyr::full_join(
                            #                dataEX_criteria,
                            #                tmp,
                        #                by=character_cols)

                        if (grepl("projection", mode)) {
                            if ("GCM" %in% names(tmp)) {
                                tmp = tidyr::unite(tmp,
                                                   "climateChain",
                                                   "GCM", "EXP",
                                                   "RCM", "BC",
                                                   sep="|",
                                                   remove=FALSE)
                                tmp = tidyr::unite(tmp,
                                                   "Chain",
                                                   "GCM", "EXP",
                                                   "RCM", "BC",
                                                   "HM",
                                                   sep="|",
                                                   remove=FALSE)
                            } else {
                                tmp$climateChain = "SAFRAN"
                                tmp = tidyr::unite(tmp,
                                                   "Chain",
                                                   "climateChain",
                                                   "HM",
                                                   sep="|",
                                                   remove=FALSE)
                                tmp = dplyr::relocate(tmp,
                                                      climateChain,
                                                      .after=Chain)
                            }
                        }
                        
                        dataEX_criteria_extract =
                            dplyr::bind_rows(dataEX_criteria_extract, tmp)
                        
                        # }
                        ### /!\ pour proj ###

                        
                    } else if (grepl("dataEX.*serie", Filenames[ii])) {

                        if (grepl("projection", mode)) {
                            if ("GCM" %in% names(tmp[[1]])) {
                                for (k in 1:length(tmp)) {
                                    if (nrow(tmp[[k]]) == 0) {
                                        next
                                    } 
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
                                                            "HM",
                                                            sep="|",
                                                            remove=FALSE)
                                }
                            } else {
                                for (k in 1:length(tmp)) {
                                    if (nrow(tmp[[k]]) == 0) {
                                        next
                                    } 
                                    tmp[[k]]$climateChain = "SAFRAN"
                                    tmp[[k]] = tidyr::unite(tmp[[k]],
                                                            "Chain",
                                                            "climateChain",
                                                            "HM",
                                                            sep="|",
                                                            remove=FALSE)
                                    tmp[[k]] = dplyr::relocate(tmp[[k]],
                                                               climateChain,
                                                               .after=Chain)
                                }
                            }
                            
                            names_in = names(tmp)[names(tmp) %in%
                                                  names(dataEX_serie)]
                            names_out = names(tmp)[!(names(tmp) %in%
                                                     names(dataEX_serie))]
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
                        
                    } else if (grepl("metaEX.*criteria", Filenames[ii])) {
                        metaEX_criteria =
                            dplyr::bind_rows(metaEX_criteria,
                                             tmp[!(tmp$variable_en %in% metaEX_criteria$variable_en),])
                        
                    } else if (grepl("metaEX.*serie", Filenames[ii])) {
                        metaEX_serie =
                            dplyr::bind_rows(metaEX_serie,
                                             tmp[!(tmp$variable_en %in% metaEX_serie$variable_en),])
                        
                    } else if (grepl("data[_]", Filenames[ii])) {
                        data = dplyr::bind_rows(data, tmp)

                    } else if (grepl("^meta$", Filenames[ii])) {
                        if (nrow(meta) == 0) {
                            meta = tmp
                        } else {
                            meta = dplyr::full_join(meta, tmp)
                        }
                        
                    } else {
                        assign(Filenames[ii], tmp)
                    }
                    
                } else {
                    assign(Filenames[ii], tmp)
                }
            }


            if (nrow(dataEX_criteria) == 0) {
                dataEX_criteria = dataEX_criteria_extract
            } else {
                character_cols =
                    names(dataEX_criteria_extract)[sapply(dataEX_criteria_extract,
                                                          is.character)]

                dataEX_criteria =
                    dplyr::full_join(dataEX_criteria,
                                     dataEX_criteria_extract,
                                     by=character_cols)
            }
        }
        
        
        # if (merge_read_saving) {
        extract_data_tmp = list()
        if (any(sapply(extract_data, '[[', 'type') == "criteria")) {
            extract_data_tmp =
                append(extract_data_tmp,
                       list(list(name=name_criteria,
                                 type="criteria",
                                 variables=
                                     metaEX_criteria$variable_en)))
            names(extract_data_tmp)[length(extract_data_tmp)] =
                "criteria"
        }
        if (any(sapply(extract_data, '[[', 'type') == "serie")) {
            extract_data_tmp =
                append(extract_data_tmp,
                       list(list(name=name_serie,
                                 type="serie",
                                 variables=metaEX_serie$variable_en)))
            names(extract_data_tmp)[length(extract_data_tmp)] =
                "serie"
        }
        extract_data = extract_data_tmp
        # }

        
        # if (!is.null(names(codes_to_use)) & exists("meta")) {
        #     info = dplyr::tibble(code=codes_to_use,
        #                          info=names(codes_to_use))
        #     meta = dplyr::left_join(meta, info, by="code")
        # }


        if (type == "piezometrie" & exists("meta")) {
            meta = get_couche_in_meta(meta)
        }

    }
    
    
    ratio_lim = 2
    fact = 3
    
    if ('find_chain_out' %in% to_do) {
        if (any(grepl("serie", extract_data))) {
            if ("QA" %in% names(dataEX_serie)) {
                dataEX_tmp = dataEX_serie$QA
                dataEX_tmp =
                    dplyr::filter(dataEX_tmp,
                                  historical[1] <= date &
                                  date <= historical[2])
                dataEX_tmp_mean =
                    dplyr::summarise(
                               dplyr::group_by(dataEX_tmp,
                                               code, Chain),
                               meanQA=mean(QA, na.rm=TRUE),
                               GCM=GCM[1], EXP=EXP[1], RCM=RCM[1],
                               BC=BC[1], HM=HM[1])
                dataEX_tmp_med =
                    dplyr::summarise(dplyr::group_by(dataEX_tmp_mean,
                                                     code),
                                     medmeanQA=median(meanQA, na.rm=TRUE))
                dataEX_tmp_mean =
                    dplyr::full_join(dataEX_tmp_mean,
                                     dataEX_tmp_med,
                                     by="code")
                dataEX_tmp_mean$ratio =
                    dataEX_tmp_mean$meanQA / dataEX_tmp_mean$medmeanQA

                # dataEX_serieQA_ALL = dplyr::bind_rows(dataEX_serieQA_ALL,
                #                                       dataEX_tmp_mean)
                
                chain_to_remove_tmp =
                    dplyr::filter(dataEX_tmp_mean,
                                  ratio < 1/ratio_lim |
                                  ratio_lim < ratio)

                chain_to_remove_tmp =
                    dplyr::select(chain_to_remove_tmp,
                                  code, Chain,
                                  GCM, EXP, RCM,
                                  BC, HM)
                chain_to_remove_tmp$on = "serie" 
                chain_to_remove = dplyr::bind_rows(chain_to_remove,
                                                    chain_to_remove_tmp)
            } else {
                stop("You need to have QA variable in dataEX_serie")
            }
        }

        if (any(grepl("criteria", extract_data))) {
            if ("deltaQA_H3" %in% names(dataEX_criteria)) {
                dataEX_tmp = dataEX_criteria

                dataEX_tmp_stat =
                    dplyr::summarise(dplyr::group_by(dataEX_tmp,
                                                     code),
                                     medQA=median(deltaQA_H3, na.rm=TRUE),
                                     stdQA=sd(deltaQA_H3, na.rm=TRUE))
                dataEX_tmp =
                    dplyr::full_join(dataEX_tmp,
                                     dataEX_tmp_stat,
                                     by="code")
                # dataEX_criteriaQA_ALL =
                    # dplyr::bind_rows(dataEX_criteriaQA_ALL,
                                     # dataEX_tmp)
                chain_to_remove_tmp =
                    dplyr::filter(dataEX_tmp,
                                  deltaQA_H3 < medQA-fact*stdQA |
                                  medQA+fact*stdQA < deltaQA_H3)

                chain_to_remove_tmp =
                    dplyr::select(chain_to_remove_tmp,
                                  code, Chain,
                                  GCM, EXP, RCM,
                                  BC, HM)
                chain_to_remove_tmp$on = "criteria"
                chain_to_remove = dplyr::bind_rows(chain_to_remove,
                                                    chain_to_remove_tmp)
            } else {
                stop("You need to have deltaQA_H3 variable in dataEX_criteria")
            }
        }
    }


    if ('add_more_info_to_metadata' %in% to_do) {
        DirPaths = filter(Projections, EXP != "SAFRAN")$path
        nDirPath = length(DirPaths)
        
        meta_ALL = dplyr::tibble()
        for (j in 1:nDirPath) {
            if (nrow(meta_ALL) == 0) {
                meta_ALL = read_tibble(file.path(DirPaths[j],
                                                 "meta.fst"))
            } else {
                meta_ALL =
                    dplyr::full_join(
                               meta_ALL,
                               read_tibble(file.path(DirPaths[j],
                                                     "meta.fst")))
            }
        }
        meta_ALL = arrange(meta_ALL, code)
        meta_ALL = dplyr::rename(meta_ALL,
                                 "surface_MORDOR_SD_km2"=
                                     "surface_MORDOR-SD_km2",
                                 "surface_MORDOR_TS_km2"=
                                     "surface_MORDOR-TS_km2")

        HM_mod = gsub("[-]", "_", unique(Projections$HM))

        for (hm in HM_mod) {
            meta_ALL =
                dplyr::mutate(
                           meta_ALL,
                           !!paste0("n_", hm):=
                               as.numeric(!is.na(get(paste0("surface_",
                                                            hm, "_km2")))))
        }
        meta_ALL = mutate(meta_ALL,
                          n=rowSums(select(meta_ALL, starts_with("n_")),
                                    na.rm=TRUE))

        meta_ALL = dplyr::relocate(meta_ALL,
                                   n, .before=code)
        meta_ALL = left_join(meta_ALL,
                             select(codes_selection_data, code, n_input=n),
                             by="code")

        if (!all(meta_ALL$n == meta_ALL$n_input)) {
            stop("issue with n")
        }

        meta_ALL = select(meta_ALL, -n_input)
        meta_ALL$is_reference = as.logical(meta_ALL$reference)
        meta_ALL = dplyr::select(meta_ALL, -reference)
        meta_ALL =
            dplyr::left_join(meta_ALL,
                             dplyr::select(codes_selection_data,
                                           code_hydro2,
                                           code),
                             by="code")
        meta_ALL = dplyr::relocate(meta_ALL,
                                   is_reference,
                                   .after=code)
        meta_ALL = dplyr::relocate(meta_ALL,
                                   code_hydro2,
                                   .after=code)
        
        meta_ALL_sf =
            sf::st_as_sf(meta_ALL,
                         coords=c("XL93_m", "YL93_m"))
        sf::st_crs(meta_ALL_sf) = sf::st_crs(2154)
        meta_ALL_sf = sf::st_transform(meta_ALL_sf, 4326)    
        get_lon = function (id) {
            meta_ALL_sf$geometry[[id]][1]
        }
        get_lat = function (id) {
            meta_ALL_sf$geometry[[id]][2]
        }
        meta_ALL$lon_deg = sapply(1:nrow(meta_ALL_sf), get_lon)
        meta_ALL$lat_deg = sapply(1:nrow(meta_ALL_sf), get_lat)
        meta_ALL = dplyr::relocate(meta_ALL,
                                   lon_deg,
                                   .after=YL93_m)
        meta_ALL = dplyr::relocate(meta_ALL,
                                   lat_deg,
                                   .after=lon_deg)

        chain_to_remove = read_tibble(filedir=file.path(resdir,
                                                        mode,
                                                        type),
                                      filename="chain_to_remove.csv")


        N_max = summarise(group_by(filter(Projections, EXP!="SAFRAN"),
                                   HM, EXP), N_max=n())        
        N_chain_to_remove =
            summarise(group_by(filter(chain_to_remove, EXP!="SAFRAN"),
                               code, HM, EXP), N=n())
        N_chain_to_remove = full_join(N_chain_to_remove,
                                      N_max, by=c("HM", "EXP"))
        N_chain_to_remove = filter(N_chain_to_remove,
                                   N > N_max/2)
        N_chain_to_remove = select(N_chain_to_remove, code, HM, EXP)
        HM_EXP_code_to_remove = N_chain_to_remove
        N_chain_to_remove$n = -1
        N_chain_to_remove = arrange(N_chain_to_remove, HM)
        N_chain_to_remove$HM = gsub("[-]", "_",
                                    N_chain_to_remove$HM)
        
        N_chain_to_remove =
            tidyr::pivot_wider(N_chain_to_remove,
                               names_from=c(HM, EXP),
                               values_from=n,
                               names_glue=
                                   "n_{gsub('.*[-]', '', EXP)}_{HM}",
                               values_fill=0)
        N_chain_to_remove = arrange(N_chain_to_remove, code)

        EXP_short = c("rcp26", "rcp45", "rcp85")
        n_HM = paste0("n_", EXP_short, "_",
                      gsub("[-]", "_", N_max$HM))
        for (n_hm in n_HM) {
            if (!(n_hm %in% names(N_chain_to_remove))) {
                N_chain_to_remove[[n_hm]] = 0
            }
        }
        
        meta_ALL = full_join(meta_ALL,
                             N_chain_to_remove,
                             by="code")

        meta_ALL = mutate(meta_ALL,
                          across(starts_with("n_"),
                                 ~ifelse(is.na(.), 0, .)))

        for (exp in EXP_short) {
            for (hm in HM_mod) {
                meta_ALL =
                    dplyr::mutate(
                               meta_ALL,
                               !!paste0("n_", exp, "_", hm):=
                                   get(paste0("n_", hm)) +
                                   get(paste0("n_", exp, "_", hm)))
            }
            meta_ALL = mutate(meta_ALL,
                              !!paste0("n_", exp):=
                                  rowSums(
                                      select(meta_ALL,
                                             starts_with(paste0("n_", exp))),
                                      na.rm=TRUE))
            meta_ALL = dplyr::relocate(meta_ALL,
                                       paste0("n_", exp),
                                       .before=code)
        }
        
        HM_EXP_code_to_remove =
            inner_join(select(Projections, GCM, RCM,
                              EXP, BC, HM, Chain),
                       HM_EXP_code_to_remove,
                       by=c("HM", "EXP"),
                       relationship="many-to-many")
        HM_EXP_code_to_remove$on = "too much chain already out"
        
        chain_to_remove = bind_rows(chain_to_remove,
                                    HM_EXP_code_to_remove)
        chain_to_remove$code_Chain = paste0(chain_to_remove$code, "_", 
                                            chain_to_remove$Chain)
        chain_to_remove = filter(chain_to_remove, !duplicated(code_Chain))
        
        write_tibble(chain_to_remove,
                     filedir=today_resdir,
                     filename="chain_to_remove_adjust.csv")
        write_tibble(meta_ALL,
                     filedir=today_resdir,
                     filename="stations_selection.csv")
    }
    

    
    if ('reshape_extracted_data_for_figure' %in% to_do) {

        if (any(grepl("serie", extract_data))) {
            for (k in 1:length(dataEX_serie)) {
                dataEX_serie[[k]]$code_Chain =
                    paste0(dataEX_serie[[k]]$code, "_",
                           dataEX_serie[[k]]$Chain)
                dataEX_serie[[k]] = filter(dataEX_serie[[k]],
                                           !(code_Chain %in%
                                             chain_to_remove$code_Chain))
                dataEX_serie[[k]] = select(dataEX_serie[[k]], -code_Chain)
            }
            
            write_tibble(dataEX_serie,
                         file.path(resdir,
                                   paste0(mode, "_for_figure"),
                                   type),
                         paste0("dataEX_serie_",
                                subset_name, ".fst"))
            write_tibble(metaEX_serie,
                         file.path(resdir,
                                   paste0(mode, "_for_figure"),
                                   type), "metaEX_serie.fst")

            meta_tmp = filter(codes_selection_data, code %in% meta$code)
            write_tibble(meta_tmp,
                         file.path(resdir,
                                   paste0(mode, "_for_figure"),
                                   type),
                         paste0("meta_", subset_name, ".fst"))

            Paths_QUALYPSO = file.path(computer_data_path, type,
                                       QUALYPSO_dir,
                                       paste0(meta_tmp$code, ".rds"))

            convert = c("Augmentation"=1,
                        "Pas de tendance"=0,
                        "Diminution"=-1)

            data_QUALYPSO = tibble()

            for (path in Paths_QUALYPSO) {
                code = gsub("[.].*", "", basename(path))
                tmp = read_tibble(path)
                tmp = tmp[c(1, 2, 4)]
                for (k in 1:length(tmp)) {
                    names(tmp[[k]]) = c("spread", "signe")
                    spread_name = c("inside", "outside")
                    names(tmp[[k]]$spread) = spread_name

                    post("full")
                    print(tmp[[k]])
                    
                    for (x in spread_name) {

                        post("spread")
                        print(tmp[[k]]$spread[[x]])
                        
                        tmp[[k]]$spread[[x]] = 
                            tibble(tmp[[k]]$spread[[x]]) %>%
                            filter(rcp=="rcp85") %>%
                            select(-rcp) %>%
                            rename(date=year) %>%
                            mutate(code=code,
                                   date=as.Date(paste0(date,
                                                       "-01-01"))) %>%
                            relocate(code, .before=date)
                        names(tmp[[k]]$spread[[x]]) =
                            gsub("chg[_]", "",
                                 names(tmp[[k]]$spread[[x]]))

                    }

                    post("signe")
                    print(tmp[[k]]$signe)

                    tmp[[k]]$signe = 
                        tmp[[k]]$signe %>%
                        filter(rcp=="rcp85") %>%
                        rename(date=year) %>%
                        mutate(code=code,
                               date=as.Date(paste0(date, "-01-01")),
                               signe=convert[match(cat,
                                                   names(convert))]) %>%
                        select(-rcp, -val, -cat) %>%
                        relocate(code, .before=date)
                }

                if (length(data_QUALYPSO) == 0) {
                    data_QUALYPSO = tmp
                } else {
                    for (k in 1:length(tmp)) {
                        data_QUALYPSO[[k]]$spread$inside =
                            bind_rows(data_QUALYPSO[[k]]$spread$inside,
                                      tmp[[k]]$spread$inside)
                        data_QUALYPSO[[k]]$spread$outside =
                            bind_rows(data_QUALYPSO[[k]]$spread$outside,
                                      tmp[[k]]$spread$outside)
                        data_QUALYPSO[[k]]$signe =
                            bind_rows(data_QUALYPSO[[k]]$signe,
                                      tmp[[k]]$signe)
                    }
                }
            }

            write_tibble(data_QUALYPSO,
                         file.path(resdir,
                                   paste0(mode, "_for_figure"),
                                   type),
                         paste0("data_QUALYPSO_",
                                subset_name, ".fst"))
        }

        if (any(grepl("criteria", extract_data))) {
            dataEX_criteria$code_Chain =
                paste0(dataEX_criteria$code, "_",
                       dataEX_criteria$Chain)
            dataEX_criteria = filter(dataEX_criteria,
                                     !(code_Chain %in% chain_to_remove$code_Chain))
            dataEX_criteria = select(dataEX_criteria, -code_Chain)

            write_tibble(dataEX_criteria,
                         file.path(resdir,
                                   paste0(mode, "_for_figure"),
                                   type),
                         paste0("dataEX_criteria_",
                                subset_name, ".fst"))
            write_tibble(metaEX_criteria,
                         file.path(resdir,
                                   paste0(mode, "_for_figure"),
                                   type), "metaEX_criteria.fst")
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

                Code = levels(factor(dataEX$code))
                nCode = length(Code)

                dataEXserieQM_obs =
                    dplyr::summarise(dplyr::group_by(dataEX$QM,
                                                     code, date),
                                     QM=median(QM_obs,
                                               na.rm=TRUE),
                                     .groups="drop")

                dataEXserieR_ratio =
                    dplyr::full_join(dataEX$Rl_ratio,
                                     dataEX$Rs_ratio,
                                     by=c("code", "HM"))
                dataEXserieR_ratio =
                    dplyr::summarise(
                               dplyr::group_by(dataEXserieR_ratio,
                                               code),
                               Rs_ratio=median(Rs_ratio_obs,
                                               na.rm=TRUE),
                               Rl_ratio=median(Rl_ratio_obs,
                                               na.rm=TRUE),
                               .groups="drop")

                regimeHydro = find_regimeHydro(dataEXserieQM_obs,
                                               lim_number=NULL,
                                               dataEXserieR_ratio)

                ok = names(regimeHydro) != "code"
                names(regimeHydro)[ok] =
                    paste0("Regime_hydro_", names(regimeHydro)[ok])
                
                meta = dplyr::full_join(meta, regimeHydro, "code")
                
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
                                          paste0(variable2search,
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
                Sys.sleep(10+rank) 
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
                ver = stringr::str_extract(proj_file,
                                           "[_]v[[:digit:]]+[_]")
                ver = as.numeric(gsub("([_])|(v)", "" , ver))
                proj_clean_file = gsub("[_]v[[:digit:]]+[_]",
                                       paste0("_v", ver+1, "_"),
                                       proj_file)
                
                proj_clean_path = file.path(proj_clean_dirpath,
                                            proj_clean_file)
                
                post(paste0("#### Cleaning ", proj_file))

                code_rm_data_path = file.path(computer_data_path,
                                              type,
                                              code_correction_dir,
                                              paste0(proj$HM,
                                                     "_rm.csv"))
                code_mv_data_path = file.path(computer_data_path,
                                              type,
                                              code_correction_dir,
                                              paste0(proj$HM,
                                                     "_mv.csv"))
                code_o_data_path = file.path(computer_data_path,
                                             type,
                                             code_correction_dir,
                                             paste0(proj$HM,
                                                    "_o.csv"))
                
                if (file.exists(code_rm_data_path) &
                    file.exists(code_mv_data_path)) {

                    system(paste0("cp ", proj_path, " ",
                                  proj_clean_path))
                    NC = ncdf4::nc_open(proj_clean_path,
                                        write=TRUE)

                    if (!("code_new" %in% names(NC$var))) {
                        dim = ncdf4::ncdim_def("code_strlen_new",
                                               "", 1:10,
                                               create_dimvar=FALSE,
                                               longname=NULL)
                        variable = ncdf4::ncvar_def("code_new", "",
                                                    list(dim,
                                                         NC$dim$station),
                                                    longname="code of stations",
                                                    prec="char")
                        NC = ncdf4::ncvar_add(NC, variable)
                        ncdf4::nc_close(NC)
                        NC = ncdf4::nc_open(proj_clean_path,
                                            write=TRUE)
                    }

                    ncdf4::ncvar_put(NC, "code_new",
                                     substr(ncdf4::ncvar_get(NC,
                                                             "code"),
                                            1, 10))
                    Code = ncdf4::ncvar_get(NC, "code")

                    if (file.exists(code_o_data_path)) {
                        code_o_data = read_tibble(code_o_data_path)
                        code_o = code_o_data$NouveauNom
                        code_o[is.na(code_o)] = Code[is.na(code_o)]
                        ncdf4::ncvar_put(NC, "code", code_o)
                        ncdf4::ncvar_put(NC, "code_new", code_o)
                        Code = ncdf4::ncvar_get(NC, "code_new")
                    }
                    
                    nCode = length(Code)
                    XL93 = ncdf4::ncvar_get(NC, "L93_X")
                    YL93 = ncdf4::ncvar_get(NC, "L93_Y")

                    code_rm_data = read_tibble(code_rm_data_path)
                    code_mv_data = read_tibble(code_mv_data_path)

                    if (nrow(code_mv_data) > 0 |
                        nrow(code_rm_data) > 0) {
                        if (!ncdf4::ncatt_get(NC, 0,
                                              "history")$hasatt) {
                            ncdf4::ncatt_put(NC, 0, "history", "")
                        }
                    }
                    
                    if (nrow(code_mv_data) > 0) {
                        Code_mv_input = code_mv_data$AncienNom
                        XL93_mv = code_mv_data$AncienX
                        YL93_mv = code_mv_data$AncienY
                        Code_mv_output = code_mv_data$NouveauNom

                        Id_mv = c()
                        for (j in 1:length(Code_mv_input)) {
                            if (!is.na(XL93_mv[j]) &
                                !is.na(YL93_mv[j])) {
                                id_mv = which(Code_mv_input[j] == Code)
                                id_mv =
                                    id_mv[which.min(abs(XL93_mv[j]-
                                                        XL93[id_mv]) + 
                                                    abs(YL93_mv[j]-
                                                        YL93[id_mv]))]
                            } else {
                                id_mv = which(Code_mv_input[j] == Code)
                            }
                            if (identical(id_mv, integer(0))) {
                                id_mv = NA
                            }
                            if (is.na(id_mv)) {
                                post(paste0("### mv WARNING ",
                                            Code_mv_input[j],
                                            " not identified for ",
                                            proj_file))
                            } else {
                                post(paste0("### mv ",
                                            Code_mv_input[j],
                                            " in ", id_mv))
                            }
                            Id_mv = c(Id_mv, id_mv)
                        }

                        post(paste0("to move ",
                                    paste0(Id_mv, collapse=" ")))
                        
                        Code[Id_mv[!is.na(Id_mv)]] =
                            Code_mv_output[!is.na(Id_mv)]
                        ncdf4::ncvar_put(NC, "code", Code)
                        ncdf4::ncvar_put(NC, "code_new", Code)
                        history = ncdf4::ncatt_get(NC, 0,
                                                   "history")$value
                        if (nchar(history) > 0) {
                            history = paste0(history, "\n")
                        }
                        history = paste0(
                            history,
                            Sys.time(), " -> ",
                            "Some stations have changed their code to ensure their correct identification in the Explore2 selection.")
                        ncdf4::ncatt_put(NC, 0, "history", history)
                    }
                    
                    if (nrow(code_rm_data) > 0) {
                        Code_rm = code_rm_data$AncienNom
                        XL93_rm = code_rm_data$AncienX
                        YL93_rm = code_rm_data$AncienY

                        Id_rm = c()
                        for (j in 1:length(Code_rm)) {
                            if (!is.na(XL93_rm[j]) &
                                !is.na(YL93_rm[j])) {
                                id_rm = which(Code_rm[j] == Code)
                                id_rm =
                                    id_rm[which.min(abs(XL93_rm[j]-
                                                        XL93[id_rm]) + 
                                                    abs(YL93_rm[j]-
                                                        YL93[id_rm]))[1]]


                            } else {
                                id_rm = which(Code_rm[j] == Code)[1]
                            }
                            if (identical(id_rm, integer(0))) {
                                id_rm = NA
                            }
                            if (is.na(id_rm)) {
                                post(paste0("### rm WARNING ",
                                            Code_rm[j],
                                            " not identified for ",
                                            proj_file))
                            } else {
                                post(paste0("### rm ",
                                            Code_rm[j],
                                            " in ", id_rm))
                            }
                            Id_rm = c(Id_rm, max(id_rm))
                        }

                        Id_rm = Id_rm[!is.na(Id_rm)]
                        post(paste0("to remove ",
                                    paste0(Id_rm, collapse=" ")))

                        # stop()

                        nDate = length(ncdf4::ncvar_get(NC, "time"))
                        Variable = c("topologicalSurface",
                                     "topologicalSurface_model",
                                     "WGS84_lon", "WGS84_lat",
                                     "WGS84_lon_model", "WGS84_lat_model",
                                     "LII_Y", "LII_X",
                                     "LII_Y_model", "LII_X_model",
                                     "L93_Y", "L93_X",
                                     "L93_Y_model", "L93_X_model")
                        Variable_chr = c("name",  "network_origin",
                                         "code_type", "code",
                                         "code_new")

                        for (variable in Variable) {
                            if (!(variable %in% names(NC$var))) {
                                next
                            }
                            value = ncdf4::ncvar_get(NC, variable)
                            value[Id_rm] = NaN
                            ncdf4::ncvar_put(NC, variable, value)
                            ncdf4::ncvar_change_missval(NC,
                                                        variable,
                                                        NaN)
                        }

                        for (variable in Variable_chr) {
                            if (!(variable %in% names(NC$var)) &
                                variable != "code_new") {
                                next
                            }
                            value = ncdf4::ncvar_get(NC, variable)
                            if (is.matrix(value)) {
                                next
                            }
                            n = max(nchar(value, allowNA=TRUE),
                                    na.rm=TRUE)
                            value[Id_rm] = strrep("-", n)
                            ncdf4::ncvar_put(NC, variable, value)
                            ncdf4::ncvar_change_missval(NC,
                                                        variable,
                                                        strrep("-", n))
                        }
                        
                        for (id_rm in Id_rm) {
                            ncdf4::ncvar_put(NC, "debit",
                                             start=c(id_rm, 1),
                                             count=c(1, -1),
                                             rep(NaN, nDate))
                        }

                        history = ncdf4::ncatt_get(NC, 0,
                                                   "history")$value
                        if (nchar(history) > 0) {
                            history = paste0(history, "\n")
                        }
                        history = paste0(
                            history,
                            Sys.time(), " -> ",
                            "Some stations have been set aside either because they are no longer part of the Explore2 selection or their code does not guarantee their identification with certainty in the Explore2 selection. Refer to the 'missing_value' attribute of each variable to learn how to identify them.")
                        ncdf4::ncatt_put(NC, 0, "history", history)
                    }

                    ncdf4::nc_close(NC)

                    proj_clean_path_tmp = gsub("[.]nc", "_tmp.nc",
                                               proj_clean_path)
                    
                    ncoCmd = paste0("ncks -h -O -x -C -v", " ",
                                    "code", " ",
                                    proj_clean_path, " ",
                                    proj_clean_path_tmp)
                    system(ncoCmd)
                    system(paste0("rm -f ", proj_clean_path))
                    system(paste0("mv ", proj_clean_path_tmp, " ",
                                  proj_clean_path))
                    
                    ncoCmd = paste0("ncrename -h -O -d", " ",
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


        OK_SAFRAN = Projections$climateChain == "SAFRAN"
        if (any(OK_SAFRAN)) {
            file.copy(Projections$path[OK_SAFRAN],
                      file.path(proj_merge_dirpath,
                                Projections$file[OK_SAFRAN]))
            Sys.sleep(10)
            Projections = Projections[!OK_SAFRAN,]   
        }
        
        Historicals =
            Projections[Projections$EXP ==
                        "historical" &
                        Projections$HM %in%
                        HM_to_use,]
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

                post(historical_path)
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
                                Projections$HM ==
                                historical$HM,]
                
                # jehfezoifjezoifjezoifjezoiji EROS
                projs = projs[substr(projs$file, "1", "15") ==
                              substr(historical$file, "1", "15"),]
                
                for (j in 1:nrow(projs)) {
                    proj = projs[j,]
                    proj_path = proj$path
                    proj_file = proj$file
                    proj_merge_file =
                        gsub("[_]rcp", "_historical-rcp", proj_file)
                    ver = stringr::str_extract(proj_merge_file,
                                               "[_]v[[:digit:]]+[_]")
                    ver = as.numeric(gsub("([_])|(v)", "" , ver))
                    proj_merge_file = gsub("[_]v[[:digit:]]+[_]",
                                           paste0("_v", ver+1, "_"),
                                           proj_merge_file)
                    
                    proj_merge_path =
                        file.path(proj_merge_dirpath,
                                  proj_merge_file)

                    post(proj_path)
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

                    post(proj_merge_path)
                    NC = ncdf4::nc_open(proj_merge_path,
                                        write=TRUE)
                    if (!ncdf4::ncatt_get(NC, 0,
                                          "history")$hasatt) {
                        ncdf4::ncatt_put(NC, 0, "history", "")
                    }
                    history = ncdf4::ncatt_get(NC, 0,
                                               "history")$value
                    if (nchar(history) > 0) {
                        history = paste0(history, "\n")
                    }
                    history = paste0(
                        history,
                        Sys.time(), " -> ",
                        "The scenario part of the projection chain has been concatenated with the associated historical part.")
                    ncdf4::ncatt_put(NC, 0, "history", history)
                    ncdf4::nc_close(NC)
                }
            }
        }
        
        if (nrow(flag) > 0) {            
            flag = tidyr::separate(flag, col="Chain",
                                   into=c("GCM", "EXP", "RCM",
                                          "BC", "HM"), sep="[|]")
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
