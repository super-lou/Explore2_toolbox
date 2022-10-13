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


#  ___   ___  ___    _    ___                               _   
# |   \ | _ \|_ _|  /_\  / __|    ___ __ __ _ __  ___  _ _ | |_ 
# | |) ||   / | |  / _ \ \__ \   / -_)\ \ /| '_ \/ _ \| '_||  _|
# |___/ |_|_\|___|/_/ \_\|___/   \___|/_\_\| .__/\___/|_|   \__| ______
# Export pour le portail DRIAS des données |_| hydro-climatiques 


## 1. INITIALISATION _________________________________________________
### 1.1. Importation _________________________________________________
library(dplyr)
library(ncdf4)
library(stringr)

### 1.2. Source ______________________________________________________
list_path = list.files(getwd(), pattern='*.R$', full.names=TRUE)
list_path = list_path[!grepl("DRIAS_export.R", list_path)]
for (path in list_path) {
    source(path, encoding='UTF-8')    
}


## 2. NOM DU FICHIER _________________________________________________
if (Adjust) {
    Variable = paste0(Variable, "Adjust")
}
filename = paste(Variable, Domain, GCM_Inst_Model, Experiment, Member,
                 RCM_Inst_Model, Version, Bc_Inst_Method_Obs_Period,
                 HYDRO_Inst_Model, TimeFrequency, StartTime_EndTime,
                 sep="_")
if (Suffix != "") {
    filename = paste0(filename, "_", Suffix)
}
filename = paste0(filename, ".nc")


## 3. RASSEMBLEMENT DES INFORMATIONS _________________________________
### 3.1. Obtention des noms de variables et dimensions _______________
lsEnv = ls()
obj_names = str_extract(lsEnv[grepl("[.]name$", lsEnv)], "[^.]+")
obj_names = c(obj_names, "global")

### 3.2. Obtention des attributs _____________________________________
extract_att_name = function (obj_name, lsEnv, notAtt) {
    att_name = gsub("^[.]", "",
                    str_extract(lsEnv[grepl(paste0(obj_name, "[.].*"),
                                            lsEnv)],
                                "([.][:digit:]+[.].*$)|([.].*$)"))
    att_name = att_name[!(att_name %in% notAtt)]
    if (identical(att_name, character(0))) {
        att_name = NULL
    }
    return (att_name)
}
notAtt = c("name", "dimension", "precision", "value")
att_names = lapply(obj_names, extract_att_name,
                   lsEnv=lsEnv, notAtt=notAtt)
names(att_names) = obj_names


## 4. CRÉATION DES DIMENSIONS ________________________________________
dim_names = c()
var_names = c()
nObj = length(obj_names) 
for (i in 1:nObj) {
    name = obj_names[i]
    if (name != "global") {

### 4.1. Vérification ________________________________________________
        obj_dim = paste0(name, ".dimension")
        if (!exists(obj_dim)) {
            dim_name = paste0(name, "_dim")
            dim_value = get(paste0(name, ".value"))

### 4.2. Création en tant que tel ____________________________________
            assign(dim_name,
                   ncdim_def(name, units="", vals=dim_value))
            dim_names = c(dim_names, name)
            
        } else {
            var_names = c(var_names, name)
        }
    }
}

## 5. CRÉATION DES VARIABLES _________________________________________
vars = list()
nVar = length(var_names) 
for (i in 1:nVar) {
    name = var_names[i]
    if (name != "global") {
        var_name = paste0(name, "_var")

### 5.1. Mise en forme des dimensions ________________________________
        var_dim = paste0(name, ".dimension")
        dimStr = get(var_dim)
        dimStr = gsub(" ", "", dimStr)
        if (grepl(",", dimStr)) {
            dimStr = unlist(strsplit(dimStr, ","))
        }
        if (all(dimStr %in% dim_names)) {
            dimStr = paste0(dimStr, "_dim")
            dim = lapply(dimStr, get)
        } else {
            dim = list()
        }

### 5.2. Mise en forme de la précision _______________________________
        var_prec = paste0(name, ".precision")
        if (exists(var_prec)) {
            prec = get(var_prec)
        } else {
            prec = "float"
        }

### 5.3. Création en tant que tel ____________________________________
        assign(var_name,
               ncvar_def(name, units="", prec=prec, dim=dim))
        vars = append(vars, list(get(var_name)))
    }
}


## 6. CRÉATION DU NETCDF _____________________________________________
NCdata = nc_create(filename, vars=vars, force_v4=TRUE)


## 7. AJOUTS DES VALEURS ET ATTRIBUTS ________________________________
actual_dim_names = names(NCdata$dim)

for (i in 1:nObj) {
    name = obj_names[i]

    if (name == "global" | name %in% actual_dim_names | name %in% var_names) {
### 7.1. Ajout des valeurs ___________________________________________
        obj_dim = paste0(name, ".dimension")
        if (exists(obj_dim)) {
            var_value = paste0(name, ".value")
            if (exists(var_value)) {
                value = get(var_value)
                ncvar_put(NCdata, name, value)
            }
        }

### 7.2. Ajout des attributs _________________________________________
        obj_att_names = unlist(att_names[names(att_names) == name])
        obj_att_fullnames = paste0(name, ".", obj_att_names)
        names(obj_att_names) = NULL
        if (!is.null(obj_att_names)) {
            nAtt = length(obj_att_names)
            for (j in 1:nAtt) {
                if (name == "global") {
                    name = 0
                }
                ncatt_put(NCdata,
                          name, gsub("^.*[.]", "", obj_att_names[j]),
                          get(obj_att_fullnames[j]))
            }
        }
    }
}


## 8. FERMETURE ET ENREGISTREMENT DU NETCDF __________________________
NCdata
nc_close(NCdata)
