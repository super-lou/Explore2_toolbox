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



plot_sheet_diagnostic_station = function () {
    Paths = list.files(file.path(resdir, read_saving),
                       pattern="^data[_].*[.]fst$",
                       include.dirs=TRUE,
                       full.names=TRUE)
    for (path in Paths) {
        data = read_tibble(filepath=path) 
        Code_tmp = levels(factor(data$Code))
        
        if (any(Code_tmp %in% CodeALL)) {
            data = data[data$Code %in% CodeALL,]
            sheet_diagnostic_station(
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
                figdir=today_figdir)
        }
    }
}

logo_path = load_logo(resources_path, logo_dir, logo_to_show)
icon_path = file.path(resources_path, icon_dir)

if ('plot_correlation_matrix' %in% to_do) {
    sheet_correlation_matrix(dataEXind,
                             metaEXind,
                             ModelGroup=group_of_models_to_use,
                             icon_path=icon_path,
                             logo_path=logo_path,
                             figdir=today_figdir)
}

if ('plot_sheet_diagnostic_station' %in% to_do) {
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
    plot_sheet_diagnostic_station()
}

if ('plot_sheet_diagnostic_region' %in% to_do) {
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
    sheet_diagnostic_region(meta,
                            dataEXind,
                            metaEXind,
                            dataEXserie,
                            Colors=Colors_of_models,
                            ModelGroup=group_of_models_to_use,
                            icon_path=icon_path,
                            Warnings=Warnings,
                            logo_path=logo_path,
                            Shapefiles=Shapefiles,
                            figdir=today_figdir)
}
