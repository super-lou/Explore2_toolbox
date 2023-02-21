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


# Main script that regroups all command lines needed to interact with
# this toolbox. Choose your parameters before executing all the script
# (RStudio : Ctrl+Alt+R) or line by line.


#  ___         __                         _    _                
# |_ _| _ _   / _| ___  _ _  _ __   __ _ | |_ (_) ___  _ _   ___
#  | | | ' \ |  _|/ _ \| '_|| '  \ / _` ||  _|| |/ _ \| ' \ (_-<
# |___||_||_||_|  \___/|_|  |_|_|_|\__,_| \__||_|\___/|_||_|/__/ _____
# If you want to contact the author of the code you need to contact
# first Louis Héraut who is the main developer. If it is not possible,
# Éric Sauquet is the main referent at INRAE to contact.
#
# Louis Héraut : <louis.heraut@inrae.fr>
# Éric Sauquet : <eric.sauquet@inrae.fr>
#
# See the 'README.txt' file for more information about the utilisation
# of this toolbox.


#  ___  _  _                 _                   _                   
# | __|(_)| | ___  ___   ___| |_  _ _  _  _  __ | |_  _  _  _ _  ___ 
# | _| | || |/ -_)(_-<  (_-<|  _|| '_|| || |/ _||  _|| || || '_|/ -_)
# |_|  |_||_|\___|/__/  /__/ \__||_|   \_,_|\__| \__| \_,_||_|  \___|
## 1. WORKING DIRECTORY ______________________________________________
# Work path
computer_work_path = '/home/louis/Documents/bouleau/INRAE/project/Ex2D_project/Ex2D_toolbox'


## 2. INPUT DIRECTORIES ______________________________________________
### 2.1. Data ________________________________________________________
computer_data_path = '/home/louis/Documents/bouleau/INRAE/data'
obs_dir = "Explore2/Explore2 HYDRO QJM critiques 2023"
obs_format = "_HYDRO_QJM.txt"
diag_dir = "Explore2/diagnostic"
proj_dir = "Explore2/projection"
codes_to_diag_shp_dir = "Explore2/reseauReferenceHYDRO"

### 2.2. Variables ___________________________________________________
# Name of the directory that regroups all variables information
CARD_path = file.path(gsub("[/]project[/].*$", "",
                           computer_work_path),
                      "project",
                      "CARD_project",
                      "CARD")
# Name of the tool directory that includes all the functions needed to
# calculate a variable
init_tools_dir = '__tools__'
# Name of the default parameters file for a variable
init_var_file = '__default__.R'

### 2.3. Resources ___________________________________________________
resources_path = file.path(computer_work_path, 'resources')
if (!(file.exists(resources_path))) {
  dir.create(resources_path)
}
print(paste('resources_path :', resources_path))
#### 2.3.1. Logo _____________________________________________________
logo_dir = 'logo'

#### 2.3.2. Icon _____________________________________________________
icon_dir = 'icon'

#### 2.3.3. Shapefile ________________________________________________
shp_dir = 'map'
# Path to the shapefile for france contour from 'computer_data_path' 
france_dir = file.path(shp_dir, 'france')
france_file = 'gadm36_FRA_0.shp'
# Path to the shapefile for basin shape from 'computer_data_path' 
bassinHydro_dir = file.path(shp_dir, 'bassinHydro')
bassinHydro_file = 'bassinHydro.shp'
# Path to the shapefile for sub-basin shape from 'computer_data_path' 
regionHydro_dir = file.path(shp_dir, 'regionHydro')
regionHydro_file = 'regionHydro.shp'
# Path to the shapefile for station basins shape from 'computer_data_path' 
entiteHydro_dir = file.path(shp_dir, 'entiteHydro')
entiteHydro_file = c('BV_4207_stations.shp', '3BVs_FRANCE_L2E_2018.shp')
entiteHydro_coord = c('L93', 'L2')
# Path to the shapefile for river shape from 'computer_data_path' 
river_dir = file.path('map', 'river')
river_file = 'CoursEau_FXX.shp'


## 3. OUTPUT DIRECTORIES _____________________________________________
### 3.0. Info ________________________________________________________
today = format(Sys.Date(), "%Y_%m_%d")
now = format(Sys.time(), "%H_%M_%S")

### 3.1. Results _____________________________________________________
resdir = file.path(computer_work_path, 'results')
today_resdir = file.path(computer_work_path, 'results', today)
now_resdir = file.path(computer_work_path, 'results', today, now)
print(paste('now_resdir :', now_resdir))

### 3.2. Figures  ____________________________________________________
figdir = file.path(computer_work_path, 'figures')
today_figdir = file.path(computer_work_path, 'figures', today)
now_figdir = file.path(computer_work_path, 'figures', today, now)
# if (!(file.exists(now_figdir))) {
#   dir.create(now_figdir, recursive=TRUE)
# }
print(paste('now_figdir :', now_figdir))

### 3.3. Tmp  ________________________________________________________
tmpdir = "tmp"


#  ___                               _                 
# | _ \ __ _  _ _  __ _  _ __   ___ | |_  ___  _ _  ___
# |  _// _` || '_|/ _` || '  \ / -_)|  _|/ -_)| '_|(_-<
# |_|  \__,_||_|  \__,_||_|_|_|\___| \__|\___||_|  /__/ ______________
## 1. ANALYSIS _______________________________________________________
### 1.1. Period ______________________________________________________
# Periods of time to perform analyses
period_diagnostic = c('1976-01-01', '2019-12-31')

### 1.2. Sampling period _____________________________________________
#### 1.2.1 Mode of sampling __________________________________________
# Mode of selection of the hydrological period. Options are : 
# - 'fixed' : Hydrological year is selected with the hydrological year
#             noted in the variable file in 'CARD_dir'
# - 'optimale' : Hydrological period is determined for each station by
#                following rules listed in the next variable.
# samplePeriod_mode =
#     'fixed'
#     # 'optimale'

#### 1.2.2. Optimisation options _____________________________________
# Parameters for the optimal selection of the hydrological year. As
# you can see, the optimisation is separated between each hydrological
# topic. You must therefore select an optimisation for each topic. The
# possibilities are:
# - 'min' or 'max' to choose the month associated with the minimum or
#   maximum of the mean monthly flow as the beginning of the
#   hydrological year.
# - A month and a day separated by a '-' in order to directly select
#   the beginning of the hydrological year.
# - A vector of two months and day to select a beginning and an end of
#   the hydrological year.
# samplePeriod_opti =
#     # NULL
#     list(
#         'Hautes Eaux' = 'min',
#         'Écoulement Lents' = '09-01',
#         'Moyennes Eaux' = 'min',
#         'Basses Eaux' = c('05-01', '11-30')
#     )

### 1.3. Saving ______________________________________________________
# Saving format to use to save analyse data
saving_format =
    c(
        'Rdata',
        'txt'
    )


## 2. PLOTTING  ______________________________________________________
### 2.1. Map _________________________________________________________
#### 2.1.1. Zone _____________________________________________________
zone_to_show = 'France'

#### 2.1.2. Hydrological network _____________________________________
# If the hydrological network needs to be plot
river_selection =
    # 'none'
    c('La Seine$', "'Yonne$", 'La Marne$', 'La Meuse', 'La Moselle$', '^La Loire$', '^la Loire$', '^le cher$', '^La Creuse$', '^la Creuse$', '^La Vienne$', '^la Vienne$', 'La Garonne$', 'Le Tarn$', 'Le Rhône$', 'La Saône$')
    # 'all'

#### 2.1.3. Shapefiles simplification ________________________________
# Tolerance of the simplification algorithm for shapefile in sf
toleranceRel =
    # 1000 # normal map
    10000 # mini map

### 2.2. Foot note ___________________________________________________
# Which logo do you want to show in the footnote
logo_to_show =
    c(
        Explore2='LogoExplore2.png'
    )

### 2.3. Other _______________________________________________________ 
# Graphical selection of period for a zoom
axis_xlim =
    NULL
# c('1982-01-01', '1983-01-01')

# Probability used to define the min and max quantile needed for
# colorbar extremes. For example, if set to 0.01, quartile 1 and
# quantile 99 will be used as the minimum and maximum values to assign
# to minmimal maximum colors.
exXprob = 0.01

propagate_NA = TRUE

nCode4write = 25

verbose =
    FALSE
    # TRUE

document_filename = "Explore2_diagnostic"
pdf_chunk = c('all')


## 3. WHAT YOU WANT TO DO ____________________________________________
### 3.1. Models ______________________________________________________
models_to_diag =
    list(
        "CTRIP"="CTRIP_diagnostic_20230124.nc",
        "EROS"=c("ErosBretagne_20230131.Rdata", "ErosLoire_20230131.Rdata"),
        "GRSD"="GRSD_20230202.Rdata",
        "J2000"="DATA_DIAGNOSTIC_EXPLORE2_J2000.Rdata",
        "SIM2"="Debits_modcou_19580801_20210731_day_METADATA.nc",
        "MORDOR-SD"="MORDOR-SD_20221912.Rdata",
        "MORDOR-TS"="MordorTS_20221213.Rdata",
        # "ORCHIDEE",
        "SMASH"="SMASH_20220921.Rdata"
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

# group_of_models_to_use =
#     # NULL
#     list(
#         # "CTRIP",
#         "EROS",
#         "GRSD",
#         "J2000",
#         "SIM2",
#         "MORDOR-SD",
#         "MORDOR-TS",
#         # "ORCHIDEE",
#         "SMASH",        
#         "Multi-Model"=
#             c("EROS", "J2000", "SIM2",
#               "MORDOR-SD", "MORDOR-TS", "SMASH")
#     )

Colors_of_models = c(
    "CTRIP"="#a88d72", #marron
    "EROS"="#cecd8d", #vert clair
    "GRSD"="#619c6c", #vert foncé
    "J2000"="#74aeb9", #bleur clair
    "SIM2"="#384a54", #bleu foncé
    "MORDOR-SD"="#d8714e", #orange
    "MORDOR-TS"="#ae473e", #rouge
    "ORCHIDEE"="#f5c8c3", #rose
    "SMASH"="#f6ba62" #mimosa    
)

### 3.2. Code ________________________________________________________
code_filenames_to_use =
    # ''
    c(
        # 'all'
        'K2981910_HYDRO_QJM.txt' #ref
        # 'A4362030_HYDRO_QJM.txt'
        # 'WDORON01_HYDRO_QJM.txt',
        # 'WDORON02_HYDRO_QJM.txt',
        # 'WSOULOIS_HYDRO_QJM.txt',
        # 'XVENEON1_HYDRO_QJM.txt',
        # 'XVENEON2_HYDRO_QJM.txt'
        # "X0454010_HYDRO_QJM.txt"
        # '^A'
        # '^H'
        # '^I',
        # '^J'
        # '^K'
        # '^M',
        # '^U'
        # '^V',
        # '^W'
        # '^X'
        # '^Y'
    )

### 3.3. Variables ___________________________________________________
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
# var_to_analyse_dir =
#     # ''
#     # 'AEAG'
#     # 'MAKAHO'
#     'Ex2D'
#     # 'WIP'

analyse_data = c(
    # 'WIP'
    # 'Ex2D/1_indicator/1_all'
    # 'Ex2D/1_indicator/2_selection',
    'Ex2D/2_serie'
)

read_saving = "ALL"

var2search = c(
    'meta',
    'dataEXind',
    'metaEXind',
    'dataEXserie',
    'metaEXserie',
    'Warnings'
)

var_selection =
    # "all"
    c("KGEracine", "Biais$", "epsilon_{T,JJA}", "epsilon_{T,DJF}", "epsilon_{P,JJA}", "epsilon_{P,DJF}", "RAT_T", "Q10", "median{tQJXA}", "alphaQA", "alphaCDC", "Q90", "median{tVCN10}")


### 3.4. Steps _______________________________________________________
# This vector regroups all the different step you want to do. For
# example if you write 'station_extraction', the extraction of the
# data for the station will be done. If you add also
# 'station_analyse', the extraction and then the trend analyse will be
# done. But if you only write, for example, 'station_plot', without
# having previously execute the code with 'station_extraction' and
# 'station_analyse', it will results in a failure.
#
# Options are listed below with associated results after '>' :
#
# - 'station_extraction' : Extraction of data and meta data tibbles
#                          about stations
#                          > 'data' 
#                          > 'df_meta'
#
# - 'station_trend_analyse' : Trend analyses of stations data
#                             > 'df_XEx' : tibble of extracted data
#                             > 'df_Xtrend' : tibble of trend results
#
# - 'station_trend_plot' : Plotting of trend analyses of stations
#    'datasheet' : datasheet of trend analyses for each stations
to_do =
    c(
        # 'delete_tmp'
        # 'create_data'
        # 'analyse_data',
        # 'save_analyse'
        # 'read_tmp'
        # 'read_saving',
        # 'select_var'
        # 'write_warnings'
        'plot'

        # 'create_data_proj'
    )

to_plot =
    c(
        'summary'
        # 'correlation_matrix',
        # 'sheet_diagnostic_station',
        # 'sheet_diagnostic_region',
        # 'sheet_diagnostic_regime'
    )

# library(Rmpi)
# mpi.scatter(x, type, rdata, root=0, comm=1)

#Need 3 slaves to run properly
#Or run mpi.spawn.Rslaves(nslaves=3)
# num="123456789abcd"
# scounts<-c(2,3,1,7)
# mpi.bcast.cmd(strnum<-mpi.scatter(integer(1),type=1,rdata=integer(1),root=0))
# strnum<-mpi.scatter(scounts,type=1,rdata=integer(1),root=0)
# mpi.bcast.cmd(ans <- mpi.scatterv(string(1),scounts=0,type=3,rdata=string(strnum),
# root=0))
# mpi.scatterv(as.character(num),scounts=scounts,type=3,rdata=string(strnum),root=0)
# mpi.remote.exec(ans)




#  ___        _  _    _        _  _            _    _            
# |_ _| _ _  (_)| |_ (_) __ _ | |(_) ___ __ _ | |_ (_) ___  _ _  
#  | | | ' \ | ||  _|| |/ _` || || |(_-</ _` ||  _|| |/ _ \| ' \ 
# |___||_||_||_| \__||_|\__,_||_||_|/__/\__,_| \__||_|\___/|_||_| ____
##### /!\ Do not touch if you are not aware #####
## 0. LIBRARIES ______________________________________________________
# Sets working directory
setwd(computer_work_path)

source('tools.R', encoding='UTF-8')

# Import EXstat
dev_path = file.path(dirname(dirname(computer_work_path)),
                     'EXstat_project', 'EXstat', 'R')
if (file.exists(dev_path)) {
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
dev_path = file.path(dirname(dirname(computer_work_path)),
                     'ASHE_project', 'ASHE', 'R')
if (file.exists(dev_path)) {
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
dev_path = file.path(dirname(dirname(computer_work_path)),
                     'dataSHEEP_project', 'dataSHEEP',
                     "__SHEEP__")
                     # 'Ex2D')
if (file.exists(dev_path)) {
    print('Loading dataSHEEP')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE,
                           recursive=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
}

# Import other library
library(dplyr)
library(ggplot2)
library(scales)
library(qpdf)
library(gridExtra)
library(gridtext)
library(grid)
library(ggh4x)
library(RColorBrewer)
library(rgdal)
library(shadowtext)
library(png)
library(ggrepel)
library(latex2exp)
library(StatsAnalysisTrend)
library(officer)
library(sf)
library(stringr)
library(ggtext)
# already ::
# library(ncdf4)
# library(rgeos)
# library(lubridate)
# library(Hmisc)
# library(accelerometry)
# library(CircStats)
# library(tools)
# library(sp)
# potentialy useless
# library(trend)


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
Subsets = ceiling(nCodeALL/nCode4write)

if (read_tmp | delete_tmp) {
    source('script_management.R', encoding='UTF-8')
}
tmppath = file.path(computer_work_path, tmpdir)
if (!(file.exists(tmppath))) {
    dir.create(tmppath, recursive=TRUE)
}

if (any(c('create_data', 'analyse_data', 'create_data_proj') %in% to_do)) {    
    for (subset in 1:Subsets) {

        file_test = c()
        if ('create_data' %in% to_do) {
            file_test = c(file_test,
                          paste0("data_", subset, ".fst"))
        }
        if (any(grepl("(indicator)|(WIP)", analyse_data))) {
            file_test = c(file_test,
                          paste0("dataEXind_", subset, ".fst"))
        }
        if (any(grepl("serie", analyse_data))) {
            file_test = c(file_test,
                          paste0("dataEXserie_", subset))
        }
        print(paste0(subset, "/", Subsets,
                     " chunks of stations in analyse so ",
                     round(subset/Subsets*100, 1), "%"))
        
        if (all(file_test %in% list.files(tmppath, include.dirs=TRUE))) {
            next
        }
        
        CodeSUB = CodeALL[((subset-1)*nCode4write+1):(subset*nCode4write)]
        CodeSUB = CodeSUB[!is.na(CodeSUB)]
        nCodeSUB = length(CodeSUB)

        if (any(c('create_data', 'create_data_proj') %in% to_do)) {
            source('script_create.R', encoding='UTF-8')
        }
        if (is.null(data)) {
            next
        }
        if ('analyse_data' %in% to_do) {
            source('script_analyse.R', encoding='UTF-8')
        }
    }
}

if (any(c('analyse_data', 'save_analyse', 'select_var', 'write_warnings', 'read_saving') %in% to_do)) {
    source('script_management.R', encoding='UTF-8')
}

if ('plot' %in% to_do) {
    source('script_layout.R', encoding='UTF-8')
}
