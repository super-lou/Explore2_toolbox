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


logo_path = load_logo(resources_path, logo_dir, logo_to_show)
icon_path = file.path(resources_path, icon_dir)

docpath = file.path(today_figdir, paste0(document_filename, ".pdf"))
today_figdir_leaf = file.path(today_figdir, "leaf")


plot_sheet_diagnostic_station = function (df_page=NULL) {
    Paths = list.files(file.path(resdir, read_saving),
                       pattern="^data[_].*[.]fst$",
                       include.dirs=TRUE,
                       full.names=TRUE)
    for (path in Paths) {
        data = read_tibble(filepath=path) 
        Code_tmp = levels(factor(data$Code))
        
        if (any(Code_tmp %in% CodeALL)) {
            data = data[data$Code %in% CodeALL,]
            df_page = sheet_diagnostic_station(
                data,
                meta,
                dataEXind,
                metaEXind,
                dataEXserie,
                Colors=Colors_of_models,
                ModelGroup=group_of_models_to_use,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=file.path(today_figdir_leaf,
                                 "diagnostic_station"),
                df_page=df_page)
        }
    }
    return (df_page)
}


if ('sheet_diagnostic_station' %in% to_plot |
    'sheet_diagnostic_region' %in% to_plot |
    'sheet_diagnostic_regime' %in% to_plot) {
    if (!exists("Shapefiles")) {
        Shapefiles = load_shapefile(
            computer_data_path, CodeALL,
            france_dir, france_file,
            bassinHydro_dir, bassinHydro_file,
            regionHydro_dir, regionHydro_file,
            entiteHydro_dir, entiteHydro_file, entiteHydro_coord,
            river_dir, river_file, river_selection=river_selection,
            toleranceRel=toleranceRel)
    }
}


# if ('summary' %in% to_plot) {
#     df_page = tibble(section='Sommaire', subsection=NA, n=1)
# } else {
#     df_page = tibble()
# }

print(df_page)

if ('correlation_matrix' %in% to_plot) {
    df_page = sheet_correlation_matrix(
        dataEXind,
        metaEXind,
        ModelGroup=group_of_models_to_use,
        icon_path=icon_path,
        logo_path=logo_path,
        figdir=file.path(today_figdir_leaf,
                         "diagnostic_correlation_matrix"),
        df_page=df_page)
}

print(df_page)

if ('sheet_diagnostic_regime' %in% to_plot) {
    df_page = sheet_diagnostic_regime(
        meta,
        dataEXind,
        metaEXind,
        dataEXserie,
        Colors=Colors_of_models,
        ModelGroup=group_of_models_to_use,
        icon_path=icon_path,
        Warnings=Warnings,
        logo_path=logo_path,
        Shapefiles=Shapefiles,
        figdir=file.path(today_figdir_leaf,
                         "diagnostic_regime"),
        df_page=df_page)
}

print(df_page)

if ('sheet_diagnostic_region' %in% to_plot) {
    df_page = sheet_diagnostic_region(
        meta,
        dataEXind,
        metaEXind,
        dataEXserie,
        Colors=Colors_of_models,
        ModelGroup=group_of_models_to_use,
        icon_path=icon_path,
        Warnings=Warnings,
        logo_path=logo_path,
        Shapefiles=Shapefiles,
        figdir=file.path(today_figdir_leaf,
                         "diagnostic_region"),
        df_page=df_page)
}

print(df_page)

if ('sheet_diagnostic_station' %in% to_plot) {
    df_page = plot_sheet_diagnostic_station(df_page=df_page)
}

print(df_page)

if ('summary' %in% to_plot) {
    sheet_summary(df_page,
                  title="title", subtitle="subtitle",
                  logo_path=logo_path,
                  figdir=today_figdir_leaf)
}

# Combine independant pages into one PDF
details = file.info(list.files(today_figdir_leaf,
                               recursive=TRUE,
                               full.names=TRUE))
details = details[with(details, order(as.POSIXct(mtime))),]
listfile_path = rownames(details)

if ('summary' %in% to_plot) {
    summary_path = listfile_path[length(listfile_path)]
    listfile_path = listfile_path[-length(listfile_path)]
    listfile_path = c(summary_path, listfile_path)
}

if (pdf_chunk == 'all') {
    pdf_combine(input=listfile_path,
                output=docpath)
}
