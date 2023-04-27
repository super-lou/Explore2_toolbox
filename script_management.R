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

    if (exists("meta")) {
        rm (meta)
    }
    for (i in 1:nSubsets_save) {
        subset_name = names(Subsets_save)[i]
        if (by_files | MPI == "file") {
            subset_name = paste0(files_name_opt,
                                 "_", subset_name)
        }
        filename = paste0("meta_", subset_name, ".fst")
        if (file.exists(file.path(tmppath, filename))) {
            meta_tmp = read_tibble(filedir=tmppath,
                                   filename=filename)
            if (!exists("meta")) {
                meta = meta_tmp
            } else {
                meta = dplyr::bind_rows(meta, meta_tmp)
            }
        }
        gc()
    }
    
    if (exists("meta_tmp")) {
        rm (meta_tmp)
    }
    meta = meta[order(meta$Code),]
    
    write_tibble(meta,
                 filedir=tmppath,
                 filename="meta.fst")

    for (i in 1:length(analyse_data)) {
        
        CARD_dir = analyse_data[[i]][1]
        simplify = as.logical(analyse_data[[i]]["simplify"])
        CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)
        
        if (exists("metaEX")) {
            rm ("metaEX")
        }
        if (exists("dataEX")) {
            rm ("dataEX")
        }
        for (j in 1:nSubsets_save) {
            subset_name = names(Subsets_save)[j]

            if (!exists("metaEX")) {
                filename = paste0("metaEX_", CARD_var, "_",
                                  files_name_opt.,
                                  subset_name, ".fst")
                if (file.exists(file.path(tmppath, filename))) {
                    metaEX = read_tibble(filedir=tmppath,
                                         filename=filename)
                    gc()
                }
            }
            
            dirname = paste0("dataEX_", CARD_var, "_",
                             files_name_opt.,
                             subset_name)
            filename = paste0(dirname, ".fst")
            if (file.exists(file.path(tmppath, dirname)) |
                file.exists(file.path(tmppath, filename))) {
                dataEX_tmp = read_tibble(filedir=tmppath,
                                         filename=filename)
                gc()

                if (!exists("dataEX")) {
                    dataEX = dataEX_tmp
                } else {
                    if (simplify) {
                        dataEX = dplyr::bind_rows(dataEX,
                                                  dataEX_tmp)
                    } else {
                        for (k in 1:length(dataEX)) {
                            dataEX[[k]] =
                                dplyr::bind_rows(dataEX[[k]],
                                                 dataEX_tmp[[k]])
                            gc()
                        }  
                    }
                }
            }
        }
        
        if (exists("dataEX_tmp")) {
            rm ("dataEX_tmp")

            if (simplify) {
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
                        
                        if (grepl("^HYP.*", varREL)) {
                            dataEX[[varREL]] =
                                dataEX[[paste0(varREL,
                                               "_sim")]] &
                                dataEX[[paste0(varREL,
                                               "_obs")]]

                        } else if (grepl("(^t)|([{]t)",
                                         varREL)) {
                            dataEX[[varREL]] =
                                circular_minus(
                                    dataEX[[paste0(varREL,
                                                   "_sim")]],
                                    dataEX[[paste0(varREL,
                                                   "_obs")]],
                                    period=365.25)/30.4375

                        } else if (grepl("(Rc)|(^epsilon)|(^alpha)",
                                         varREL)) {
                            dataEX[[varREL]] =
                                dataEX[[paste0(varREL, "_sim")]] /
                                dataEX[[paste0(varREL, "_obs")]]
                            
                        } else {
                            dataEX[[varREL]] =
                                (dataEX[[paste0(varREL,
                                                "_sim")]] -
                                 dataEX[[paste0(varREL,
                                                "_obs")]]) /
                                dataEX[[paste0(varREL,
                                               "_obs")]]
                        }
                        dataEX =
                            dplyr::relocate(dataEX,
                                            !!varREL,
                                            .after=!!paste0(varREL,
                                                            "_sim"))
                    }
                }
                
            } else {
                for (j in 1:length(dataEX)) {
                    dataEX[[j]] =
                        dataEX[[j]][order(dataEX[[j]]$Model),]
                    gc()
                }
            }
        }

        write_tibble(dataEX,
                     filedir=tmppath,
                     filename=paste0("dataEX_", CARD_var,
                                     .files_name_opt,
                                     ".fst"))
        write_tibble(metaEX,
                     filedir=tmppath,
                     filename=paste0("metaEX_", CARD_var,
                                     .files_name_opt,
                                     ".fst"))
        if (!is.null(wait)) {
            post("Waiting for writting of extracted data")
            Sys.sleep(wait)
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
    
    if ("meta" %in% var2save) {
        meta = read_tibble(filedir=tmppath,
                           filename="meta.fst")
        
        write_tibble(meta,
                     filedir=today_resdir_tmp,
                     filename=paste0("meta.fst"))
        if ("Rdata" %in% saving_format) {
            write_tibble(meta,
                         filedir=today_resdir_tmp,
                         filename=paste0("meta.Rdata"))
        }
        if ("txt" %in% saving_format) {
            write_tibble(meta,
                         filedir=today_resdir_tmp,
                         filename=paste0("meta.txt"))
        }
        if (!is.null(wait)) {
            post("Waiting for saving of meta data")
            Sys.sleep(wait)
        }
    }

    for (i in 1:length(analyse_data)) {
        
        CARD_dir = analyse_data[[i]][1]
        simplify = as.logical(analyse_data[[i]]["simplify"])
        CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)
        
        dirname = paste0("dataEX_", CARD_var,
                         .files_name_opt)
        filename = paste0(dirname, ".fst")
        if (file.exists(file.path(tmppath, dirname)) |
            file.exists(file.path(tmppath, filename))) {

            if ("metaEX" %in% var2save) {
                metaEX = read_tibble(filedir=tmppath,
                                     filename=paste0(
                                         "metaEX_",
                                         CARD_var,
                                         .files_name_opt,
                                         ".fst"))
                gc()
            }
            if ("dataEX" %in% var2save) {
                dataEX = read_tibble(filedir=tmppath,
                                     filename=paste0(
                                         "dataEX_",
                                         CARD_var,
                                         .files_name_opt,
                                         ".fst"))
                gc()
            }
        } else {
            next
        }

        if ("dataEX" %in% var2save) {
            write_tibble(dataEX,
                         filedir=today_resdir_tmp,
                         filename=paste0("dataEX_",
                                         CARD_var,
                                         ".fst"))
            if ("Rdata" %in% saving_format) {
                write_tibble(dataEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("dataEX_",
                                             CARD_var,
                                             ".Rdata"))
            }
            if ("txt" %in% saving_format) {
                write_tibble(dataEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("dataEX_",
                                             CARD_var,
                                             ".txt"))
            }
            if (!is.null(wait)) {
                post("Waiting for saving of extracted data")
                Sys.sleep(wait)
            }
        }
        
        if ("metaEX" %in% var2save) {
            write_tibble(metaEX,
                         filedir=today_resdir_tmp,
                         filename=paste0("metaEX_",
                                         CARD_var,
                                         ".fst"))
            if ("Rdata" %in% saving_format) {
                write_tibble(metaEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("metaEX_",
                                             CARD_var,
                                             ".Rdata"))
            }
            if ("txt" %in% saving_format) {
                write_tibble(metaEX,
                             filedir=today_resdir_tmp,
                             filename=paste0("metaEX_",
                                             CARD_var,
                                             ".txt"))
            }
            if (!is.null(wait)) {
                post("Waiting for saving of extracted meta data")
                Sys.sleep(wait)
            }
        }
    }
}



## 1. MANAGEMENT OF DATA ______________________________________________
if (!read_tmp & !merge_nc & !delete_tmp) {

    if (MPI == "code" & rank == 0 | MPI != "code") {
        if (MPI == "code" & rank == 0) {
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
        }
        
        if ('analyse_data' %in% to_do) {
            manage_data()
        }
        
        if ('save_analyse' %in% to_do) {
            post("### Saving analyses")
            post(paste0("Save extracted data and metadata in ",
                         paste0(saving_format, collapse=", ")))
            save_data()
        }

    } else if (MPI == "code") {
        Rmpi::mpi.send(as.integer(1), type=1, dest=0, tag=1, comm=0)
        post(paste0("End signal from rank ", rank)) 
    }

    if ('read_saving' %in% to_do) {
        post("### Reading saving")
        post(paste0("Reading extracted data and metadata in ",
                    read_saving))

        for (i in 1:length(analyse_data)) {
            CARD_dir = analyse_data[[i]][1]
            simplify = as.logical(analyse_data[[i]]["simplify"])
            CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)
            
            Paths = list.files(file.path(resdir, read_saving),
                               include.dirs=TRUE,
                               full.names=TRUE)

            pattern = var2search
            pattern[!grepl("dataEX", pattern)] =
                paste0(pattern[!grepl("dataEX", pattern)], "[.]")
            pattern = paste0("(", paste0(pattern,
                                         collapse=")|("), ")")
            pattern = gsub("EX", paste0("EX_", CARD_var), pattern)
            pattern = gsub("[_]", "[_]", pattern)
            Paths = Paths[grepl(pattern, Paths)]
            
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
        }

    }

    if ('criteria_selection' %in% to_do) {
        post("### Selecting variables")
        for (i in 1:length(analyse_data)) {
            
            CARD_dir = analyse_data[[i]][1]
            simplify = as.logical(analyse_data[[i]]["simplify"])
            CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)

            if (simplify) {
                dataEXname = paste0("dataEX_", CARD_var)
                metaEXname = paste0("metaEX_", CARD_var)
                dataEXtmp = get(dataEXname)
                metaEXtmp = get(metaEXname)
                dataEXtmp =
                    dataEXtmp[!grepl("(^HYP)|([_]obs$)|([_]sim$)",
                                     names(dataEXtmp))]
                metaEXtmp =
                    metaEXtmp[!grepl("(^HYP)|([_]obs$)|([_]sim$)",
                                     metaEXtmp$var),]
                assign(dataEXname, dataEXtmp)
                assign(metaEXname, metaEXtmp)
            }   
        }
    }

    if ('write_warnings' %in% to_do) {
        post("### Writing warnings")
        for (i in 1:length(analyse_data)) {
            
            CARD_dir = analyse_data[[i]][1]
            simplify = as.logical(analyse_data[[i]]["simplify"])
            CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)

            if (simplify) {
                dataEX = get(paste0("dataEX_", CARD_var))
                metaEX = get(paste0("metaEX_", CARD_var))
                Warnings = find_Warnings(dataEX, metaEX,
                                         resdir=today_resdir, save=TRUE)
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
        Paths[!grepl("[.]", Paths)] = paste0(Paths[!grepl("[.]", Paths)], ".fst")
        Filenames = gsub("^.*[/]+", "", Paths)
        Filenames = gsub("[.].*$", "", Filenames)
        nFile = length(Filenames)
        for (i in 1:nFile) {
            post(paste0(Filenames[i], " reads in ", Paths[i]))
            assign(Filenames[i], read_tibble(filepath=Paths[i]))
        }
        read_tmp = FALSE
    }

    
    if (merge_nc) {
        post("### Merging NetCDF file by time for projection")
        proj_merge_dir = paste0(proj_dir, "_merge")
        proj_merge_dirpath = file.path(computer_data_path,
                                       proj_merge_dir)
        if (!dir.exists(proj_merge_dirpath)) {
            if (rank == 0) {
                dir.create(proj_merge_dirpath)
            } else {
                Sys.sleep(10)  
            }
        }

        Historicals =
            projs_selection_data[projs_selection_data$EXP ==
                                 "historical",]
        nHistoricals = nrow(Historicals)

        if (MPI == "file") {
            start = ceiling(seq(1, nHistoricals,
                                by=(nHistoricals/size)))
            end = ceiling(seq((nHistoricals/size), nHistoricals,
                              by=(nHistoricals/size)))
            Historicals = Historicals[start[rank+1]:end[rank+1],]
        } 
        
        nHistoricals = nrow(Historicals)
        flag = dplyr::tibble()
        
        for (i in 1:nHistoricals) {
            historical = Historicals[i,]
            historical_path = historical$path
            NC_historical = ncdf4::nc_open(historical_path)
            Date = NetCDF_extrat_time(NC_historical)
            ncdf4::nc_close(NC_historical)
            minDate_historical = min(Date)
            maxDate_historical = max(Date)

            projs =
                projs_selection_data[projs_selection_data$GCM ==
                                     historical$GCM &
                                     projs_selection_data$RCM ==
                                     historical$RCM &
                                     projs_selection_data$EXP !=
                                     "historical" &
                                     projs_selection_data$BC ==
                                     historical$BC &
                                     projs_selection_data$Model ==
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

                cdoCmd = paste0(cdo_cmd_path,
                                " --history -O mergetime ",
                                historical_path, " ",
                                proj_path, " ", 
                                proj_merge_path)
                system(cdoCmd)

                NC_proj = ncdf4::nc_open(proj_path)
                Date = NetCDF_extrat_time(NC_proj)
                minDate_proj = min(Date)
                maxDate_proj = max(Date)
                
                NC_proj_merge = ncdf4::nc_open(proj_merge_path,
                                               write=TRUE)
                code_value = ncdf4::ncvar_get(NC_proj, "code")
                station_dim = NC_proj_merge$dim[['station']]
                nchar_dim = ncdf4::ncdim_def("code_strlen",
                                             "",
                                             1:max(nchar(code_value)))
                code_var = ncdf4::ncvar_def(name="code",
                                            units="",
                                            dim=list(nchar_dim,
                                                     station_dim),
                                            prec="char")
                NC_proj_merge = ncdf4::ncvar_add(NC_proj_merge,
                                                 code_var)
                ncdf4::ncvar_put(NC_proj_merge,
                                 "code", code_value)
                ncdf4::nc_close(NC_proj)
                ncdf4::nc_close(NC_proj_merge)

                flag = dplyr::bind_rows(
                                  flag,
                                  dplyr::tibble(ID=proj$ID,
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
        if (nrow(flag) > 0) {
            flag = tidyr::separate(flag, col="ID",
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
                flag_tmp = read_tibble(file.path(tmppath,
                                                 paste0("flag_",
                                                        rank , ".fst")))
                flag = dplyr::bind_rows(flag, flag_tmp)
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
