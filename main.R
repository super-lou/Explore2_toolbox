# \\\
# Copyright 2021-2022 Louis Héraut*1,
#                     Éric Sauquet*2
#
# *1   INRAE, France
#      louis.heraut@inrae.fr
# *2   INRAE, France
#      eric.sauquet@inrae.fr
#
# This file is part of Ex2D R toolbox.
#
# Ex2D R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ex2D R toolbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ex2D R toolbox.
# If not, see <https://www.gnu.org/licenses/>.
# ///
#
#
# main.R
#
# Main script that regroups all command lines needed to interact with
# this toolbox. Choose your parameters before executing all the script
# (RStudio : Ctrl+Alt+R) or line by line.


#  ___         __                         _    _                
# |_ _| _ _   / _| ___  _ _  _ __   __ _ | |_ (_) ___  _ _   ___
#  | | | ' \ |  _|/ _ \| '_|| '  \ / _` ||  _|| |/ _ \| ' \ (_-<
# |___||_||_||_|  \___/|_|  |_|_|_|\__,_| \__||_|\___/|_||_|/__/ _____
#
# If you want to contact the author of the code you need to contact
# first Louis Héraut who is the main developer. If it is not possible,
# Éric Sauquet is the main referent at INRAE to contact.
#
# Louis Héraut : <louis.heraut@inrae.fr>
# Éric Sauquet : <eric.sauquet@inrae.fr>
#
# See the 'README.txt' file for more information about the utilisation
# of this toolbox.


#  _   _                  ___              __  _       
# | | | | ___ ___  _ _   / __| ___  _ _   / _|(_) __ _ 
# | |_| |(_-</ -_)| '_| | (__ / _ \| ' \ |  _|| |/ _` |
#  \___/ /__/\___||_|    \___|\___/|_||_||_|  |_|\__, | ______________
## You can modify this part without risk ##      |___/ 

## 1. WORKING DIRECTORY ______________________________________________
# Work path (it normally needs to end with '\\ashes' directory)
computer_work_path = 
    '/home/louis/Documents/bouleau/INRAE/project/Ex2D_project/Ex2D_toolbox'

## 2. DATA DIRECTORY _________________________________________________
# Data path (it normally needs to end with '\\ashes' directory)
data_path = 
    '/home/louis/Documents/bouleau/INRAE/project/Ex2D_project/Ex2D_toolbox'

# Directory of Banque HYDRO data you want to use in ash\\data\\ to
# extract stations flow data. If '' is use, data will be search in
# ash\\data\\.
filedir =
    # ''
    # 'AEAG_selection'
    'RRSE'

# Name of the files that will be analysed from the data directory
# (if 'all', all the file of the directory will be chosen)
filename =
    # ''
    'all'
    # c(
        # 'X0500010_HYDRO_QJM.txt'
        # 'Q0214010_HYDRO_QJM.txt',
        # 'H7833520_HYDRO_QJM.txt',
        # 'O0384010_HYDRO_QJM.txt',
        # 'O3314010_HYDRO_QJM.txt',
        # 'S2235610_HYDRO_QJM.txt',
        # 'O1484320_HYDRO_QJM.txt',
        # 'O0362510_HYDRO_QJM.txt'
        # 'A3301010_HYDRO_QJM.txt',
        # 'A4050620_HYDRO_QJM.txt'
        # '^[A]'
    # )

## 3. WHAT YOU WANT TO DO ____________________________________________
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
to_do =
    c(
        'station_extraction',
        'station_trend_analyse',
        'station_trend_plot'
    )

## 4. ANALYSIS PARAMETERS ____________________________________________
# Periods of time to perform the trend analyses
period =
    # c('1968-01-01', '2020-12-31')
    c('1900-01-01', '2020-12-31')


#    _       _                               _ 
#   /_\   __| |__ __ __ _  _ _   __  ___  __| |
#  / _ \ / _` |\ V // _` || ' \ / _|/ -_)/ _` |
# /_/ \_\\__,_| \_/ \__,_||_||_|\__|\___|\__,_| ______________________
## You still can modify this part without major risk but it can be ##
## less intuitive ##                                          

## 1. FILES STRUCTURE _________________________________________________
### 1.1. Input directories ___________________________________________
# Path to the data
computer_data_path = file.path(computer_work_path, 'data')

# Resources directory
resources_path = file.path(computer_work_path, 'resources')
if (!(file.exists(resources_path))) {
  dir.create(resources_path)
}
print(paste('resources_path :', resources_path))

# Logo filename
logo_dir = 'logo'
PRlogo_file = 'logo_Prefet_bassin.png'
AEAGlogo_file = 'agence-de-leau-adour-garonne_logo.png'
INRAElogo_file = 'Logo-INRAE_Transparent.png'
FRlogo_file = 'Republique_Francaise_RVB.png'

shp_dir = 'map'
# Path to the shapefile for france contour from 'computer_data_path' 
fr_shpdir = file.path(shp_dir, 'france')
fr_shpname = 'gadm36_FRA_0.shp'

# Path to the shapefile for basin shape from 'computer_data_path' 
bs_shpdir = file.path(shp_dir, 'bassin')
bs_shpname = 'BassinHydrographique.shp'

# Path to the shapefile for sub-basin shape from 'computer_data_path' 
sbs_shpdir = file.path(shp_dir, 'sous_bassin')
sbs_shpname = 'SousBassinHydrographique.shp'

# Path to the shapefile for station basins shape from 'computer_data_path' 
cbs_shpdir = file.path(shp_dir, 'bassin_station')
cbs_shpname = c('BV_4207_stations.shp', '3BVs_FRANCE_L2E_2018.shp')
cbs_coord = c('L93', 'L2')

# Path to the shapefile for river shape from 'computer_data_path' 
rv_shpdir = file.path('map', 'river')
rv_shpname = 'CoursEau_FXX.shp'

### 1.2. Output directories __________________________________________
# Result directory
resdir = file.path(computer_work_path, 'results')
if (!(file.exists(resdir))) {
  dir.create(resdir)
}
print(paste('resdir :', resdir))

# Result sub directory
modified_data_dir = 'modified_data'
trend_dir = 'trend_analyses'

# Figure directory
figdir = file.path(computer_work_path, 'figures')
if (!(file.exists(figdir))) {
  dir.create(figdir)
}
print(paste('figdir :', figdir))


## 3. DATA CORRECTION ________________________________________________
# Local corrections of the data
df_flag = NULL


## 4. ANALYSED VARIABLES _____________________________________________
### 4.1. Hydrological variables ______________________________________
# Name of the directory that regroups all variables information
CARD_dir = file.path(gsub("[/]project[_].*$", "", getwd()),
                    "CARD_project",
                    "CARD")
# Name of the tool directory that includes all the functions needed to
# calculate a variable
init_tools_dir = '__tools__'
# Name of the default parameters file for a variable
init_var_file = '__default__.R'


# Name of the subdirectory in 'CARD_dir' that includes variables to
# analyse. If no subdirectory is selected, all variable files will be
# used in 'CARD_dir' (which is may be too much).
# This subdirectory can follows some rules :
# - Variable files can be rename to began with a number followed by an
#   underscore '_' to create an order in variables. For example,
#   '2_QA.R' will be analysed and plotted after '1_QMNA.R'.
# - Directory of variable files can also be created in order to make a
#   group of variable of similar event. Names should be chosen between
#   'Crue'/'Crue Nivale'/'Moyennes Eaux' and 'Étiage'. A directory can
#   also be named 'Resume' in order to not include variables in an
#   event group.
var_to_analyse_dir =
    # ''
    # 'AEAG'
    # 'MAKAHO'
    # 'Ex2D'
    'WIP'


## 5. STATISTICAL OPTIONS ____________________________________________
# The risk of the Mann-Kendall trend detection test
level = 0.1

# Mode of selection of the hydrological period. Options are : 
# - 'every' : Each month will be use one by one as a start of the
#             hydrological year
# - 'fixed' : Hydrological year is selected with the hydrological year
#             noted in the variable file in 'CARD_dir'
# - 'optimale' : Hydrological period is determined for each station by
#                following rules listed in the next variable.
samplePeriod_mode =
    # 'every'
    'fixed'
    # 'optimale'

# Parameters for the optimal selection of the hydrological year. As
# you can see, the optimisation is separated between each hydrological
# event. You must therefore select an optimisation for each event. The
# possibilities are:
# - 'min' or 'max' to choose the month associated with the minimum or
#   maximum of the mean monthly flow as the beginning of the
#   hydrological year.
# - A month and a day separated by a '-' in order to directly select
#   the beginning of the hydrological year.
# - A vector of two months and day to select a beginning and an end of
#   the hydrological year.
samplePeriod_opti = list(
    'Crue' = 'min',
    'Crue Nivale' = '09-01',
    'Moyennes Eaux' = 'min',
    'Étiage' = c('05-01', '11-30')
)


## 6. READING AND WRITING OF RESULTS _________________________________
### 6.1. Reading _____________________________________________________
# If you want to read results that have already been saved
read_results = FALSE

### 6.2. Writing data on RAM _________________________________________
# If you want to save on RAM all the results or not. If no option is
# selected, only the last results will be stored on RAM (because
# results are overwrites each time in order  to save place).
# Variable names stored will be :
# - 'df_Xdata' : Modified flow data for every station
# - 'df_Xmod' : Historic of modification of flow data
# - 'df_XEx' : Extracted data
# - 'df_Xtrend' : Trend results
# - 'res_Xanalyse' : List of 'df_XEx' and 'df_Xtrend'
# Otherwise, if you select 'modified_data', only 'df_Xdata' and
# 'df_Xmod' will be save under the same name with 'X'replaced by the
# corresponding variable name. And similarly, if 'analyse' is
# selected, only 'df_XEx', 'df_Xtrend' and 'res_Xanalyse' are saved
# for each variable.
to_assign_out = c(
    # 'modified_data',
    # 'analyse'
)

### 6.3. Writing data on disc ________________________________________
# It is possible to save the data under txt files.
# Options are :
# - 'meta' : saves 'df_meta' the data frame of meta informations
# - 'modified_data' : saves modified 'data' data frame that take
#   corrections into account
# - 'analyse' : saves results of the trend analyse
saving = c(
    # 'meta',
    # 'modified_data',
    # 'analyse'
)

# If TRUE, data will be saved in 'fst' which is a fast format otherwise the default format is 'txt'
fast_format = TRUE

### 6.4. Writing figure ______________________________________________
# How the pdf will be constructed. If you choose 'by_code', a pdf will
# be save for each station. Otherwise, if you choose 'all', every
# figure will be saved as one pdf.
pdf_chunk =
    'by_code'
    # 'all'


## 7. PLOTTING PARAMETERS ____________________________________________
### 7.1. What do you want to plot ____________________________________
# What you want to be plotted for station analyses. For example if 'datasheet' is wrote, datasheet about each stations will be drawn.
# All the option are :
#    'datasheet' : datasheet of trend analyses for each stations
#        'table' : summarizing table about trend analyses
#          'map' : map about trend analyses
to_plot_station =
    c(
        # 'summary',
        'datasheet'
        # 'table'
        # 'map'
        # 'map_regime'
        # 'map_trend'
        # 'map_mean'
    )

### 7.2. What do you want to show ____________________________________
# Do you want to show small insert of color based on the studied
# event in the upper left corner of datasheet
show_colorEvent = TRUE

# Which part of the globe do you want to show in the datasheet
# mini map
zone_to_show =
    'France'
    # 'Adour-Garonne'

# If the hydrological network needs to be plot
river_selection =
    # 'none'
    c('La Seine$', "'Yonne$", 'La Marne$', 'La Meuse', 'La Moselle$', '^La Loire$', '^la Loire$', '^le cher$', '^La Creuse$', '^la Creuse$', '^La Vienne$', '^la Vienne$', 'La Garonne$', 'Le Tarn$', 'Le Rhône$', 'La Saône$')
    # 'all'

# Which logo do you want to show in the footnote
logo_to_show =
    c(
        # 'PR',
        'FR',
        'INRAE'
        # 'AEAG'
    )

### 7.3. Other _______________________________________________________
# Tolerance of the simplification algorithm for shapefile in sf
toleranceRel =
    # 1000 # normal map
    10000 # mini map
    
# Graphical selection of period for a zoom
axis_xlim =
    NULL
# c('1982-01-01', '1983-01-01')

# Probability used to define the min and max quantile needed for
# colorbar extremes. For example, if set to 0.01, quartile 1 and
# quantile 99 will be used as the minimum and maximum values to assign
# to minmimal maximum colors.
exXprob = 0.01


#  ___              ___             _   
# |   \  ___ __ __ | _ \ __ _  _ _ | |_ 
# | |) |/ -_)\ V / |  _// _` || '_||  _|
# |___/ \___| \_/  |_|  \__,_||_|   \__| _____________________________
## /!\ Do not touch if you are not aware ##

## 0. INITIALISATION _________________________________________________
# Sets working directory
setwd(computer_work_path)

# Import MKstat
dev_path = file.path(dirname(dirname(computer_work_path)),
                     'MKstat_project', 'MKstat', 'R')
if (file.exists(dev_path)) {
    print('Loading MKstat from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading MKstat from package')
    library(MKstat)
}

# Import ashes
dev_path = file.path(dirname(dirname(computer_work_path)),
                     'ashes_project', 'ashes', 'R')
if (file.exists(dev_path)) {
    print('Loading ashes from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading ashes from package')
    library(ashes)
}

# Import dataSheep
dev_path = file.path(dirname(dirname(computer_work_path)),
                     'dataSheep_project', 'dataSheep', 'R')
if (file.exists(dev_path)) {
    print('Loading dataSheep from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading dataSheep from package')
    library(dataSheep)
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
# already ::
# library(rgeos)
# library(lubridate)
# library(Hmisc)
# library(accelerometry)
# library(CircStats)
# library(tools)
# library(sp)
# potentialy useless
# library(trend)

# Creates list of period for trend analysis
trend_period = NULL
if (!is.null(periodAll)) {
    trend_period = append(trend_period, list(periodAll))
}
if (!is.null(periodSub)) {
    trend_period = append(trend_period, list(periodSub))
}
# Creates list of period for average analysis
mean_period = NULL
if (!is.null(periodRef)) {
    mean_period = append(mean_period, list(periodRef))
}
if (!is.null(periodCur)) {
    mean_period = append(mean_period, list(periodCur))
}

input_trend_period = sapply(trend_period, paste, collapse='/')


## 1. EXTRACTION _____________________________________________________
if ('station_extraction' %in% to_do | 'climate_extraction' %in% to_do) {
    print('EXTRACTION')
    source('script_extract.R', encoding='UTF-8')
}

## 2. ANALYSES _______________________________________________________
if ('station_trend_analyse' %in% to_do | 'station_break_analyse' %in% to_do | 'climate_trend_analyse' %in% to_do) {
    print('ANALYSES')
    source('script_analyse.R', encoding='UTF-8')
}

## 3. PLOTTING _______________________________________________________
if ('station_serie_plot' %in% to_do | 'station_trend_plot' %in% to_do | 'station_break_plot' %in% to_do | 'climate_trend_plot' %in% to_do) {
    print('PLOTTING')
    source('script_layout.R', encoding='UTF-8')
}







## 2. DATA IMPORTATION _______________________________________________
# dataJ2K_file = "DATA_DIAGNOSTIC_EXPLORE2_J2000_v0.Rdata"
# dataJ2K_path = file.path(data_dir, dataJ2K_file)
# dataJ2K = loadRData(dataJ2K_path)
# dataJ2K = convert_J2K(dataJ2K)

# dataSMASH_file = "SMASH_20220921.Rdata"
# dataSMASH_path file.path(data_dir, dataSMASH_file)
# dataSMASH = loadRData(dataSMASH_path)

# dataSIM2_file = "Debits_modcou_19580801_20210731_day_METADATA.nc"
# dataSIM2_path = file.path(data_dir, dataSIM2_file)
# dataSIM2 = NetCDF_to_tibble(dataSIM2_path)




