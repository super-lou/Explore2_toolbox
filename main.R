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


#  ___         __                         _    _                
# |_ _| _ _   / _| ___  _ _  _ __   __ _ | |_ (_) ___  _ _   ___
#  | | | ' \ |  _|/ _ \| '_|| '  \ / _` ||  _|| |/ _ \| ' \ (_-<
# |___||_||_||_|  \___/|_|  |_|_|_|\__,_| \__||_|\___/|_||_|/__/ _____
# If you want to contact the author of the code you need to contact
# first Louis Héraut who is the main developer. If it is not possible,
# Éric Sauquet is the main referent at INRAE to contact.
#
# Louis Héraut : <https://github.com/super-lou>
#                <louis.heraut@inrae.fr>
#                 
# Éric Sauquet : <eric.sauquet@inrae.fr>
#
# See the 'README.md' file for more information about the utilisation
# of this toolbox.


#  ___                            
# | _ \ _ _  ___  __  ___  ___ ___
# |  _/| '_|/ _ \/ _|/ -_)(_-<(_-<
# |_|  |_|  \___/\__|\___|/__//__/ ___________________________________
## 1. REQUIREMENTS ___________________________________________________
# Ex2D_toolbox path
lib_path =
    "./"
# '/home/herautl/library/Ex2D_toolbox'

# Display information along process
verbose =
    # FALSE
    TRUE


## 2. GENERAL PROCESSES ______________________________________________
# This to_do vector regroups all the different step you want to do.
# For example if you write 'create_data', a tibble of hydrological
# data will be created according to the info you provide in the ## 1.
# CREATE_DATA section of the STEPS part below. If you also add
# 'analyse_data' in the vector, the analyse will also be perfom
# following the creation of data. But if you only write, for example,
# 'plot_sheet', without having previously execute the code to have
# loading data to plot, it will results in a failure.
#
# Options are listed below with associated results after '>' :
#
# - 'delete_tmp' :
#     Delete temporary data in the tmpdir/.
#     > Permanently erase temporary data.
#
# - 'create_data' :
#     Creation of tibble of data that will be saved in tmpdir/. The
#     data will be saved in fst format which is a fast reading and
#     writting format. Each data tibble go with its meta tibble that
#     regroup info about the data. Those files are named with a '_'
#     followed by a capital letter that correspond to the first letter
#     of the hydrological station codes that are stored in it. A file
#     contain nCode4RAM stations, so each nCode4RAM stations a
#     different file is created with a digit in its name to specify
#     it. The selection of station code is done in the
#     code_filenames_to_use variable of the ## 1. CREATE_DATA section
#     of the STEPS part below and the model used are selected in the
#     variable models_to_diag of that same previous section.
#     > tmpdir/data_K1.fst :
#        A fst file that contain the tibble of created data.
#     > tmpdir/meta_K1.fst :
#        An other fst file that contain info about the data file.
#
# - 'analyse_data' :
#     Perfom the requested analysis on the created data contained in
#     the tmpdir/. Details about the analysis are given with the
#     analyse_data variable in the ## 2. ANALYSE_DATA section of the
#     STEPS part below. This variable needs to be a path to a CARD
#     directory. See CARD toolbox for more info
#     https://github.com/super-lou/CARD.
#     > tmpdir/dataEXind_K1.fst : 
#        If the CARD directory contains 'indicator' this fst file
#        will be created.
#     > tmpdir/metaEXind_K1.fst :
#        Info about variables stored in dataEXind_K1.fst.
#     > tmpdir/dataEXserie_K1/ : 
#        If the CARD directory contains 'serie' this directory that
#        contains a fst file for each serie variable extracted
#        will be created.
#     > tmpdir/metaEXserie_K1.fst :
#        Info about variables stored in dataEXserie_K1.
#
# - 'save_analyse' :
#     Saves all the data contained in the tmpdir/ to the resdir/. The
#     format used is specified in the saving_format variable of the 
#     ## 3. SAVE_ANALYSE section of the STEPS part.
#     > Moves all temporary data in tmpdir/ to the resdir/.
#
# - 'read_tmp' :
#     Loads in RAM all the data stored in fst files in the tmpdir/.
#     > For example, if there is a tmpdir/metaEXind_K1.fst file, a
#       data called metaEXind_K1 will be created in the current R
#       process that contained the data stored in the previous files.
#
# - 'read_saving' :
#     Loads in RAM all the data stored in the resdir/ which names are
#     based on var2search.
#     > Same as 'read_tmp' results but again from resdir/.
#
# - 'criteria_selection' :
#     Select only the criteria listed in the criteria_selection
#     variable in the extracted data.
#     > For example, if dataEXind exists, it will returns the same
#       dataEXind tibble but only with columns of selected criteria. 
#
# - 'write_warnings' :
#     Writes in tmpdir/ the Warnings.fst file which is a tibble of
#     warnings based on the dataEXind tibble.
#     > Warnings tibble in RAM and writes it in tmpdir/.
#
# - 'plot_sheet' :
#     Plots a set of datasheets specify by the plot_sheet variable
#     below. Different plotting options are mentioned in the ## 6.
#     PLOT_SHEET section of the STEPS part.
#     > Creates a pdf file in the figdir/ directory.
#
# - 'plot_doc' :
#     Plots a pre-define set of datasheets in document format specify
#     by the plot_doc variable below and the corresponding variables
#     define in ## 7. PLOT_DOC.
#     > Creates set of pdf files and a pdf document that regroup all
#       those individual file in a specific directory of the figdir/
#       directory.

to_do =
    c(
        # 'delete_tmp',
        # 'create_data',
        # 'analyse_data',
        # 'save_analyse'
        # 'read_tmp'
        # 'read_saving',
        # 'criteria_selection',
        # 'write_warnings'
        # 'plot_sheet'
        'plot_doc'
        # 'create_data_proj'
    )

## 3. PLOTTING PROCESSES _____________________________________________
### 3.1. Sheet _______________________________________________________
# The use of this plot_sheet vector is quite similar to the to_do vector. It regroups all the different datasheet you want to plot individually. For example if you write 'diagnostic_station', the data previously analysed saved and read will be use to plot the diagnostic datasheet for a specific station  
# loading data to plot, it will results in a failure.
#
# Options are listed below with associated results after '>' :
plot_sheet =
    c(
        # 'summary'
        'diagnostic_matrix'
        # 'diagnostic_station'
        # 'diagnostic_region'
        # 'diagnostic_regime'
    )

### 3.2. Document ____________________________________________________
plot_doc =
    c(
        # "diagnostic_matrix"
        # 'diagnostic_regime'
        'diagnostic_region'
    )


#  ___  _                  
# / __|| |_  ___  _ __  ___
# \__ \|  _|/ -_)| '_ \(_-<
# |___/ \__|\___|| .__//__/ __________________________________________
## 1. CREATE_DATA|_| _________________________________________________ 
period_diagnostic = c('1976-01-01', '2019-12-31')
propagate_NA = TRUE
nCode4RAM = 25

models_to_diag =
    list(
        "CTRIP"="CTRIP_diagnostic_20230124.nc",
        "EROS"=c("ErosBretagne_20230131.Rdata",
                 "ErosLoire_20230131.Rdata"),
        "GRSD"="GRSD_20230223.nc",
        "J2000"="DATA_DIAGNOSTIC_EXPLORE2_J2000.Rdata",
        "SIM2"="Debits_modcou_19580801_20210731_day_METADATA.nc",
        "MORDOR-SD"="MORDOR-SD_20221912.Rdata",
        "MORDOR-TS"="MordorTS_20221213.Rdata",
        "ORCHIDEE"="MODEL_ORCHIDEE_KWR-RZ1-RATIO-19760101_20191231.nc",
        "SMASH"="SMASH_20230303.nc"
    )
complete_by = "SMASH"

models_to_proj = c(
        # "CTRIP",
        # "EROS",
        # "GRSD",
        # "J2000"=
        # "SIM2"=
        # "MORDOR-TS"="debit_Loire_CNRM-CERFACS-CNRM-CM5_historical_r1i1p1_CNRM-ALADIN63_v2_MF-ADAMONT-SAFRAN-1980-2011_EDF-MORDOR-TS_day_19510101-20051231.nc"
        # "ORCHIDEE",
        # "SMASH"=
)

code_filenames_to_use =
    # ''
    c(
        'all'
        # 'K2981910_HYDRO_QJM.txt' #ref
        # 'O3084320_HYDRO_QJM.txt'
        # 'WDORON01_HYDRO_QJM.txt'
        # 'WDORON02_HYDRO_QJM.txt',
        # 'WSOULOIS_HYDRO_QJM.txt',
        # 'XVENEON1_HYDRO_QJM.txt',
        # 'XVENEON2_HYDRO_QJM.txt',
        # "X0454010_HYDRO_QJM.txt"
        # 'A4362030_HYDRO_QJM.txt'
        # '^X'
        # 'X0454010_HYDRO_QJM.txt',
        # 'XVENEON1_HYDRO_QJM.txt'
        
        # '^H'
        # '^I'
        # '^J'
        # '^K'
        # '^M'
        # '^U'
        # '^V'
        # '^W'
        
        # '^G'
        # '^R'
    )


## 2. ANALYSE_DATA ___________________________________________________
# Name of the subdirectory in 'CARD_dir' that includes variables to
# analyse. If no subdirectory is selected, all variable files will be
# used in 'CARD_dir' (which is may be too much).
# This subdirectory can follows some rules :
# - Variable files can be rename to began with a number followed by an
#   underscore '_' to create an order in variables. For example,
#   '2_QA.R' will be analysed and plotted after '1_QMNA.R'.
# - Directory of variable files can also be created in order to make a
#   group of variable of similar topic. Names should be chosen between
#   'Crue'/'Crue Nivale'/'Moyennes Eaux' and 'Étiage'. A directory can
#   also be named 'Resume' in order to not include variables in an
#   topic group.

analyse_data = c(
    'WIP'
    # 'Ex2D/1_indicator/1_all',
    # 'Ex2D/1_indicator/2_selection'
    # 'Ex2D/2_serie'
)


## 3. SAVE_ANALYSE ___________________________________________________
# Saving format to use to save analyse data
saving_format = c('Rdata', 'txt')


## 4. READ_SAVING ____________________________________________________
read_saving = "ALL"

var2search = c(
    'meta',
    'dataEXind',
    'metaEXind',
    'dataEXserie',
    'metaEXserie',
    'Warnings'
)


## 5. CRITERIA_SELECTION _____________________________________________
criteria_selection =
    # "all"
    c("KGEracine", "Biais$", "epsilon_{T,JJA}", "epsilon_{T,DJF}", "epsilon_{P,JJA}", "epsilon_{P,DJF}", "RAT_T", "RAT_P", "Q10", "median{tQJXA}", "^alphaQA", "^alphaCDC", "Q90", "median{tVCN10}")


## 6. PLOT_SHEET _____________________________________________________
# If the hydrological network needs to be plot
river_selection =
    # 'none'
    c('La Seine$', "'Yonne$", 'La Marne$', 'La Meuse', 'La Moselle$', '^La Loire$', '^la Loire$', '^le cher$', '^La Creuse$', '^la Creuse$', '^La Vienne$', '^la Vienne$', 'La Garonne$', 'Le Tarn$', 'Le Rhône$', 'La Saône$')
# 'all'

# Tolerance of the simplification algorithm for shapefile in sf
toleranceRel =
    # 1000 # normal map
    10000 # mini map

# Which logo do you want to show in the footnote
logo_to_show =
    c(
        Explore2='LogoExplore2.png'
    )

# Probability used to define the min and max quantile needed for
# colorbar extremes. For example, if set to 0.01, quartile 1 and
# quantile 99 will be used as the minimum and maximum values to assign
# to minmimal maximum colors.
exXprob = 0.01

Colors_of_models = c(
    "CTRIP"="#a88d72", #marron
    "EROS"="#cecd8d", #vert clair
    "GRSD"="#619c6c", #vert foncé
    "J2000"="#74aeb9", #bleu clair
    "SIM2"="#384a54", #bleu foncé
    "MORDOR-SD"="#d8714e", #orange
    "MORDOR-TS"="#ae473e", #rouge
    "ORCHIDEE"="#efa59d", #rose #f5c8c3
    "SMASH"="#f6ba62" #mimosa    
)


## 7. PLOT_DOC _______________________________________________________
default_doc_name = "Diagnostic Hydrologique"
doc_diagnostic_matrix =
    list(
        name='Diagnostic Hydrologique Choix des Indicateurs',
        chunk='all',
        'summary',
        'diagnostic_matrix'
    )
doc_diagnostic_regime =
    list(
        name='Diagnostic Hydrologique par Régime',
        chunk='all',
        'summary',
        'diagnostic_regime'
    )
doc_diagnostic_region =
    list(
        name='Diagnostic Hydrologique Régional',
        chunk='region',
        'summary',
        'diagnostic_region',
        'diagnostic_station'
    )


#  ___               __  _   
# |   \  _ _  __ _  / _|| |_ 
# | |) || '_|/ _` ||  _||  _|
# |___/ |_|  \__,_||_|   \__| ________________________________________
# dataEXserieQM_obs =
#     dplyr::summarise(dplyr::group_by(dataEXserie$QM, Code, Month),
#                      QM=select_good(QM_obs),
#                      .groups="drop")
# dataEXseriePA_med = dplyr::summarise(dplyr::group_by(dataEXserie$PA,
#                                                      Code, Date),
#                                      PAs=median(PAs, na.rm=TRUE),
#                                      PAl=median(PAl, na.rm=TRUE),
#                                      PA=median(PA, na.rm=TRUE),
#                                      .groups="drop")
# find_regimeHydro(dataEXserieQM_obs, 2, dataEXseriePA_med)


# Error in `dplyr::summarise()` at EXstat/R/process_extraction.R:1286:16:
# ! Problem while computing `ValueEX1 = f(...)`.
# ℹ The error occurred in group 4072: Code = "SMASH_A6541110", Date_g = "1993".
# Caused by error in `f()`:
# ! objet 'period_select' introuvable
# Run `rlang::last_error()` to see where the error occurred.
# There were 50 or more warnings (use warnings() to see the first 50)


#  ___        _  _    _        _  _            _    _            
# |_ _| _ _  (_)| |_ (_) __ _ | |(_) ___ __ _ | |_ (_) ___  _ _  
#  | | | ' \ | ||  _|| |/ _` || || |(_-</ _` ||  _|| |/ _ \| ' \ 
# |___||_||_||_| \__||_|\__,_||_||_|/__/\__,_| \__||_|\___/|_||_| ____
##### /!\ Do not touch if you are not aware #####
## 0. LIBRARIES ______________________________________________________
# Computer
computer = Sys.info()["nodename"]
print(paste0("Computer ", computer))
computer_file_list = list.files(path=lib_path,
                                pattern="computer[_].*[.]R")
computer_list = gsub("(computer[_])|([.]R)", "", computer_file_list)
computer_file = computer_file_list[sapply(computer_list,
                                          grepl, computer)]
computer_path = file.path(lib_path, computer_file)
print(paste0("So reading file ", computer_path))
source(computer_path, encoding='UTF-8')

# Sets working directory
setwd(computer_work_path)
source(file.path(lib_path, 'tools.R'), encoding='UTF-8')

# Import EXstat
dev_path = file.path(dev_lib_path,
                     c('', 'EXstat_project'), 'EXstat', 'R')
if (any(file.exists(dev_path))) {
    print('Loading EXstat from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading EXstat from package')
    library(EXstat)
}

# Import ASHE
dev_path = file.path(dev_lib_path,
                     c('', 'ASHE_project'), 'ASHE', 'R')
if (any(file.exists(dev_path))) {
    print('Loading ASHE from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading ASHE from package')
    library(ASHE)
}

# Import dataSHEEP
dev_path = file.path(dev_lib_path,
                     c('', 'dataSHEEP_project'), 'dataSHEEP',
                     "__SHEEP__")
                     # 'Ex2D')
if (any(file.exists(dev_path))) {
    print('Loading dataSHEEP')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE,
                           recursive=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
}

# Import other library
print("Importing library")
library(dplyr)
library(ggplot2)
library(qpdf)
library(gridExtra)
library(gridtext) #nope
library(ggh4x)
library(rgdal)
library(shadowtext)
library(png)
library(ggrepel)
library(latex2exp)
library(sf) #nope
library(stringr)
library(ggtext) #nope
# already ::
# library(grid)
# library(ncdf4)
# library(rgeos)
# library(lubridate)
# library(sp)


if ("delete_tmp" %in% to_do) {
    delete_tmp = TRUE
    to_do = to_do[to_do != "delete_tmp"]
} else {
    delete_tmp = FALSE
}

if ("read_tmp" %in% to_do) {
    read_tmp = TRUE
    to_do = to_do[to_do != "read_tmp"]
} else {
    read_tmp = FALSE
}

if ('plot_doc' %in% to_do) {
    plot_doc = get(paste0("doc_", plot_doc[1]))
}

codes_to_diag_shp = read_shp(file.path(computer_data_path,
                                       codes_to_diag_shp_dir))
codes_to_diag = as.character(codes_to_diag_shp$Code)
if (all(code_filenames_to_use == "")) {
    stop ("No station selected")
}

if (all(code_filenames_to_use == "all")) {
    CodeALL = codes_to_diag
} else {
    code_filenames_to_use = convert_regexp(computer_data_path,
                                           obs_dir,
                                           code_filenames_to_use)
    codes_to_use = gsub("[_].*$", "", code_filenames_to_use)
    okCode = codes_to_use %in% codes_to_diag
    CodeALL = codes_to_use[okCode]
}
nCodeALL = length(CodeALL)

tmppath = file.path(computer_work_path, tmpdir)
if (read_tmp | delete_tmp) {
    print("## MANAGING DATA")
    source(file.path(lib_path, 'script_management.R'),
           encoding='UTF-8')
}
if (!(file.exists(tmppath))) {
    dir.create(tmppath, recursive=TRUE)
}

if (any(c('create_data', 'analyse_data', 'create_data_proj') %in% to_do)) {

    if (all(c('create_data', 'analyse_data') %in% to_do)) {
        print("## CREATING AND ANALYSING DATA")
    } else if ('create_data' %in% to_do) {
        print("## CREATING DATA")
    } else if ('analyse_data' %in% to_do) {
        print("## ANALYSING DATA")
    } else {
        print("Maybe you can start by creating data")
    }

    if (MPI) {
        library(Rmpi)
        rank = mpi.comm.rank(comm=0)
        size = mpi.comm.size (comm=0)
    } else {
        rank = 0
        size = 1
    }

    firstLetterALL = substr(CodeALL, 1, 1)
    IdCode = cumsum(table(firstLetterALL))

    Subsets = list()
    for (i in 1:length(IdCode)) {
        Id = IdCode[i]
        if (i == 1) {
            id = 1    
        } else {
            id = IdCode[i-1] + 1
        }
        names(id) = NULL
        name = names(Id)
        names(Id) = NULL
        n = 1
        while (id+nCode4RAM < Id) {
            Subsets = append(Subsets, list(c(id, id+nCode4RAM)))
            names(Subsets)[length(Subsets)] = paste0(name, n)
            id = id+nCode4RAM+1
            n = n+1
        }
        if (id != Id) {
            Subsets = append(Subsets, list(c(id, Id)))
            names(Subsets)[length(Subsets)] = paste0(name, n)
        } else if (id == Id & Id == 1) {
            Subsets = append(Subsets, list(c(id, Id)))
            names(Subsets)[length(Subsets)] = paste0(name, n)
        }
    }
    
    nSubsets = length(Subsets)
    Subsets = Subsets[as.integer(rank*(nSubsets/size+.5)+1):
                      as.integer((rank+1)*(nSubsets/size+.5))]
    Subsets = Subsets[!is.na(names(Subsets))]
    nSubsets = length(Subsets)
    
    for (i in 1:nSubsets) {

        subset = Subsets[[i]]
        subset_name = names(Subsets)[i]

        file_test = c()
        if ('create_data' %in% to_do) {
            file_test = c(file_test,
                          paste0("data_", subset_name, ".fst"))
        }
        if (any(grepl("(indicator)|(WIP)", analyse_data))) {
            file_test = c(file_test,
                          paste0("dataEXind_", subset_name, ".fst"))
        }
        if (any(grepl("serie", analyse_data))) {
            file_test = c(file_test,
                          paste0("dataEXserie_", subset_name))
        }
        print(paste0(i, "/", nSubsets,
                     " chunks of stations in analyse so ",
                     round(i/nSubsets*100, 1), "% done"))
        
        if (all(file_test %in% list.files(tmppath, include.dirs=TRUE))) {
            next
        }
        
        # CodeSUB = CodeALL[((subset-1)*nCode4RAM+1):(subset*nCode4RAM)]
        CodeSUB = CodeALL[subset[1]:subset[2]]
        CodeSUB = CodeSUB[!is.na(CodeSUB)]
        nCodeSUB = length(CodeSUB)

        if (any(c('create_data', 'create_data_proj') %in% to_do)) {
            source(file.path(lib_path, 'script_create.R'),
                   encoding='UTF-8')
        }
        if (is.null(data)) {
            next
        }
        if ('analyse_data' %in% to_do) {
            source(file.path(lib_path, 'script_analyse.R'),
                   encoding='UTF-8')
        }
    }
}

if (any(c('analyse_data', 'save_analyse',
          'criteria_selection', 'write_warnings',
          'read_saving') %in% to_do)) {
    print("## MANAGING DATA")
    source(file.path(lib_path, 'script_management.R'),
           encoding='UTF-8')
}

if (any(c('plot_sheet', 'plot_doc') %in% to_do)) {
    print("## PLOTTING DATA")
    source(file.path(lib_path, 'script_layout.R'),
           encoding='UTF-8')
}
