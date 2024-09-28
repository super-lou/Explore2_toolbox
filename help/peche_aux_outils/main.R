# Copyright 2024 Louis Héraut (louis.heraut@inrae.fr)*1,
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
# Explore2 R toolbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Explore2 R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


if(!require(ncdf4)) install.packages("ncdf4", dependencies=TRUE)
if(!require(lubridate)) install.packages("lubridate", dependencies=TRUE)
if(!require(dplyr)) install.packages("dplyr", dependencies=TRUE)
if(!require(tidyr)) install.packages("tidyr", dependencies=TRUE)
if(!require(ggh4x)) install.packages("ggh4x", dependencies=TRUE)
if(!require(latex2exp)) install.packages("latex2exp", dependencies=TRUE)

library(ncdf4)
library(dplyr)
library(ggplot2)
library(ggh4x)
library(latex2exp)

source("tools.R")



## 0. INFO ___________________________________________________________
# La liste des narratifs ainsi que quelques données utiles les
# concernants
Storylines = list(
    vert=list(
        name="vert",
        EXP="(historical)|(rcp85)",
        GCM="HadGEM2-ES", RCM="ALADIN63", BC="ADAMONT",
        climate_chain=c(
            "historical|MOHC-HadGEM2-ES|CNRM-ALADIN63|MF-ADAMONT-SAFRAN-1980-2011",
            "rcp85|MOHC-HadGEM2-ES|CNRM-ALADIN63|MF-ADAMONT-SAFRAN-1980-2011"),
        color="#569A71", color_light="#BAD8C6",
        info="Réchauffement marqué et augmentation des précipitations"
    ),
    jaune=list(
        name="jaune",
        EXP="(historical)|(rcp85)",
        GCM="CNRM-CM5", RCM="ALADIN63", BC="ADAMONT",
        climate_chain=c(
            "historical|CNRM-CERFACS-CNRM-CM5|CNRM-ALADIN63|MF-ADAMONT-SAFRAN-1980-2011",
            "rcp85|CNRM-CERFACS-CNRM-CM5|CNRM-ALADIN63|MF-ADAMONT-SAFRAN-1980-2011"),
        color="#EECC66", color_light="#F8EBC2",
        info="Changements futurs relativement peu marqués"
    ),
    orange=list(
        name="orange",
        EXP="(historical)|(rcp85)",
        GCM="EC-EARTH", RCM="HadREM3-GA7", BC="ADAMONT",
        climate_chain=c(
            "historical|ICHEC-EC-EARTH|MOHC-HadREM3-GA7-05|MF-ADAMONT-SAFRAN-1980-2011",
            "rcp85|ICHEC-EC-EARTH|MOHC-HadREM3-GA7-05|MF-ADAMONT-SAFRAN-1980-2011"),
        color="#E09B2F", color_light="#F3D7AC",
        info="Fort réchauffement et fort assèchement en été (et en annuel)"
    ),
    violet=list(
        name="violet",
        EXP="(historical)|(rcp85)",
        GCM="HadGEM2-ES", RCM="CCLM4-8-17", BC="ADAMONT",
        climate_chain=c(
            "historical|MOHC-HadGEM2-ES|CLMcom-CCLM4-8-17|MF-ADAMONT-SAFRAN-1980-2011",
            "rcp85|MOHC-HadGEM2-ES|CLMcom-CCLM4-8-17|MF-ADAMONT-SAFRAN-1980-2011"),
        color="#791F5D", color_light="#E9A9D5",
        info="Fort réchauffement et forts contrastes saisonniers en précipitations"
    )
)


## 1. PROJECTIONS ____________________________________________________
### 1.1. Obtenir les URLs ____________________________________________
# Une liste préformatée des URLs disponibles sur DRIAS-Eau est
# disponible dans le fichier URL_DRIAS_projections.csv
URL = dplyr::as_tibble(read.table(
                 file=file.path("robot",
                                "URL_DRIAS_projections.csv"),
                 header=TRUE,
                 sep=",", quote='"'))

# Le tibble URL contient donc l'ensemble des combinaisons utiles pour
# faire une sous sélection des URLs disponibles
EXP = unique(URL$EXP)
GCM = unique(URL$GCM)
RCM = unique(URL$RCM)
BC = unique(URL$BC)
HM = unique(URL$HM)
Variables = unique(URL$variable)

### 1.2. Filtrer les URLs ____________________________________________
# Soit en utilisant le tibble URL avec dplyr pour une combinaison
# spécifique ...
URL_filtered = dplyr::filter(URL,
                             EXP == "rcp85" &
                             grepl("ADAMONT", BC) &
                             HM %in% c("J2000", "GRSD"))

# ou pour filtrer les narratifs Explore2
URL_filtered = dplyr::tibble()
for (storyline in Storylines) {
    URL_filtered_tmp = dplyr::filter(URL,
                                     grepl(storyline$EXP, EXP) &
                                     grepl(storyline$GCM, GCM) &
                                     grepl(storyline$RCM, RCM) &
                                     grepl(storyline$BC, BC))
    URL_filtered = dplyr::bind_rows(URL_filtered, URL_filtered_tmp)
}
URL_filtered = dplyr::filter(URL_filtered,
                             HM %in% c("J2000", "GRSD"))
Urls = URL_filtered$url

# Soit en lisant directement un fichier txt qui contient une liste des
# URLs récupérés par le biais de la plateforme DRIAS-Eau
Urls = readLines("manual_URL_DRIAS_projections.txt")

### 1.3. Obtenir les NetCDFs _________________________________________
get_netcdf(Urls, "DRIAS_projections")

### 1.4. Lire un NetCDF ______________________________________________
# Obtenir l'ensemble des chemins des NetCDFs téléchargés
Paths = list.files(file.path("DRIAS_projections"),
                   full.names=TRUE)

# Le package ncdf4 permet de lire un NetCDF
NC = nc_open(Paths[1])

# Dans un premier temps, il est possible d'obtenir la liste des
# attributs globaux ...
ncatt_get(NC, "")$value
# ou un seul spécifiquement
ncatt_get(NC, "", "hy_institute_id")$value
# De la même manière, il est possible d'obtenir les attributs
# d'une dimension ou d'une variable
ncatt_get(NC, "time", "units")$value

# Dans un second temps, il est possible d'obtenir une variable
# contenue dans la liste des variables disponibles
names(NC$var)
# Donc par exemple pour obtenir le code des stations :
Codes_NC = ncvar_get(NC, "code")

# De cette manière, pour la Dore à Dora ...
code = "K298191001"
# il faut chercher son indice dans ce NetCDF
id = match(code, Codes_NC)
# Cet id permet donc d'aller chercher les informations d'intérêts dans
# ce NetCDF et uniquement dans celui-ci
ncvar_get(NC, "topologicalSurface_model")[id]

# Cependant, il est plus périlleux de vouloir répéter l'opération
# précédente pour obtenir l'entierté de la matrice des débits.
# Il est donc conseillé de n'en tier que la partie souhaité en
# utilisant les fonctionnalités internes aux NetCDFs
# On part de l'indice id pour la première dimension "station" et on
# part du début de la dimension seconde dimension "time"
start = c(id, 1)
# On compte un seul pas sur la dimension "station" et on prend
# l'entiereté de la dimension "time"
count = c(1, -1)
# Ainsi, on peut obtenir les débits de la Dore à Dora pour ce NetCDF
Q = ncvar_get(NC, "debit",
              start=start,
              count=count)

# et son vecteur temps associé
Date = ncvar_get(NC, "time") + as.Date("1950-01-01")

# Cette fonction reprend ce procédé avec une liste de station pour
# obtenir un tibble près à être traiter
Codes = c("K297031001", "K298191001", "K299401001")
data = read_netcdf_projections(Paths, Codes)

# Mais pour simplifier le traitement, il est important de regrouper
# la partie historique et la partie projeté de chaque chaîne de
# modélisation
data = merge_data_projections(data)


### 1.5. Afficher les projections ____________________________________
# Pour la Dora à Dora
data_code = dplyr::filter(data, code=="K298191001")

min_date = data_code %>%
    dplyr::filter(EXP == "historical") %>%
    dplyr::group_by(chain) %>%
    dplyr::summarise(min=min(date, na.rm=TRUE))
min_date = max(min_date$min, na.rm=TRUE)

max_date = data_code %>%
    dplyr::filter(EXP != "historical") %>%
    dplyr::group_by(chain) %>%
    dplyr::summarise(max=max(date, na.rm=TRUE))
max_date = min(max_date$max, na.rm=TRUE)

data_code = dplyr::filter(data_code,
                          min_date <= date &
                          date <= max_date)

data_code_med = 
    dplyr::summarise(dplyr::group_by(data_code,
                                     climate_chain,
                                     date),
                     Q=median(Q, na.rm=TRUE),
                     .groups="drop")

figdir = "figures"
if (!dir.exists(figdir)) {
    dir.create(figdir)
}

for (storyline in Storylines) {
    
    data_code_med_storyline =
        dplyr::filter(data_code_med,
                      climate_chain %in% storyline$climate_chain)
    
    plot = ggplot() +
        theme_minimal() +
        theme(panel.grid.major.x=element_blank(),
              panel.grid.minor.x=element_blank(),
              axis.line.x=element_line(color="grey65",
                                       linewidth=0.5,
                                       lineend="round"),
              axis.ticks.x=element_line(color="grey80"),
              axis.ticks.length=unit(0.2, "cm"),
              plot.title=element_text(color=storyline$color)) +
        
        ggtitle(TeX(paste0("\\textbf{", storyline$info, "}"))) +
        
        geom_line(data=data_code,
                  aes(x=date,
                      y=Q,
                      group=chain),
                  color="grey65",
                  linewidth=0.8,
                  alpha=0.15,
                  lineend="round") +
        geom_line(data=data_code_med_storyline,
                  aes(x=date,
                      y=Q),
                  color=storyline$color,
                  linewidth=0.25,
                  alpha=1,
                  lineend="round")

    plot = plot +
        xlab(NULL) +
        scale_x_date(
            breaks=get_breaks,
            minor_breaks=get_minor_breaks,
            guide="axis_minor",
            date_labels="%Y",
            expand=c(0, 0)) +
        ylab(TeX("débit \\small{en m$^{3}$.s$^{-1}$}")) +
        scale_y_sqrt(limits=c(0, NA),
                     expand=c(0, 0))
  

    ggsave(plot=plot,
           filename=file.path(figdir,
                              paste0("DRIAS_projection_",
                                     storyline$name, ".pdf")),
           width=50, height=10, units="cm")
}


## 2. INDICATEURS ____________________________________________________
### 2.1. Obtenir les URLs ____________________________________________
# Une liste préformatée des URLs disponibles sur DRIAS-Eau est
# disponible dans le fichier URL_DRIAS_indicateurs.csv
URL = dplyr::as_tibble(read.table(
                 file=file.path("robot",
                                "URL_DRIAS_indicateurs.csv"),
                 header=TRUE,
                 sep=",", quote='"'))

# Le tibble URL contient donc l'ensemble des combinaisons utiles pour
# faire une sous sélection des URLs disponibles
EXP = unique(URL$EXP)
BC = unique(URL$BC)
HM = unique(URL$HM)
Indicateurs = unique(URL$indicateur)

### 2.2. Filtrer les URLs ____________________________________________
# Soit en utilisant le tibble URL avec dplyr
URL_filtered = dplyr::filter(URL,
                             EXP == "rcp85" &
                             BC == "MF-ADAMONT" &
                             HM %in% c("J2000", "GRSD") &
                             indicateur == "Debit-VCN10_Saisonnier")
Urls = URL_filtered$url

# Soit en lisant directement un fichier txt qui contient une liste des
# URLs récupérés par le biais de la plateforme DRIAS-Eau
Urls = readLines("manual_URL_DRIAS_indicateurs.txt")

### 2.3. Obtenir les NetCDFs _________________________________________
get_netcdf(Urls, "DRIAS_indicateurs")
