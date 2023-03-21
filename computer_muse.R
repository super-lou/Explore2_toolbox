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
# See the 'README.md' file for more information about the utilisation
# of this toolbox.


#   ___                          _             
#  / __| ___  _ __   _ __  _  _ | |_  ___  _ _ 
# | (__ / _ \| '  \ | '_ \| || ||  _|/ -_)| '_|
#  \___|\___/|_|_|_|| .__/ \_,_| \__|\___||_|  
## 1. INFO ________ |_| ______________________________________________
# Work path
computer_work_path = '/home/herautl/scratch'
# Library path for package dev
dev_lib_path = '/home/herautl/library'
# Is it parallelized
MPI = TRUE


## 2. INPUT DIRECTORIES ______________________________________________
### 2.1. Data ________________________________________________________
computer_data_path = '/home/herautl/data'
obs_dir = "Explore2/Explore2 HYDRO QJM critiques 2023"
obs_format = "_HYDRO_QJM.txt"
diag_dir = "Explore2/diagnostic"
proj_dir = "Explore2/projection"
codes_selection_file = "Explore2/Selection points simulation V20230221.txt"
projs_selection_file = "Explore2/ensembleProjectionClimatExplore2.txt"

### 2.2. Variables ___________________________________________________
# Name of the directory that regroups all variables information
CARD_path = file.path(dev_lib_path, "CARD")
# Name of the tool directory that includes all the functions needed to
# calculate a variable
init_tools_dir = '__tools__'
# Name of the default parameters file for a variable
init_var_file = '__default__.R'

#### 2.3. Shapefile ________________________________________________
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

### 2.4. Resources ___________________________________________________
resources_path = file.path(dev_lib_path, "Explore2_toolbox", 'resources')
#### 2.4.1. Logo _____________________________________________________
logo_dir = 'logo'

#### 2.4.2. Icon _____________________________________________________
icon_dir = 'icon'


## 3. OUTPUT DIRECTORIES _____________________________________________
### 3.0. Info ________________________________________________________
today = format(Sys.Date(), "%Y_%m_%d")
now = format(Sys.time(), "%H_%M_%S")

### 3.1. Results _____________________________________________________
resdir = file.path(computer_work_path, 'results')
today_resdir = file.path(computer_work_path, 'results', today)
now_resdir = file.path(computer_work_path, 'results', today, now)

### 3.2. Figures  ____________________________________________________
figdir = file.path(computer_work_path, 'figures')
today_figdir = file.path(computer_work_path, 'figures', today)
now_figdir = file.path(computer_work_path, 'figures', today, now)

### 3.3. Tmp  ________________________________________________________
tmpdir = "tmp"
