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


## 1. STATION TREND ANALYSIS _________________________________________
if ('station_trend_analyse' %in% to_do) {

    script_to_analyse_dirpath = file.path(CARD_dir, var_to_analyse_dir)
    
    script_to_analyse = list.files(script_to_analyse_dirpath,
                                   pattern=".R$",
                                   recursive=TRUE,
                                   include.dirs=FALSE,
                                   full.names=FALSE)

    script_to_analyse = script_to_analyse[!grepl("default.R",
                                                 script_to_analyse)]

    event_to_analyse = list.dirs(script_to_analyse_dirpath,
                                 recursive=TRUE, full.names=FALSE)
    event_to_analyse = event_to_analyse[event_to_analyse != ""]
    event_to_analyse = gsub('.*_', '', event_to_analyse)

    structure = replicate(length(event_to_analyse), c())
    names(structure) = event_to_analyse
    
    var_analyse = c()
    event_analyse = c()
    unit_analyse = c()
    samplePeriod_analyse = list()
    glose_analyse = c()
    data_analyse = list()
    trend_analyse = list()

    if (exists("dataEx")) {
        rm (dataEx)
    }
    
### 1.3. Trend analyses ______________________________________________
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
            if (identical(samplePeriod_opti[[event]], "min")) {
                minQM = paste0(formatC(meta$minQM,
                                       width=2,
                                       flag="0"),
                               '-01')
                samplePeriodMOD = tibble(Code=meta$Code,
                                         sp=minQM)
            } else if (identical(samplePeriod_opti[[event]], "max")) {
                maxQM = paste0(formatC(meta$maxQM,
                                       width=2,
                                       flag="0"),
                               '-01')
                samplePeriodMOD = tibble(Code=meta$Code,
                                         sp=maxQM)
            } else {
                samplePeriodMOD = samplePeriod_opti[[event]]
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
        event_analyse = c(event_analyse, event)
        unit_analyse = c(unit_analyse, unit)
        samplePeriod_analyse = append(samplePeriod_analyse,
                                      list(samplePeriod))
        glose_analyse = c(glose_analyse, glose)

        Xex = get_dataEx(data=data,
                         Process=Process,
                         period=period)

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
            
        if ('modified_data' %in% to_assign_out) {
            assign(paste0(var, 'data'), Xdata)
            assign(paste0(var, 'mod'), Xmod)
        }
        
        if ('analyse' %in% to_assign_out) {
            assign(paste0(var, 'ex'), Xex)
        }

        if ('station_trend_plot' %in% to_do | is.null(saving)) {
            data_analyse = append(data_analyse, list(Xex))
        }

        ### 1.3. Saving ______________________________________________________
        # if ('modified_data' %in% saving & !read_results) {
        #     # Writes modified data
        #     write_data(Xdata, Xmod, resdir,
        #                filedir=file.path(modified_data_dir,
        #                                  var, monthSamplePeriod))
        
        #     if (fast_format) {
        #         write_dataFST(Xdata, resdir,
        #                       filedir='fst',
        #                       filename=paste0('data_', var,
        #                                       '_', monthSamplePeriod,
        #                                       '.fst'))
        #     }
        # }

        # if ('analyse' %in% saving) {                
        #     # Writes trend analysis results
        #     write_analyse(res_Xanalyse, resdir,
        #                   filedir=file.path(trend_dir,
        #                                     var, monthSamplePeriod))
        
        #     if (fast_format) {
        #         write_dataFST(Xex,
        #                       resdir,
        #                       filedir='fst',
        #                       filename=paste0(var, 'Ex_',
        #                                       monthSamplePeriod,
        #                                       '.fst'))
        #     }
        # }
    }
}

if ('meta' %in% saving) {
    if (fast_format) {
        write_metaFST(meta, resdir,
                      filedir=file.path('fst'))
    }
}
