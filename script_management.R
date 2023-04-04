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
if (!read_tmp & !delete_tmp) {

    if (MPI == "code" & rank == 0 | MPI != "code") {
        if (MPI == "code" & rank == 0) {
            Root = rep(0, times=size)
            Root[1] = 1
            post(paste0("Waiting other : ",
                        paste0(gsub("1", "-", 
                                    gsub("0", "_",
                                         Root)), collapse="")))
            for (root in 1:(size-1)) {
                Root[root+1] = mpi.recv(0, type=2, source=root,
                                        tag=1, comm=0)
                post(paste0("End signal received from rank ", root))
                post("Waiting other : ")
                post(paste0(gsub("1", "-", 
                                 gsub("0", "_",
                                      Root)), collapse=""))
            }
        }
        
        if ('analyse_data' %in% to_do) {
            if (exists("meta")) {
                rm (meta)
            }
            for (i in 1:nSubsets) {
                subset_name = names(Subsets)[i]
                if (by_files | MPI == "file") {
                    subset_name = paste0(files_name_opt,
                                         "_", subset_name)
                }
                filename = paste0("meta_", subset_name, ".fst")

                file_test = file.path(tmppath, filename)
                if (!file.exists(file_test)) {
                    post(paste0("Waiting for ", file_test))
                    start_time = Sys.time()
                    while (!file.exists(file_test) |
                           Sys.time()-start_time < 60) {
                        Sys.sleep(1)
                    }
                    if (Sys.time()-start_time > 60) {
                        post(paste0("Problem with file reading for ",
                                    file_test))
                    }
                }
                
                if (file.exists(file_test)) {
                    meta_tmp = read_tibble(filedir=tmppath,
                                           filename=filename)
                    if (!exists("meta")) {
                        meta = meta_tmp
                    } else {
                        meta = dplyr::bind_rows(meta, meta_tmp)
                    }
                }
            }
            
            if (exists("meta_tmp")) {
                rm (meta_tmp)
                meta = meta[order(meta$Code),]
            }

            for (ii in 1:length(analyse_data)) {
                
                CARD_dir = analyse_data[[ii]][1]
                simplify = as.logical(analyse_data[[ii]]["simplify"])
                CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)

                post(CARD_var)
                
                filename = paste0("metaEX_", CARD_var, ".fst")

                file_test = file.path(tmppath, filename)
                if (!file.exists(file_test)) {
                    post(paste0("Waiting for ", file_test))
                    start_time = Sys.time()
                    while (!file.exists(file_test) |
                           Sys.time()-start_time < 60) {
                        Sys.sleep(1)
                    }
                    if (Sys.time()-start_time > 60) {
                        post(paste0("Problem with file reading for ",
                                    file_test))
                    }
                }
                
                if (file.exists(file.path(tmppath, filename))) {
                    metaEX = read_tibble(filedir=tmppath,
                                         filename=filename)
                }
                
                if (exists("dataEX")) {
                    rm ("dataEX")
                }
                for (jj in 1:nSubsets) {
                    subset_name = names(Subsets)[jj]
                    if (by_files | MPI == "file") {
                        subset_name = paste0(files_name_opt,
                                             "_", subset_name)
                    }
                    dirname = paste0("dataEX_", CARD_var, "_",
                                     subset_name)
                    filename = paste0(dirname, ".fst")
                    
                    file_test = c(file.path(tmppath, dirname),
                                  file.path(tmppath, filename))
                    if (!any(file.exists(file_test))) {
                        post(paste0("Waiting for ", file_test))
                        start_time = Sys.time()
                        while (!any(file.exists(file_test)) |
                               Sys.time()-start_time < 60) {
                                   Sys.sleep(1)
                               }
                        if (Sys.time()-start_time > 60) {
                            post(paste0("Problem with file reading for ",
                                        file_test))
                        }
                    }
                    
                    if (file.exists(file.path(tmppath, dirname)) |
                        file.exists(file.path(tmppath, filename))) {
                        dataEX_tmp = read_tibble(filedir=tmppath,
                                                 filename=filename)
                        if (!exists("dataEX")) {
                            dataEX = dataEX_tmp
                        } else {
                            if (simplify) {
                                dataEX = dplyr::bind_rows(dataEX,
                                                          dataEX_tmp)
                            } else {
                                for (kk in 1:length(dataEX)) {
                                    dataEX[[kk]] =
                                        dplyr::bind_rows(dataEX[[kk]],
                                                         dataEX_tmp[[kk]])
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
                            
                            for (jj in 1:nVarsREL) {
                                varREL = VarsREL[jj]
                                
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
                        for (jj in 1:length(dataEX)) {
                            dataEX[[jj]] =
                                dataEX[[jj]][order(dataEX[[jj]]$Model),]
                        }
                    }
                }
                
                write_tibble(dataEX,
                             filedir=tmppath,
                             filename=paste0("dataEX_", CARD_var,
                                             ".fst"))
                write_tibble(metaEX,
                             filedir=tmppath,
                             filename=paste0("metaEX_", CARD_var,
                                             ".fst"))
            }
        }

        if ('save_analyse' %in% to_do) {
            post("### Saving analyses")
            post(paste0("Save extracted data and metadata in ",
                         paste0(saving_format, collapse=", ")))

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
            
            if ("meta" %in% var2save & exists("meta")) {
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
            }

            for (ii in 1:length(analyse_data)) {
                
                CARD_dir = analyse_data[[ii]][1]
                simplify = as.logical(analyse_data[[ii]]["simplify"])
                CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)

                dirname = paste0("dataEX_", CARD_var)
                filename = paste0(dirname, ".fst")

                file_test = c(file.path(tmppath, dirname),
                              file.path(tmppath, filename))
                if (!any(file.exists(file_test))) {
                    post(paste0("Waiting for ", file_test))
                    start_time = Sys.time()
                    while (!any(file.exists(file_test)) |
                           Sys.time()-start_time < 60) {
                               Sys.sleep(1)
                           }
                    if (Sys.time()-start_time > 60) {
                        post(paste0("Problem with file reading for ",
                                    file_test))
                    }
                }
                
                if (file.exists(file.path(tmppath, dirname)) |
                    file.exists(file.path(tmppath, filename))) {

                    if ("metaEX" %in% var2save) {
                        metaEX = read_tibble(filedir=tmppath,
                                             filename=paste0("metaEX_",
                                                             CARD_var,
                                                             ".fst"))
                    }
                    if ("dataEX" %in% var2save) {
                        dataEX = read_tibble(filedir=tmppath,
                                             filename=paste0("dataEX_",
                                                             CARD_var,
                                                             ".fst"))
                    }
                } else {
                    next
                }

                if ("dataEX" %in% var2save) {
                    write_tibble(dataEX,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("dataEX_", CARD_var,
                                                 ".fst"))
                    if ("Rdata" %in% saving_format) {
                        write_tibble(dataEX,
                                     filedir=today_resdir_tmp,
                                     filename=paste0("dataEX_", CARD_var,
                                                     ".Rdata"))
                    }
                    if ("txt" %in% saving_format) {
                        write_tibble(dataEX,
                                     filedir=today_resdir_tmp,
                                     filename=paste0("dataEX_", CARD_var,
                                                     ".txt"))
                    }
                }
                
                if ("metaEX" %in% var2save) {
                    write_tibble(metaEX,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("metaEX_", CARD_var,
                                                 ".fst"))
                    if ("Rdata" %in% saving_format) {
                        write_tibble(metaEX,
                                     filedir=today_resdir_tmp,
                                     filename=paste0("metaEX_", CARD_var,
                                                     ".Rdata"))
                    }
                    if ("txt" %in% saving_format) {
                        write_tibble(metaEX,
                                     filedir=today_resdir_tmp,
                                     filename=paste0("metaEX_", CARD_var,
                                                     ".txt"))
                    }
                }
            }
        }

    } else if (MPI == "code") {
        mpi.send(1, type=2, dest=0, tag=1, comm=0)
        post(paste0("End signal from root ", rank)) 
    }

    if ('read_saving' %in% to_do) {
        post("### Reading saving")
        post(paste0("Reading extracted data and metadata in ",
                     read_saving))
        Paths = list.files(file.path(resdir, read_saving),
                           pattern=paste0("(",
                                          paste0(var2search,
                                                 collapse=")|("),
                                          ")"),
                           include.dirs=TRUE,
                           recursive=TRUE,
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
    }

    if ('criteria_selection' %in% to_do) {
        post("### Selecting variables")
        for (i in 1:length(analyse_data)) {
            
            CARD_dir = analyse_data[[i]][1]
            simplify = as.logical(analyse_data[[i]]["simplify"])
            CARD_var = gsub("[/][[:digit:]]+[_]", "_", CARD_dir)

            dataEX_name = paste0("dataEX_", CARD_var)
            metaEX_name = paste0("metaEX_", CARD_var)
            
            if (any(grepl(dataEX_name, ls())) &
                any(grepl(metaEX_name, ls()))) {

                dataEX = get(dataEX_name)
                metaEX = get(metaEX_name)
            
                res = get_select(dataEX, metaEX,
                                 simplify=simplify,
                                 select=criteria_selection)
                dataEX = res$dataEX
                metaEX = res$metaEX
                
                assign(dataEX_name, dataEX)
                assign(metaEX_name, metaEX)
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

    if (delete_tmp) {
        post("### Deleting tmp")
        if (file.exists(tmppath) & rank == 0) {
            unlink(tmppath, recursive=TRUE)
        }
        delete_tmp = FALSE
    }
}
