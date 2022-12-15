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
# R/script_analyse.R
#
# Script that manages the call to the right process in order to
# realise analyses.


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {

    script_to_analyse_dirpath = file.path(CARD_dir, var_to_analyse_dir)
    
    script_to_analyse = list.files(script_to_analyse_dirpath,
                                   pattern=".R$",
                                   recursive=TRUE,
                                   include.dirs=FALSE,
                                   full.names=FALSE)

    script_to_analyse = script_to_analyse[!grepl("default.R",
                                                 script_to_analyse)]

    topic_to_analyse = list.dirs(script_to_analyse_dirpath,
                                 recursive=TRUE, full.names=FALSE)
    topic_to_analyse = topic_to_analyse[topic_to_analyse != ""]
    topic_to_analyse = gsub('.*_', '', topic_to_analyse)

    structure = replicate(length(topic_to_analyse), c())
    names(structure) = topic_to_analyse
    
    var_analyse = c()
    topic_analyse = c()
    unit_analyse = c()
    samplePeriod_analyse = list()
    glose_analyse = c()

    metaVAR = dplyr::tibble()
    
    if (exists("dataEx")) {
        rm (dataEx)
    }
    
    for (script in script_to_analyse) {
        
        list_path = list.files(file.path(CARD_dir,
                                         init_tools_dir),
                               pattern='*.R$',
                               full.names=TRUE)
        for (path in list_path) {
            source(path, encoding='UTF-8')    
        }

        Process_default = sourceProcess(
            file.path(CARD_dir,init_var_file))
        
        Process = sourceProcess(
            file.path(script_to_analyse_dirpath, script),
            default=Process_default)

        principal = Process$P
        principal_names = names(principal)
        for (i in 1:length(principal)) {
            assign(principal_names[i], principal[[i]])
        }
        
        split_script = split_path(script)
        
        if (length(split_script) == 1) {
            if (!('None' %in% names(structure))) {
                structure = append(list(None=c()), structure)
            }
            structure[['None']] = c(structure[['None']], var)
        } else if (length(split_script) == 2) {
            dir = split_script[2]
            dir = gsub('.*_', '', dir)
            structure[[dir]] = c(structure[[dir]], var)
        }
        
        if (samplePeriod_mode == 'optimale') {
            if (identical(samplePeriod_opti[[topic]], "min")) {
                minQM = paste0(formatC(meta$minQM,
                                       width=2,
                                       flag="0"),
                               '-01')
                samplePeriodMOD = tibble(Code=meta$Code,
                                         sp=minQM)
            } else if (identical(samplePeriod_opti[[topic]], "max")) {
                maxQM = paste0(formatC(meta$maxQM,
                                       width=2,
                                       flag="0"),
                               '-01')
                samplePeriodMOD = tibble(Code=meta$Code,
                                         sp=maxQM)
            } else {
                samplePeriodMOD = samplePeriod_opti[[topic]]
            }
            
        } else {
            samplePeriodMOD = NULL
        }

        if (!is.null(samplePeriodMOD)) {
            nProcess = length(Process)
            for (i in 1:nProcess) {
                if (!is.null(Process[[i]]$samplePeriod)) {
                    Process[[i]]$samplePeriod = samplePeriodMOD
                    samplePeriod = Process[[i]]$samplePeriod
                }
            }
        }

        if (var %in% var_analyse) {
            next
        }
        
        var_analyse = c(var_analyse, var)
        topic_analyse = c(topic_analyse, topic)
        unit_analyse = c(unit_analyse, unit)
        samplePeriod_analyse = append(samplePeriod_analyse,
                                      list(samplePeriod))
        glose_analyse = c(glose_analyse, glose)

        Xex = get_dataEx(data=data,
                         Process=Process,
                         period=period)

        print(paste0("Data extracted for ", var))
        print(Xex)

        vars = names(Xex)[!(names(Xex) %in% c("ID", "Date"))]
        vars = gsub("([_]obs)|([_]sim)", "", vars)
        vars = vars[!duplicated(vars)]

        metaVAR = dplyr::bind_rows(
                             metaVAR,
                             dplyr::tibble(var=vars,
                                           unit=unit,
                                           glose=glose,
                                           topic=
                                               paste0(topic,
                                                      collapse="/"),
                                           samplePeriod=
                                               paste0(samplePeriod,
                                                      collapse="/")))

        Xex$Model = gsub("[_].*$", "", Xex$ID)
        Xex$Code = gsub("^.*[_]", "", Xex$ID)
        Xex = dplyr::select(Xex, -ID)
        Xex = dplyr::select(Xex, Model, Code, dplyr::everything())

        if (!exists("dataEx")) {
            dataEx = Xex
        } else {
            dataEx = dplyr::full_join(dataEx,
                                      Xex,
                                      by=c("Model", "Code"))  
        }
    }
    write_tibble(meta,
                 filedir=tmpdir,
                 filename=paste0("meta_", subset, ".fst"))
    write_tibble(dataEx,
                 filedir=tmpdir,
                 filename=paste0("dataEx_", subset, ".fst"))
}
