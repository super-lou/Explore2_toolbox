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
                if (file.exists(file.path(tmppath, filename))) {
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
            

            if (any(grepl("(indicator)|(WIP)", analyse_data))) {

                filename = "metaEXind.fst"
                if (file.exists(file.path(tmppath, filename))) {
                    metaEXind = read_tibble(filedir=tmppath,
                                            filename=filename)
                }
                
                if (exists("dataEXind")) {
                    rm (dataEXind)
                }
                for (i in 1:nSubsets) {
                    subset_name = names(Subsets)[i]
                    if (by_files | MPI == "file") {
                        subset_name = paste0(files_name_opt,
                                             "_", subset_name)
                    }
                    filename = paste0("dataEXind_",
                                      subset_name, ".fst")
                    if (file.exists(file.path(tmppath, filename))) {
                        dataEXind_tmp = read_tibble(filedir=tmppath,
                                                    filename=filename)
                        if (!exists("dataEXind")) {
                            dataEXind = dataEXind_tmp
                        } else {
                            dataEXind = dplyr::bind_rows(dataEXind,
                                                         dataEXind_tmp)
                        }
                    }
                }
                if (exists("dataEXind_tmp")) {
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
                                        dataEXind[[paste0(varREL,
                                                          "_sim")]],
                                        dataEXind[[paste0(varREL,
                                                          "_obs")]],
                                        period=365.25)/30.4375

                            } else if (grepl("(Rc)|(^epsilon)|(^alpha)",
                                             varREL)) {
                                dataEXind[[varREL]] =
                                    dataEXind[[paste0(varREL, "_sim")]] /
                                    dataEXind[[paste0(varREL, "_obs")]]
                                
                            } else {
                                dataEXind[[varREL]] =
                                    (dataEXind[[paste0(varREL,
                                                       "_sim")]] -
                                     dataEXind[[paste0(varREL,
                                                       "_obs")]]) /
                                    dataEXind[[paste0(varREL,
                                                      "_obs")]]
                            }
                            dataEXind =
                                dplyr::relocate(dataEXind,
                                                !!varREL,
                                                .after=!!paste0(varREL,
                                                                "_sim"))
                        }
                    }
                }
            }

            if (any(grepl("serie", analyse_data))) {

                filename = "metaEXserie.fst"
                if (file.exists(file.path(tmppath, filename))) {
                    metaEXserie = read_tibble(filedir=tmppath,
                                              filename=filename)
                }
                
                if (exists("dataEXserie")) {
                    rm (dataEXserie)
                }
                for (i in 1:nSubsets) {
                    subset_name = names(Subsets)[i]
                    if (by_files | MPI == "file") {
                        subset_name = paste0(files_name_opt,
                                             "_", subset_name)
                    }
                    dirname = paste0("dataEXserie_",
                                     subset_name)
                    post(dirname)
                    post(file.exists(file.path(tmppath, dirname)))
                    if (file.exists(file.path(tmppath, dirname))) {
                        dataEXserie_tmp = read_tibble(
                            filedir=tmppath,
                            filename=paste0(dirname, ".fst"))
                        if (!exists("dataEXserie")) {
                            dataEXserie = dataEXserie_tmp
                        } else {
                            for (i in 1:length(dataEXserie)) {
                                dataEXserie[[i]] =
                                    dplyr::bind_rows(
                                               dataEXserie[[i]],
                                               dataEXserie_tmp[[i]])
                            }
                        }
                    }
                }
                if (exists("dataEXserie_tmp")) {
                    rm (dataEXserie_tmp)
                    
                    for (i in 1:length(dataEXserie)) {
                        dataEXserie[[i]] =
                            dataEXserie[[i]][order(dataEXserie[[i]]$Model),]
                    }
                }
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

            file.copy(data_paths,
                      file.path(today_resdir_tmp, data_files))
            
            write_tibble(meta,
                         filedir=today_resdir_tmp,
                         filename=paste0("meta.fst"))
            
            if (any(grepl("(indicator)|(WIP)", analyse_data))) {
                write_tibble(metaEXind,
                             filedir=today_resdir_tmp,
                             filename=paste0("metaEXind.fst"))
                write_tibble(dataEXind,
                             filedir=today_resdir_tmp,
                             filename=paste0("dataEXind.fst"))
            }
            if (any(grepl("serie", analyse_data))) {
                write_tibble(metaEXserie,
                             filedir=today_resdir_tmp,
                             filename=paste0("metaEXserie.fst"))
                write_tibble(dataEXserie,
                             filedir=today_resdir_tmp,
                             filename=paste0("dataEXserie.fst"))
            }

            if ("Rdata" %in% saving_format) {
                write_tibble(meta,
                             filedir=today_resdir_tmp,
                             filename=paste0("meta.Rdata"))
                if (any(grepl("(indicator)|(WIP)", analyse_data))) {
                    write_tibble(metaEXind,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("metaEXind.Rdata"))
                    write_tibble(dataEXind,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("dataEXind.Rdata"))
                }
                if (any(grepl("serie", analyse_data))) {
                    write_tibble(metaEXserie,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("metaEXserie.Rdata"))
                    write_tibble(dataEXserie,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("dataEXserie.Rdata"))
                }
            }    
            if ("txt" %in% saving_format) {
                write_tibble(meta,
                             filedir=today_resdir_tmp,
                             filename=paste0("meta.txt"))
                if (any(grepl("(indicator)|(WIP)", analyse_data))) {
                    write_tibble(metaEXind,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("metaEXind.txt"))
                    write_tibble(dataEXind,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("dataEXind.txt"))
                }
                if (any(grepl("serie", analyse_data))) {
                    write_tibble(metaEXserie,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("metaEXserie.txt"))
                    write_tibble(dataEXserie,
                                 filedir=today_resdir_tmp,
                                 filename=paste0("dataEXserie.txt"))
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
        res = get_select(dataEXind, metaEXind,
                         select=criteria_selection)
        dataEXind = res$dataEXind
        metaEXind = res$metaEXind
    }

    if ('write_warnings' %in% to_do) {
        post("### Writing warnings")
        Warnings = find_Warnings(dataEXind, metaEXind,
                                 resdir=today_resdir, save=TRUE)
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
