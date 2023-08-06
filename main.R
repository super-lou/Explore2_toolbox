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
# 'extract_data' in the vector, the extract will also be perfom
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
# - 'extract_data' :
#     Perfom the requested analysis on the created data contained in
#     the tmpdir/. Details about the analysis are given with the
#     extract_data variable in the ## 2. EXTRACT_DATA section of the
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
# - 'save_extract' :
#     Saves all the data contained in the tmpdir/ to the resdir/. The
#     format used is specified in the saving_format variable of the 
#     ## 3. SAVE_EXTRACT section of the STEPS part.
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
# - 'selection' :
#     Select only the criteria listed in the selection
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

type =
    "hydrologie"
    # "piezometrie"

mode =
    "diagnostic"
    # "diagnostic_ungauged"
    # "projection"
    # "projection_merge"

to_do =
    c(
        # 'delete_tmp',
        # 'merge_nc'
        # 'reshape_data'
        'create_data',
        # 'extract_data',
        'save_extract'
        # 'read_tmp'
        # 'read_saving',
        # 'selection',
        # 'write_warnings',
        # 'add_regime_hydro'
        # 'analyse_data'
        # 'plot_sheet'
        # 'plot_doc'
        # 'create_data_proj'
    )

extract_data =
    c(
        # 'WIP'
        'Explore2_criteria_diag_performance',
        'Explore2_criteria_diag_sensibilite',
        'Explore2_criteria_diag_sensibilite_RAT',
        'Explore2_criteria_diag_HE',
        'Explore2_criteria_diag_ME',
        'Explore2_criteria_diag_BE',
        'Explore2_criteria_diag_BF',
        'Explore2_serie_diag_plot'
        # 'Explore2_serie_proj_safran',
        # 'Explore2_serie_more_proj_safran'
        # 'Explore2_serie_proj'
        # 'Explore2_serie_more_proj'
    )


## 3. PLOTTING PROCESSES _____________________________________________
### 3.1. Sheet _______________________________________________________
# The use of this plot_sheet vector is quite similar to the to_do
# vector. It regroups all the different datasheet you want to plot
# individually. For example if you write 'diagnostic_station', the
# data previously extractd saved and read will be use to plot the
# diagnostic datasheet for specific stations.  
#
# Options are listed below with associated results after '>' :
#
# - 'sommaire' :
#     Plots the sommaire page of a selection of pages.
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
        # 'sommaire'
        # 'correlation_matrix'
        # 'fiche_diagnostic_station'
        # 'fiche_diagnostic_region'
        'fiche_diagnostic_regime'
        # 'fiche_diagnostic_piezometre'
        # 'carte_regime'
        # 'carte_critere'
        
    )

### 3.2. Document ____________________________________________________
plot_doc =
    c(
        # "correlation_matrix"
        # "correlation_matrix_ungauged"
        
        # 'fiche_diagnostic_region'
        'fiche_diagnostic_regime'
        # 'fiche_diagnostic_piezometre'

        ## normal
        # "carte_critere_model"
        # "carte_critere_model_secteur"
        # "carte_critere_critere"
        # "carte_critere_critere_secteur"

        ## ungauged
        # "carte_critere_model_ungauged"
        # "carte_critere_model_ungauged_secteur"
        # "carte_critere_critere_ungauged"
        # "carte_critere_critere_ungauged_secteur"

        ## avertissement
        # "carte_critere_model_avertissement_secteur"

        ## piezo
        # "carte_piezo_critere_model"
        # "carte_piezo_critere_critere"
        
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
    # "file"
    "code"


#  ___  _                  
# / __|| |_  ___  _ __  ___
# \__ \|  _|/ -_)| '_ \(_-<
# |___/ \__|\___|| .__//__/ __________________________________________
## 1. CREATE_DATA|_| _________________________________________________ 
period_extract_diag = c('1976-01-01', '2019-12-31')
period_extract_proj = c('1975-09-01', '2100-08-31')
propagate_NA = TRUE
## diag ##
# nCode4RAM | 14 |  9 |  6
# nodes     |  2 |  3 |  4
# tasks     | 28 | 28 | 28
## proj per model ##
# nProj     | 82 | 41
# nCode4RAM | 20 | 20
# nodes     |  3 |  2
# tasks     | 28 | 28
nCode4RAM = 100

projs_to_use =
    c(
        'all'
        # "(rcp26)|(rcp45)|(rcp85")
        # "MPI.*rcp85.*RegCM4.*CDFt"
        # "EARTH.*HadREM3.*ADAMONT.*CTRIP"
        # "HadGEM2.*rcp45.*CCLM.*ADAMONT.*SIM2"
        # "MPI.*rcp26.*RegCM4.*ADAMONT"
        # "ALADIN.*ADAMONT"
        # "rcp26"
        # "EC-EARTH.*rcp26.*HadREM3.*ADAMONT.*CTRIP"
        # "NorESM1-M.*rcp26.*REMO.*ADAMONT"
        # "HadGEM2.*histo.*RegCM4.*CDFt"
        # "MPI.*rcp45.*CCLM.*ADAMONT"
        # "MPI.*rcp85.*RegCM4.*ADAMONT"
        # "EC.*rcp45.*RACMO22E.*ADAMONT"

        # "CNRM.*rcp45.*ALADIN63.*ADAMONT"
    )

models_to_use =
    c(
        "CTRIP",
        "EROS",
        "GRSD",
        "J2000",
        "SIM2",
        "MORDOR-SD",
        "MORDOR-TS",
        "ORCHIDEE", 
        "SMASH"

        # "AquiFR",
        # "EROS Bretagne",
        # "MONA"
        
    )
complete_by = "SMASH"

codes_to_use =
    # ''
    c(
        'all'
        # 'K2981910' #ref
        # "^A"
        # "^H64"
        # "^I",
        # "^K"
        
        
        ## échange code
        # "K2240820",
        # "K2240810",
        # "K0910010"

        ## edf problème
        # "K0100020",
        # "K1930010",
        # "K2680810"

        ## pourri
        # "H640201001", #SIM2
        # "B413201001", #CTRIP
    )

# "K072530200" manquante

diag_station_2_remove =
    c(
        "ORCHIDEE"="K649*",
        "CTRIP"="O038401001",
        "CTRIP"="D020601001"
    )

# existant :
# K0910010
# K2240810
# conversion :
# K0910050 -> K0910010
# K2240820 -> K2240810

# KLIGNON1 -> K0725302





# dataEX_criteria_normal = dataEX_criteria
# dataEX_criteria_ungauged = dataEX_criteria
# dataEX_criteria = dplyr::filter(dataEX_criteria_normal, !(Model %in% c("GRSD", "SMASH")))
# dataEX_criteria = dplyr::bind_rows(dataEX_criteria, dataEX_criteria_ungauged)
# dataEX_criteria = dplyr::filter(dataEX_criteria, Model != "MORDOR-SD")



## 2. EXTRACT_DATA ___________________________________________________
# Name of the subdirectory in 'CARD_dir' that includes variables to
# extract. If no subdirectory is selected, all variable files will be
# used in 'CARD_dir' (which is may be too much).
# This subdirectory can follows some rules :
# - Variable files can be rename to began with a number followed by an
#   underscore '_' to create an order in variables. For example,
#   '2_QA.R' will be extractd and plotted after '1_QMNA.R'.
# - Directory of variable files can also be created in order to make a
#   group of variable of similar topic. Names should be chosen between
#   'Crue'/'Crue Nivale'/'Moyennes Eaux' and 'Étiage'. A directory can
#   also be named 'Resume' in order to not include variables in an
#   topic group.

WIP = 
    list(name='WIP',
         # variables=c("QA", "QA_season"),
         # variables=c("epsilon_P_season", "epsilon_T_season"),
         variables=c("QA"),
         suffix=c("_obs", "_sim"),
         # suffix=c("_obs"),
         suffix=NULL,
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=FALSE)

# diag
Explore2_criteria_diag_performance = 
    list(name='Explore2_criteria_diag_performance',
         variables=c("KGE", "KGEracine",
                     "NSE", "NSEracine", "NSElog", "NSEinv",
                     "Biais", "Biais_season",
                     "STD"),
         suffix=NULL,
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_criteria_diag_sensibilite = 
    list(name='Explore2_criteria_diag_sensibilite',
         variables=c("Rc",
                     "epsilon_P", "epsilon_P_season",
                     "epsilon_T", "epsilon_T_season"),
         suffix=c("_obs", "_sim"),
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_criteria_diag_sensibilite_RAT = 
    list(name='Explore2_criteria_diag_sensibilite_RAT',
         variables=c("RAT_T", "RAT_P", "RAT_ET0"),
         suffix=NULL,
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_criteria_diag_HE = 
    list(name='Explore2_criteria_diag_HE',
         variables=c("Q10",
                     "QJXA-10", "alphaQJXA",
                     "med{tQJXA}", "med{dtCrue}"),
         suffix=c("_obs", "_sim"),
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_criteria_diag_ME = 
    list(name='Explore2_criteria_diag_ME',
         variables=c("Q50",
                     "moyQA", "aCDC", "alphaQA"),
         suffix=c("_obs", "_sim"),
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_criteria_diag_BE = 
    list(name='Explore2_criteria_diag_BE',
         variables=c("Q90",
                     "QMNA-5", "VCN30-2", "VCN10-5", "alphaVCN10", 
                     "med{tVCN10}", "med{allBE}"),
         suffix=c("_obs", "_sim"),
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_criteria_diag_BF = 
    list(name='Explore2_criteria_diag_BF',
         variables=c("BFI", "BFM",
                     "med{debutBF}", "med{centreBF}", "med{finBF}",
                     "med{dtBF}", "med{vBF}", "med{dtRec}"),
         suffix=c("_obs", "_sim"),
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=TRUE)

Explore2_serie_diag_plot = 
    list(name='Explore2_serie_diag_plot',
         variables=c("QM", "QA", "PA_all", "P_r_all",
                     "medQJC5", "CDC"),
         suffix=c("_obs", "_sim"),
         expand=FALSE,
         cancel_lim=TRUE,
         simplify=FALSE)

if (type == "piezometrie") {
    Explore2_serie_diag_plot$variables = "medQJC5"
}

# proj safran
Explore2_serie_proj_safran =
    list(name='Explore2_serie_proj_safran',
         variables=c("QA", "QA_month", "QA_season",
                     "QA05", "QA10", "QA50", "QA90", "QA95",
                     "QJXA", "VCX3",
                     "QMNA", "VCN10", "VCN3"),
         suffix="_obs",
         expand=TRUE,
         cancel_lim=FALSE,
         simplify=FALSE)

Explore2_serie_more_proj_safran =
    list(name='Explore2_serie_more_proj_safran',
         variables=c("tQJXA", "fQA01", "fQA05", "fQA10", "dtCrue",
                     "tVCN10", "allBE",
                     "debutBF", "centreBF", "finBF",
                     "dtBF", "vBF", "dtRec"),
         suffix="_obs",
         expand=TRUE,
         cancel_lim=FALSE,
         simplify=FALSE)

# proj
Explore2_serie_proj =
    list(name='Explore2_serie_proj',
         variables=c("QA", "QA_month", "QA_season",
                     "QA05", "QA10", "QA50", "QA90", "QA95",
                     "QJXA", "VCX3",
                     "QMNA", "VCN10", "VCN3"),
         suffix="_sim",
         expand=TRUE,
         cancel_lim=FALSE,
         simplify=FALSE)

Explore2_serie_more_proj =
    list(name='Explore2_serie_more_proj',
         variables=c("tQJXA", "fQA01", "fQA05", "fQA10", "dtCrue",
                     "tVCN10", "allBE",
                     "debutBF", "centreBF", "finBF",
                     "dtBF", "vBF", "dtRec"),
         suffix="_sim",
         expand=TRUE,
         cancel_lim=FALSE,
         simplify=FALSE)

# Explore2_proj_delta =
#     list(name='Explore2_proj_delta',
#          variables="deltaQA",
#          cancel_lim=FALSE,
#          simplify=TRUE)


## 3. SAVE_EXTRACT ___________________________________________________
# If one input file need to give one output file
by_files =
    # TRUE
    FALSE

var2save =
    c(
        'meta',
        'data',
        'dataEX',
        'metaEX'
    )

# Saving format to use to save extract data
saving_format =
    ""
    # c('Rdata', 'txt')

wait =
    NULL
    # 1

## 4. READ_SAVING ____________________________________________________
read_saving =
    file.path(mode, type)
    # "proj/SMASH/CNRM-CM5_historical_ALADIN63_ADAMONT_SMASH"

var2search =
    c(
        'meta[.]',
        'data[.]fst',
        'dataEX',
        'metaEX',
        'Warnings'
    )

merge_read_saving =
    TRUE
    # FALSE

# ## 5. SELECTION _____________________________________________
diag_criteria_selection =
#     # "all"
    c("KGEracine", "Biais$", "epsilon.*JJA$", "epsilon.*DJF$",
      "RAT[_]T$", "RAT[_]P$", "Q10$", "med[{]tQJXA[}]$",
      "^alphaQA$", "^aCDC$", "Q90$", "med[{]tVCN10[}]$")

diag_period_selection =
    list(
        "MORDOR-TS"=c(NA, as.Date("2017-08-31"))
    )

diag_station_selection =
    c(
        "ORCHIDEE"="K649*",
        "CTRIP"="O038401001",
        "CTRIP"="D020601001"
    )


## 6. PLOT_SHEET _____________________________________________________
# If the hydrological network needs to be plot
river_selection =
    NULL
    # c('La Seine$', "'Yonne$", 'La Marne$', 'La Meuse', 'La Moselle$',
    #   '^La Loire$', '^la Loire$', '^le cher$', '^La Creuse$',
    #   '^la Creuse$', '^La Vienne$', '^la Vienne$', 'La Garonne$',
    #   'Le Tarn$', 'Le Rhône$', 'La Saône$')

river_length =
    # NULL
    300000
    
# Tolerance of the simplification algorithm for shapefile in sf
toleranceRel =
    1000 # normal map
    # 9000 # mini map

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
    "CTRIP"="#A88D72", #marron
    "EROS"="#CECD8D", #vert clair
    "GRSD"="#619C6C", #vert foncé
    "J2000"="#74AEB9", #bleu clair
    "MORDOR-SD"="#D8714E", #orange
    "MORDOR-TS"="#AE473E", #rouge
    "ORCHIDEE"="#EFA59D", #rose
    "SIM2"="#475E6A", #bleu foncé
    "SMASH"="#F6BA62", #mimosa
    # "Multi-modèle"="",

    "AquiFR"="#AF3FA5", #violet
    "EROS Bretagne"="#CECD8D", #vert clair
    "MONA"="#F5D80E" #jaune
)

add_multi = TRUE


## 7. PLOT_DOC _______________________________________________________
default_doc_title = "Diagnostic Hydrologique"
doc_correlation_matrix =
    list(
        title="Matrice de corrélation des critères d'évaluation",
        subtitle=NULL,
        chunk='all',
        sheet=c('sommaire',
                'correlation_matrix')
    )
doc_correlation_matrix_ungauged =
    list(
        title="Matrice de corrélation des critères d'évaluation",
        subtitle="Validation croisée par bloc",
        chunk='all',
        sheet=c('sommaire',
                'correlation_matrix')
    )
doc_fiche_diagnostic_regime =
    list(
        title='Fiche diagnostic par régime',
        subtitle=NULL,
        chunk='all',
        sheet=c('sommaire',
                'fiche_diagnostic_regime')
    )
doc_fiche_diagnostic_region =
    list(
        title='Fiche diagnostic région',
        subtitle=NULL,
        chunk='region',
        sheet=c('sommaire',
                'fiche_diagnostic_region',
                'fiche_diagnostic_station')
    )

## Piezometre
doc_fiche_diagnostic_piezometre =
    list(
        title='Fiche diagnostic piézomètre',
        subtitle=NULL,
        chunk='all',
        sheet=c('sommaire',
                'fiche_diagnostic_piezometre')
    )

## Carte
### Station
doc_carte_critere_model =
    list(
        title="Carte des critères d'évaluation par modèle",
        subtitle=NULL,
        chunk='model',
        sheet=c('sommaire',
                'carte_critere')
    )
doc_carte_critere_critere =
    list(
        title="Carte des critères d'évaluation par critère",
        subtitle=NULL,
        chunk='critere',
        sheet=c('sommaire',
                'carte_critere')
    )
### Secteur
doc_carte_critere_model_secteur =
    list(
        title="Carte des critères d'évaluation par modèle (secteur)",
        subtitle=NULL,
        chunk='model',
        sheet=c('sommaire',
                'carte_critere_secteur')
    )
doc_carte_critere_critere_secteur =
    list(
        title="Carte des critères d'évaluation par critère (secteur)",
        subtitle=NULL,
        chunk='critere',
        sheet=c('sommaire',
                'carte_critere_secteur')
    )

## Carte en validation croisée
### Station
doc_carte_critere_model_ungauged =
    list(
        title="Carte des critères d'évaluation par modèle",
        subtitle="Validation croisée par bloc",
        chunk='model',
        sheet=c('sommaire',
                'carte_critere')
    )
doc_carte_critere_critere_ungauged =
    list(
        title="Carte des critères d'évaluation par critère",
        subtitle="Validation croisée par bloc",
        chunk='critere',
        sheet=c('sommaire',
                'carte_critere')
    )
### Secteur
doc_carte_critere_model_ungauged_secteur =
    list(
        title="Carte des critères d'évaluation par modèle (secteur)",
        subtitle="Validation croisée par bloc",
        chunk='model',
        sheet=c('sommaire',
                'carte_critere_secteur')
    )
doc_carte_critere_critere_ungauged_secteur =
    list(
        title="Carte des critères d'évaluation par critère (secteur)",
        subtitle="Validation croisée par bloc",
        chunk='critere',
        sheet=c('sommaire',
                'carte_critere_secteur')
    )

### Warning
doc_carte_critere_model_avertissement_secteur =
    list(
        title="Carte des avertissements par modèle (secteur)",
        subtitle="Avertissements",
        chunk='model',
        sheet=c('sommaire',
                'carte_critere_avertissement_secteur')
    )



## Carte piezo
### Station
doc_carte_piezo_critere_model =
    list(
        title="Carte des critères d'évaluation par modèle",
        subtitle="Piézomètre",
        chunk='model',
        sheet=c('sommaire',
                'carte_critere_piezo_shape')
    )
doc_carte_piezo_critere_critere =
    list(
        title="Carte des critères d'évaluation par critère",
        subtitle="Piézomètre",
        chunk='critere',
        sheet=c('sommaire',
                'carte_critere_piezo_shape')
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
library(stringr)

# already ::
# library(tidyr)
# library(grid)
# library(ncdf4)
# library(rgeos)
# library(lubridate)
# library(sp)
# library(fst)


if (any(grepl("plot", to_do))) {
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
    library(ggtext)
}

if (MPI != "") {
    library(Rmpi)
    rank = mpi.comm.rank(comm=0)
    size = mpi.comm.size(comm=0)
} else {
    rank = 0
    size = 1
}


if (grepl("diagnostic", mode)) {
    period_extract = period_extract_diag
} else if (grepl("projection", mode)) {
    period_extract = period_extract_proj
    var2save = var2save[var2save != "data"]
}

# if (!(file.exists(resources_path)) & rank == 0) {
  # dir.create(resources_path)
# }

delete_tmp = FALSE
merge_nc = FALSE
read_tmp = FALSE


# if ('extract_data' %in% to_do) {
extract_data_tmp = lapply(extract_data, get)
names(extract_data_tmp) = extract_data
extract_data = extract_data_tmp
# }


if ('plot_doc' %in% to_do) {
    plot_doc = get(paste0("doc_", plot_doc[1]))
}

if (type == "hydrologie") {

    if (grepl("projection", mode)) {
        projs_selection_data = read_tibble(file.path(
            computer_data_path,
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
        
        if (mode == "projection_merge") {
            projs_selection_data =
                projs_selection_data[projs_selection_data$EXP !=
                                     "historical",]
        }
        
        proj_path = file.path(computer_data_path, type, mode)

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

            
            OK = apply(as.matrix(
                sapply(projs_to_use, grepl,
                       x=projs_selection_data$file)),
                1, any)
            projs_selection_data = projs_selection_data[OK,]
            OK_nest = apply(as.matrix(
                sapply(projs_to_use, grepl,
                       x=projs_selection_data_nest$regexp)),
                1, any)
            projs_selection_data_nest = projs_selection_data_nest[OK_nest,]
        }

        files_to_use = projs_selection_data_nest$path
        names(files_to_use) = projs_selection_data_nest$ID

        write_tibble(dplyr::select(projs_selection_data,
                                   -"path"),
                     filedir=today_resdir,
                     filename="projs_selection.txt")

        
    } else if (grepl("diagnostic", mode)) { #####
        diag_path = file.path(computer_data_path, type, mode)
        models_to_use_name = models_to_use
        models_path = list.files(file.path(computer_data_path,
                                           type,
                                           mode),
                                 full.names=TRUE)
        models_file = basename(models_path)
        files_to_use = lapply(models_to_use, apply_grepl,
                              table=models_file, target=models_path)
        names(files_to_use) = models_to_use_name
        files_to_use = files_to_use[sapply(files_to_use, length) > 0]

        complete_by =
            complete_by[complete_by %in% names(files_to_use)][1]
    }
    
    nFiles_to_use = length(files_to_use)

    codes_selection_data = read_tibble(file.path(
        computer_data_path, type,
        codes_hydro_selection_file))
    codes_selection_data = dplyr::filter(codes_selection_data,
                                         !grepl("Supprimer", X))

    codes_selection_data$SuggestionNOM =
        gsub(" A ", " à ",
             gsub("L ", "l'",
                  gsub("^L ", "L'",
                       stringr::str_to_title(
                                    gsub("L'", "L ",
                                         codes_selection_data$SuggestionNOM
                                         )))))
    write_tibble(codes_selection_data,
                 filedir=today_resdir,
                 filename="codes_selection_data.txt")

    if (grepl("diagnostic", mode)) {
        ref = 1
    } else if (grepl("projection", mode)) {
        ref = c(0, 1)
    }
    codes_selection_data =
        codes_selection_data[codes_selection_data$Référence %in%
                             ref,]
    codes8_selection = codes_selection_data$CODE
    codes10_selection = codes_selection_data$SuggestionCode
    codes8_selection = codes8_selection[!is.na(codes8_selection)]
    codes10_selection = codes10_selection[!is.na(codes10_selection)]

    if (all(codes_to_use == "")) {
        stop ("No station selected")
    }
    if (all(codes_to_use == "all")) {
        CodeALL8 = codes8_selection
        CodeALL10 = convert_codeNtoM(codes8_selection)
    } else {
        # codes_to_use[nchar(codes_to_use) == 10] =
        # codes8_selection[codes10_selection %in%
        # codes_to_use[nchar(codes_to_use) == 10]]
        codes_to_use = convert_codeNtoM(codes_to_use, 10,
                                        8, top=NULL)
        codes_to_use = convert_regexp(computer_data_path,
                                      file.path(type,
                                                obs_hydro_dir),
                                      codes_to_use,
                                      obs_hydro_format)
        
        okCode = codes_to_use %in% codes8_selection
        CodeALL8 = codes_to_use[okCode]
        # CodeALL10 = codes10_selection[codes8_selection %in% CodeALL8]
        CodeALL10 = convert_codeNtoM(CodeALL8)
    }
    CodeALL8 = CodeALL8[nchar(CodeALL8) > 0]
    CodeALL10 = CodeALL10[nchar(CodeALL10) > 0]
    nCodeALL = length(CodeALL10)

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

    
} else if (type == "piezometrie") {
    nCode4RAM = 300
    files_to_use = ""
    Subsets = ""
    nSubsets = 1
    
    Files = ""
    Files_name = ""
    nFiles = 1
    
    codes_selection_data = read_tibble(file.path(
        computer_data_path, type,
        codes_piezo_selection_file))
    
    codes10_selection = codes_selection_data$code_bss

    if (all(codes_to_use == "all")) {
        CodeALL = codes10_selection
    } else {
        okCode = grepl(paste0("(",
                              paste0(codes_to_use, collapse=")|("),
                              ")"), codes10_selection)
        CodeALL = codes10_selection[okCode]
    }
}



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

if ('reshape_data' %in% to_do) {
    post("## RESHAPE DATA")
    source(file.path(lib_path, 'script_reshape_data.R'),
           encoding='UTF-8')
}

if (any(c('create_data', 'extract_data', 'save_extract') %in% to_do)) {

    if (all(c('create_data', 'extract_data') %in% to_do)) {
        post("## CREATING AND EXTRACTING DATA")
    } else if ('create_data' %in% to_do) {
        post("## CREATING DATA")
    } else if ('extract_data' %in% to_do) {
        post("## EXTRACTING DATA")
    } else if (!('save_extract' %in% to_do)) {
        post("Maybe you can start by creating data")
    }

    timer = dplyr::tibble()

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

            if (type == "hydrologie") {
                sep = "_"
            } else if (type == "piezometrie") {
                sep = ""
            }
            
            Create_ok = c()
            
            for (ss in 1:nSubsets) {
                subset = Subsets[[ss]]
                subset_name = names(Subsets)[ss]

                if (ss < nSubsets) {
                    subset_next = Subsets[[ss+1]]
                    subset_next_name = names(Subsets)[ss+1]
                } else {
                    subset_next = "!"
                    subset_next_name = "!"
                }

                post(paste0("For subset ", files_name_opt.,
                            subset_name, ": ",
                            paste0(subset, collapse=" -> ")))
                
                file_test = c()
                if ('create_data' %in% to_do & "data" %in% var2save) {
                    file_test = c(file_test,
                                  paste0("data", sep,
                                         files_name_opt.,
                                         subset_next_name, ".fst"))
                }
                if ('extract_data' %in% to_do) {
                    for (aa in 1:length(extract_data)) {
                        extract = extract_data[[aa]]
                        
                        if (extract$simplify) {
                            file_test = c(file_test,
                                          paste0("dataEX_",
                                                 extract$name,
                                                 sep, files_name_opt.,
                                                 subset_next_name, ".fst"))
                        } else {
                            file_test = c(file_test,
                                          paste0("dataEX_",
                                                 extract$name,
                                                 sep, files_name_opt.,
                                                 subset_next_name))
                        }
                    }
                }
                
                post(paste0(ss, "/", nSubsets,
                            " chunks of stations in extract so ",
                            round(ss/nSubsets*100, 1), "% done"))
                
                if (all(file_test %in% list.files(tmppath,
                                                  include.dirs=TRUE))) {
                    Create_ok = c(Create_ok, TRUE)
                    next
                }

                if (type == "hydrologie") {
                    CodeSUB8 = CodeALL8[subset[1]:subset[2]]
                    CodeSUB8 = CodeSUB8[!is.na(CodeSUB8)]
                    CodeSUB10 = CodeALL10[subset[1]:subset[2]]
                    CodeSUB10 = CodeSUB10[!is.na(CodeSUB10)]
                    nCodeSUB = length(CodeSUB10)
                } else if (type == "piezometrie") {                    
                    CodeSUB = CodeALL
                }

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
                    if ('extract_data' %in% to_do) {
                        timer = start_timer(timer, rank, "extract",
                                            paste0(files_name_opt.,
                                                   subset_name))
                        source(file.path(lib_path,
                                         'script_extraction.R'),
                               encoding='UTF-8')
                        timer = stop_timer(timer, rank, "extract",
                                           paste0(files_name_opt.,
                                                  subset_name))
                    }
                }
                Create_ok = c(Create_ok, create_ok)
                
                print("")
            }

            if (any(Create_ok)) {
                if (any(c('extract_data', 'save_extract') %in% to_do)) {
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

        timer$time = as.numeric(timer$stop - timer$start)
    } else {
        warning ("No files")
    }

    write_tibble(timer, today_resdir,
                 paste0("timer_", rank, ".txt"))
}

if (any(c('selection', 'write_warnings', 'add_regime_hydro',
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

if (any(c('analyse_data') %in% to_do)) {
    post("## ANALYSING DATA")
    source(file.path(lib_path, 'script_analyse.R'),
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

