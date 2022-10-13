# \\\
# Copyright 2022 Louis Héraut (louis.heraut@inrae.fr)*1
#
# *1   INRAE, France
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



## 1. INITIALISATION _________________________________________________
### 1.1. Importation _________________________________________________
# Import Ex2D
dev_path = file.path(dirname(getwd()),
                     'Ex2D', 'R')
if (file.exists(dev_path)) {
    print('Loading Ex2D from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading Ex2D from package')
    library(Ex2D)
}

### 1.2. Files structure _____________________________________________
data_dir = "data"
results_dir = "results"


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



