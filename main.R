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
# Explore2_toolbox path
lib_path =
    # "./"
    '/home/herautl/library/Explore2_toolbox'


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
#     codes_to_use variable of the ## 1. CREATE_DATA section of the
#     STEPS part below and the model used are selected in the
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

mode =
    # "diag"
    "proj"

to_do =
    c(
        # 'delete_tmp'
        # 'merge_nc'
        'create_data',
        'analyse_data',
        'save_analyse'
        # 'read_tmp'
        # 'read_saving',
        # 'criteria_selection',
        # 'write_warnings'
        # 'plot_sheet'
        # 'plot_doc'
        # 'create_data_proj'
    )

analyse_data =
    c(
        # "WIP"
        # 'Explore2_diag_criteria_all',
        # 'Explore2_diag_criteria_select',
        # 'Explore2_diag_serie'
        # 'Explore2_diag_proj_serie'
        'Explore2_proj_serie',
        'Explore2_proj_check'
        # 'Explore2_proj_delta'
    )


## 3. PLOTTING PROCESSES _____________________________________________
### 3.1. Sheet _______________________________________________________
# The use of this plot_sheet vector is quite similar to the to_do
# vector. It regroups all the different datasheet you want to plot
# individually. For example if you write 'diagnostic_station', the
# data previously analysed saved and read will be use to plot the
# diagnostic datasheet for specific stations.  
#
# Options are listed below with associated results after '>' :
#
# - 'summary' :
#     Plots the summary page of a selection of pages.
#     > figdir/sommaire.pdf
#
# - 'diagnostic_matrix' :
#     Plots diagnostic correlation matrix of every criteria for each
#     model.
#     > figdir/matrice_correlation_J2000.pdf
#
# - 'diagnostic_station' :
#     Plots diagnostic station pages for each station selected.
#     > figdir/K2981910_diagnostic_datasheet.pdf
#
# - 'diagnostic_region' :
#     Plots diagnostic region pages for each hydrological region of
#     available stations.
#     > figdir/Loire_K_diagnostic_datasheet.pdf
#
# - 'diagnostic_regime' :
#     Plots diagnostic regime pages for each hydrological regime of
#     available stations.
#     > figdir/Pluvial_modérément_contrasté_diagnostic_datasheet.pdf

plot_sheet =
    c(
        # 'summary'
        # 'diagnostic_matrix'
        'diagnostic_station'
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


## 4. OTHER __________________________________________________________
# Display information along process
verbose =
    # FALSE
    TRUE
subverbose =
    FALSE
    # TRUE

# Which type of MPI is used
MPI =
    # ""
    "file"
    # "code"


#  ___  _                  
# / __|| |_  ___  _ __  ___
# \__ \|  _|/ -_)| '_ \(_-<
# |___/ \__|\___|| .__//__/ __________________________________________
## 1. CREATE_DATA|_| _________________________________________________ 
period_analyse_diag = c('1976-01-01', '2019-12-31')
period_analyse_proj = c('1975-09-01', '2100-08-31')
propagate_NA = TRUE
nCode4RAM = 15
use_proj_merge =
    TRUE
    # FALSE

projs_to_use =
    c(
        'all'
        # "(rcp26)|(rcp45)|(rcp85")
        # "MPI.*rcp26.*REMO.*CDFt.*MORDOR.*SD"
        # "EARTH.*HadREM3.*ADAMONT.*CTRIP"
        # "HadGEM2.*rcp45.*CCLM.*ADAMONT.*SIM2"
        # "MPI-ESM-LR.*historical.*RegCM4.*CDFt"
        # "ALADIN.*ADAMONT"
        # "rcp26"
        # "EC-EARTH.*rcp26.*HadREM3.*ADAMONT.*CTRIP"
        # "NorESM1-M.*rcp26.*REMO.*ADAMONT"
        # "HadGEM2.*histo.*RegCM4.*CDFt"
    )

models_to_use =
    c(
        # "CTRIP"
        # "EROS"
        # "GRSD"
        # "J2000"
        # "SIM2"
        "MORDOR-SD"
        # "MORDOR-TS"
        # "ORCHIDEE"
        # "SMASH"
    )
complete_by = "SMASH"

codes_to_use =
    # ''
    c(
        'all'
        # 'K2981910' #ref
        # "K221083001",
        # "^R"
        # "^K"
        # 'K1363010',
        # 'V0144010',
        # 'K1341810'
        # "M0014110",
        # "^A"
    )

# existant :
# K0910010
# K2240810
# conversion :
# K0910050 -> K0910010
# K2240820 -> K2240810


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

WIP = 
    list(name='WIP',
         n=2,
         variable="mean{QA}",
         variable_names=NULL,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_diag_criteria_all = 
    list(name='Explore2_diag_criteria_all',
         n=2,
         variable=c("KGE", "KGEracine", "NSE", "NSEracine",
                    "NSElog", "NSEinv", "Biais", "Biais_SEA",
                    "STD", "Rc", "epsilon_P", "epsilon_P,SEA",
                    "epsilon_T", "epsilon_T,SEA", "RAT_T", "RAT_P",
                    "RAT_ET0", "Q10", "QJXA-10", "alphaQJXA",
                    "median{tQJXA}", "median{dtCrue}", "Q50",
                    "mean{QA}", "alphaCDC", "alphaQA", "Q90",
                    "QMNA-5", "VCN30-2", "VCN10-5", "alphaVCN10",
                    "median{tVCN10}", "median{dtRec}", "BFI", "BFM"),
         variable_names=NULL,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_diag_criteria_select =  
    list(name='Explore2_diag_criteria_select',
         n=2,
         variable=c("KGEracine", "Biais", "epsilon_T,DJF",
                    "epsilon_T,JJA", "epsilon_P,DJF", "epsilon_P,JJA",
                    "RAT_T", "RAT_P", "Q10", "median{tQJXA}",
                    "alphaCDC", "alphaQA", "Q90", "median{tVCN10}"),
         variable_names=NULL,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_diag_serie = 
    list(name='Explore2_diag_serie',
         n=2,
         variable=c("QM", "PA", "QA", "median{QJ}",
                    "median{QJ}C5", "FDC"),
         variable_names=NULL,
         cancel_lim=TRUE,
         simplify=FALSE)

Explore2_diag_proj_serie =
    list(name='Explore2_diag_proj_serie',
         n=1,
         variable=c("QA", "QA_janv", "QA_fevr", "QA_mars", "QA_avr",
                    "QA_mai", "QA_juin", "QA_juill", "QA_aout",
                    "QA_sept", "QA_oct", "QA_nov", "QA_dec", "QA_DJF",
                    "QA_MAM", "QA_JJA", "QA_SON", "QA05", "QA10",
                    "QA50", "QA90", "QA95", "QJXA", "VCX3", "QMNA",
                    "VCN10", "VCN3"),
         variable_names=c(Q="Q_obs"),
         cancel_lim=TRUE,
         simplify=FALSE)

Explore2_proj_serie =
    list(name='Explore2_proj_serie',
         n=1,
         variable=c("QA", "QA_janv", "QA_fevr", "QA_mars", "QA_avr",
                    "QA_mai", "QA_juin", "QA_juill", "QA_aout",
                    "QA_sept", "QA_oct", "QA_nov", "QA_dec", "QA_DJF",
                    "QA_MAM", "QA_JJA", "QA_SON", "QA05", "QA10",
                    "QA50", "QA90", "QA95", "QJXA", "VCX3", "QMNA",
                    "VCN10", "VCN3"),
         variable_names=c(Q="Q_sim"),
         cancel_lim=FALSE,
         simplify=FALSE)

Explore2_proj_check = 
    list(name='Explore2_proj_check',
         n=1,
         variable=c("tQJXA", "tCEN_etiage_check"),
         variable_names=c(Q="Q_sim"),
         cancel_lim=FALSE,
         simplify=FALSE)

Explore2_proj_delta =
    list(name='Explore2_proj_delta',
         n=1,
         variable="deltaQA",
         variable_names=c(Q="Q_sim"),
         cancel_lim=FALSE,
         simplify=TRUE)


## 3. SAVE_ANALYSE ___________________________________________________
# If one input file need to give one output file
by_files =
    TRUE
    # FALSE

var2save =
    c(
        'meta',
        # 'data',
        'dataEX',
        'metaEX'
    )

# Saving format to use to save analyse data
saving_format =
    ""
    # c('Rdata', 'txt')

wait =
    NULL
    # 1

## 4. READ_SAVING ____________________________________________________
read_saving =
    "diag/"
    # "proj/SMASH/CNRM-CM5_historical_ALADIN63_ADAMONT_SMASH"

var2search =
    c(
        'meta',
        'data',
        'dataEX',
        'metaEX',
        'Warnings'
    )


# ## 5. CRITERIA_SELECTION _____________________________________________
# criteria_selection =
#     # "all"
#     c("KGEracine", "Biais$", "epsilon_{T,JJA}", "epsilon_{T,DJF}", "epsilon_{P,JJA}", "epsilon_{P,DJF}", "RAT_T", "RAT_P", "Q10", "median{tQJXA}", "^alphaQA", "^alphaCDC", "Q90", "median{tVCN10}")


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
    "MORDOR-SD"="#d8714e", #orange
    "MORDOR-TS"="#ae473e", #rouge
    "ORCHIDEE"="#efa59d", #rose #f5c8c3
    "SIM2"="#384a54", #bleu foncé
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
                     "R")
if (any(file.exists(dev_path))) {
    print('Loading dataSHEEP')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE,
                           recursive=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
}

# Import SHEEPfold
dev_path = file.path(dev_lib_path,
                     c('', 'SHEEPfold_project'), 'SHEEPfold',
                     "__SHEEP__")
if (any(file.exists(dev_path))) {
    print('Loading SHEEPfold')
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
library(gridtext)
library(ggh4x)
require(rgdal)
library(shadowtext)
library(png)
library(ggrepel)
library(latex2exp)
require(sf) #nope
library(stringr)
library(ggtext)
# already ::
# library(tidyr)
# library(grid)
# library(ncdf4)
# library(rgeos)
# library(lubridate)
# library(sp)
# library(fst)


if (MPI != "") {
    library(Rmpi)
    rank = mpi.comm.rank(comm=0)
    size = mpi.comm.size(comm=0)
} else {
    rank = 0
    size = 1
}

apply_grepl = function (x, table, target=NULL) {
    if (is.null(target)) {
        target = table
    }
    return (target[grepl(x, table)])
}

apply_match = function (x, table, target=NULL) {
    if (is.null(target)) {
        target = table
    }
    return (target[match(x, table)])
}

apply_bra = function (id, target) {
    return (target[id])
}

convert2bool = function (X, true) {
    ok = X == true
    X[ok] = TRUE
    X[!ok] = FALSE
    return (X)
}

if (mode == "diag") {
    period_analyse = period_analyse_diag
} else if (mode == "proj") {
    period_analyse = period_analyse_proj
}

if (!(file.exists(resources_path)) & rank == 0) {
  dir.create(resources_path)
}

delete_tmp = FALSE
merge_nc = FALSE
read_tmp = FALSE

analyse_data_tmp = lapply(analyse_data, get)
names(analyse_data_tmp) = analyse_data
analyse_data = analyse_data_tmp


if ('plot_doc' %in% to_do) {
    plot_doc = get(paste0("doc_", plot_doc[1]))
}

if (mode == "proj") {
    projs_selection_data = read_tibble(file.path(computer_data_path,
                                                 projs_selection_file))  
    EXP = c("historical", 'rcp26', 'rcp45', 'rcp85')
    names(projs_selection_data)[3:6] = EXP
    projs_selection_data =
        dplyr::mutate(projs_selection_data,
                      dplyr::across(.cols=EXP,
                                    .fns=convert2bool, true="x"))
    projs_selection_data =
        tidyr::pivot_longer(data=projs_selection_data,
                            cols=EXP,
                            names_to="EXP")
    projs_selection_data$value = as.logical(projs_selection_data$value)
    projs_selection_data = dplyr::filter(projs_selection_data, value)
    projs_selection_data = dplyr::select(projs_selection_data, -"value")

    BC = c("ADAMONT", "CDFt")
    projs_selection_data = tidyr::crossing(projs_selection_data,
                                           BC, Model=models_to_use)
    projs_selection_data$ID =
        paste0(projs_selection_data$GCM, "|",
               projs_selection_data$EXP, "|",
               projs_selection_data$RCM, "|",
               projs_selection_data$BC, "|",
               projs_selection_data$Model)
    
    projs_selection_data$regexp =
        paste0(".*", 
               gsub("[|]", ".*", projs_selection_data$ID),
               ".*")
    projs_selection_data$regexp = gsub("[-]", "[-]",
                                       projs_selection_data$regexp)
    projs_selection_data$regexp = gsub("[_]", "[_]",
                                       projs_selection_data$regexp)
    
    if (use_proj_merge) {
        proj_path = file.path(computer_data_path,
                               proj_merge_dir)
        projs_selection_data =
            projs_selection_data[projs_selection_data$EXP !=
                                 "historical",]
    } else {
        proj_path = file.path(computer_data_path, proj_dir)
    }    

    Paths = list.files(proj_path,
                       pattern=".*[.]nc",
                       include.dirs=FALSE,
                       full.names=TRUE,
                       recursive=TRUE)
    Files = basename(Paths)
    
    any_grepl = function (pattern, x) {
        any(grepl(pattern, x))
    }
    projs_selection_data =
        projs_selection_data[sapply(projs_selection_data$regexp,
                                    any_grepl,
                                    x=Files),]
    projs_selection_data$file =
        lapply(projs_selection_data$regexp, apply_grepl, table=Files)
    projs_selection_data$path =
        lapply(projs_selection_data$file,
               apply_match, table=Files, target=Paths)
    
    projs_selection_data_nest = projs_selection_data
    projs_selection_data = tidyr::unnest(projs_selection_data,
                                         c(file, path))

    if (all(projs_to_use != "all")) {
        OK = apply(sapply(projs_to_use, grepl,
                          x=projs_selection_data$regexp),
                   1, any)
        projs_selection_data = projs_selection_data[OK,]
        OK_nest = apply(sapply(projs_to_use, grepl,
                               x=projs_selection_data_nest$regexp),
                        1, any)
        projs_selection_data_nest = projs_selection_data_nest[OK_nest,]
    }

    files_to_use = projs_selection_data_nest$path
    names(files_to_use) = projs_selection_data_nest$ID

    write_tibble(dplyr::select(projs_selection_data,
                               -"path"),
                 filedir=today_resdir,
                 filename="projs_selection.txt")
    
} else if (mode == "diag") { #####
    diag_path = file.path(computer_data_path, diag_dir)
    models_to_use_name = models_to_use
    models_path = list.files(file.path(computer_data_path, diag_dir),
                             full.names=TRUE)
    models_file = basename(models_path)
    files_to_use = lapply(models_to_use, apply_grepl,
                          table=models_file, target=models_path)
    names(files_to_use) = models_to_use_name
}

nFiles_to_use = length(files_to_use)



codes_selection_data = read_tibble(file.path(computer_data_path,
                                             codes_selection_file))
codes_selection_data = dplyr::filter(codes_selection_data,
                                     !grepl("Supprimer", X))

if (mode == "diag") {
    ref = 1
} else if (mode == "proj") {
    ref = c(0, 1)
}
codes_selection_data =
    codes_selection_data[codes_selection_data$Référence %in% ref,]
codes8_selection = codes_selection_data$CODE
codes10_selection = codes_selection_data$SuggestionCode
codes8_selection = codes8_selection[!is.na(codes8_selection)]
codes10_selection = codes10_selection[!is.na(codes10_selection)]

if (all(codes_to_use == "")) {
    stop ("No station selected")
}
if (all(codes_to_use == "all")) {
    CodeALL8 = codes8_selection
    CodeALL10 = convert_code8to10(codes8_selection)
} else {
    codes_to_use[nchar(codes_to_use) == 10] =
        codes8_selection[codes10_selection %in%
                         codes_to_use[nchar(codes_to_use) == 10]]
    
    codes_to_use = convert_regexp(computer_data_path,
                                  obs_dir,
                                  codes_to_use,
                                  obs_format)
    
    okCode = codes_to_use %in% codes8_selection
    CodeALL8 = codes_to_use[okCode]
    # CodeALL10 = codes10_selection[codes8_selection %in% CodeALL8]
    CodeALL10 = convert_code8to10(CodeALL8)
}
CodeALL8 = CodeALL8[nchar(CodeALL8) > 0]
CodeALL10 = CodeALL10[nchar(CodeALL10) > 0]
nCodeALL = length(CodeALL10)


if (MPI != "") {
    tmppath = file.path(computer_work_path,
                        paste0(tmpdir,
                               "_",
                               paste0(models_to_use,
                                      collapse="_"))) #########################################################
} else {
    tmppath = file.path(computer_work_path, tmpdir)
}


if ("delete_tmp" %in% to_do) {
    delete_tmp = TRUE
    to_do = to_do[to_do != "delete_tmp"]
    post("## MANAGING DATA")
    source(file.path(lib_path, 'script_management.R'),
           encoding='UTF-8')
}

if (!(file.exists(tmppath)) & rank == 0) {
    dir.create(tmppath, recursive=TRUE)
}

if ("merge_nc" %in% to_do) {
    merge_nc = TRUE
    to_do = to_do[to_do != "merge_nc"]
    post("## MANAGING DATA")
    source(file.path(lib_path, 'script_management.R'),
           encoding='UTF-8')
}

if (any(c('create_data', 'analyse_data', 'save_analyse') %in% to_do)) {

    if (all(c('create_data', 'analyse_data') %in% to_do)) {
        post("## CREATING AND ANALYSING DATA")
    } else if ('create_data' %in% to_do) {
        post("## CREATING DATA")
    } else if ('analyse_data' %in% to_do) {
        post("## ANALYSING DATA")
    } else if (!('save_analyse' %in% to_do)) {
        post("Maybe you can start by creating data")
    }

    timer = dplyr::tibble()

    firstLetterALL = substr(CodeALL10, 1, 1)
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
        while (id+nCode4RAM-1 < Id) {
            Subsets = append(Subsets, list(c(id, id+nCode4RAM-1)))
            names(Subsets)[length(Subsets)] = paste0(name, n)
            id = id+nCode4RAM
            n = n+1
        }
        Subsets = append(Subsets, list(c(id, Id)))
        names(Subsets)[length(Subsets)] = paste0(name, n)
    }
    nSubsets = length(Subsets)

    if (by_files | MPI == "file") {
        if (MPI == "file") {
            start = ceiling(seq(1, nFiles_to_use,
                                by=(nFiles_to_use/size)))
            if (any(diff(start) == 0)) {
                start = 1:nFiles_to_use
                end = start
            } else {
                end = c(start[-1]-1, nFiles_to_use)
            }
            if (rank == 0) {
                post(paste0(paste0("rank ", 0:(size-1), " get ",
                                   end-start+1, " files"),
                            collapse="    "))
            }
            if (rank+1 > nFiles_to_use) {
                Files = NULL
            } else {
                Files = files_to_use[start[rank+1]:end[rank+1]]
            }
            
        } else {
            Files = files_to_use
        }
        Files_name = names(Files)
        Files_len = sapply(Files, length)
        names(Files_len) = NULL
        Files_name = Map(rep, x=Files_name, each=Files_len)
        names(Files) = NULL
        names(Files_name) = NULL
        Files = as.list(Files)
        Files_name = as.list(Files_name)
        
    } else {
        Files = files_to_use
        Files_name = names(Files)
        Files_len = sapply(Files, length)
        names(Files_len) = NULL
        Files_name = Map(rep, x=Files_name, each=Files_len)
        names(Files) = NULL
        names(Files_name) = NULL
        Files = list(Files)
        Files_name = list(Files_name)
    }
    nFiles = length(Files)

    Subsets_save = Subsets
    nSubsets_save = nSubsets
    if (MPI == "code") {
        Subsets = Subsets[rank+1]
        Subsets = Subsets[!is.na(names(Subsets))]
        nSubsets = length(Subsets)

        if (nSubsets == 0) {
            Rmpi::mpi.send(as.integer(1), type=1, dest=0, tag=1, comm=0)
            post(paste0("End signal from rank ", rank)) 
        }
    }

    post(paste0("All ", nFiles, " files: ",
                paste0(names(Files), collapse=" ")))

    if (nFiles != 0 & nSubsets != 0) {
        for (ff in 1:nFiles) {
            files = Files[[ff]]
            files_name = Files_name[[ff]]
            if (by_files | MPI == "file") {
                files_name_opt = gsub("[|]", "_", files_name[1]) #####
                files_name_opt. = paste0(files_name_opt, "_")
                .files_name_opt. = paste0("_", files_name_opt, "_")
                .files_name_opt = paste0("_", files_name_opt)
            } else {
                files_name_opt = ""
                files_name_opt. = ""
                .files_name_opt. = ""
                .files_name_opt = ""
            }
            
            Create_ok = c()
            
            for (ss in 1:nSubsets) {
                subset = Subsets[[ss]]
                subset_name = names(Subsets)[ss]

                post(paste0("For subset ", files_name_opt.,
                            subset_name, ": ",
                            paste0(subset, collapse=" -> ")))
                
                file_test = c()
                if ('create_data' %in% to_do & "data" %in% var2save) {
                    file_test = c(file_test,
                                  paste0("data_",
                                         files_name_opt.,
                                         subset_name, ".fst"))
                }
                if ('analyse_data' %in% to_do) {
                    for (aa in 1:length(analyse_data)) {
                        analyse = analyse_data[[aa]]
                        
                        if (analyse$simplify) {
                            file_test = c(file_test,
                                          paste0("dataEX_",
                                                 analyse$name,
                                                 "_", files_name_opt.,
                                                 subset_name, ".fst"))
                        } else {
                            file_test = c(file_test,
                                          paste0("dataEX_",
                                                 analyse$name,
                                                 "_", files_name_opt.,
                                                 subset_name))
                        }
                    }
                }
                
                post(paste0(ss, "/", nSubsets,
                            " chunks of stations in analyse so ",
                            round(ss/nSubsets*100, 1), "% done"))
                
                if (all(file_test %in% list.files(tmppath,
                                                  include.dirs=TRUE))) {
                    Create_ok = c(Create_ok, TRUE)
                    gc()
                    next
                }
                
                CodeSUB8 = CodeALL8[subset[1]:subset[2]]
                CodeSUB8 = CodeSUB8[!is.na(CodeSUB8)]
                CodeSUB10 = CodeALL10[subset[1]:subset[2]]
                CodeSUB10 = CodeSUB10[!is.na(CodeSUB10)]
                nCodeSUB = length(CodeSUB10)

                if ('create_data' %in% to_do) {
                    timer = start_timer(timer, rank, "create",
                                        paste0(files_name_opt.,
                                               subset_name))
                    source(file.path(lib_path, 'script_create.R'),
                           encoding='UTF-8')
                    timer = stop_timer(timer, rank, "create",
                                       paste0(files_name_opt.,
                                              subset_name))
                }        
                if (create_ok) {
                    if ('analyse_data' %in% to_do) {
                        timer = start_timer(timer, rank, "analyse",
                                            paste0(files_name_opt.,
                                                   subset_name))
                        source(file.path(lib_path, 'script_analyse.R'),
                               encoding='UTF-8')
                        timer = stop_timer(timer, rank, "analyse",
                                           paste0(files_name_opt.,
                                                  subset_name))
                    }
                }
                Create_ok = c(Create_ok, create_ok)
                gc()
                print("")
            }

            if (any(Create_ok)) {
                if (any(c('analyse_data', 'save_analyse') %in% to_do)) {
                    post("## MANAGING DATA")
                    timer = start_timer(timer, rank, "save",
                                        paste0(files_name_opt.,
                                               subset_name))
                    source(file.path(lib_path, 'script_management.R'),
                           encoding='UTF-8')
                    timer = stop_timer(timer, rank, "save",
                                       paste0(files_name_opt.,
                                              subset_name))
                }
            }
            print("")
        }
        
    } else {
        warning ("No files")
    }

    timer$time = timer$stop - timer$start
    write_tibble(timer, tmppath,
                 paste0("timer_", rank , ".fst"))

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

        timer = dplyr::tibble()
        for (root in 0:(size-1)) {
            path = file.path(tmppath, paste0("timer_", root , ".fst"))
            if (file.exists(path)) {
                timer_tmp = read_tibble(path)
                timer = dplyr::bind_rows(timer, timer_tmp)
            }
        }
        write_tibble(timer, today_resdir, "timer.txt")
        
    } else if (MPI == "file") {
        Rmpi::mpi.send(as.integer(1), type=1, dest=0, tag=1, comm=0)
        post(paste0("End signal from rank ", rank)) 

    } else {
        write_tibble(timer, today_resdir, "timer.txt")
    }
}

if (any(c('criteria_selection', 'write_warnings',
          'read_saving') %in% to_do)) {
    post("## MANAGING DATA")
    source(file.path(lib_path, 'script_management.R'),
           encoding='UTF-8')
}

if ("read_tmp" %in% to_do) {
    read_tmp = TRUE
    to_do = to_do[to_do != "read_tmp"]
    post("## MANAGING DATA")
    source(file.path(lib_path, 'script_management.R'),
           encoding='UTF-8')
}

if (any(c('plot_sheet', 'plot_doc') %in% to_do)) {
    post("## PLOTTING DATA")
    source(file.path(lib_path, 'script_layout.R'),
           encoding='UTF-8')
}

# print(sort(sapply(ls(), function(x) {    
    # object.size(get(x))})))



# FILES = c()
# for (rank in 0:(size-1)) {
#     start = ceiling(seq(1, nFiles_to_use,
#                         by=(nFiles_to_use/size)))
#     end = c(start[-1]-1, nFiles_to_use)
#     if (rank == 0) {
#         post(paste0(paste0("rank ", 0:(size-1), " get ",
#                            end-start+1, " files"),
#                     collapse="    "))
#     }
#     Files = files_to_use[start[rank+1]:end[rank+1]]
#     FILES = c(FILES, Files)
# }

# length(files_to_use)
# length(FILES)
# names(files_to_use)[!(names(files_to_use) %in% names(FILES))]

# [1] "IPSL-CM5A-MR|rcp85|RCA4|CDFt|EROS"   
# [2] "MPI-ESM-LR|rcp26|REMO|CDFt|MORDOR-SD"
