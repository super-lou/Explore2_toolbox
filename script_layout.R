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


plot_sheet_diagnostic_station = function (dataEXind_chunk,
                                          dataEXserie_chunk,
                                          Code_to_plot,
                                          today_figdir_leaf,
                                          df_page=NULL,
                                          subverbose=FALSE) {
    
    Paths = list.files(file.path(resdir, read_saving, type),
                       pattern="^data[_].*[.]fst$",
                       include.dirs=TRUE,
                       full.names=TRUE)
    letterPaths = gsub("(.*[_])|([[:digit:]]+[.]fst)", "", Paths)
    Paths = Paths[letterPaths %in% substr(Code_to_plot, 1, 1)]
    for (path in Paths) {
        data = read_tibble(filepath=path) 
        Code_tmp = levels(factor(data$Code))

        if (any(Code_tmp %in% Code_to_plot)) {
            data = data[data$Code %in% Code_to_plot,]
            df_page = sheet_diagnostic_station(
                data,
                meta,
                dataEXind_chunk,
                metaEXind_chunk,
                dataEXserie_chunk,
                Colors=Colors_of_models,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=subverbose)
            break
        }
    }
    return (df_page)
}


logo_path = load_logo(resources_path, logo_dir, logo_to_show)
icon_path = file.path(resources_path, icon_dir)

if (!exists("Shapefiles")) {
    post("### Loading shapefiles")

    if (type == "hydrologie") {
        Code_shp = CodeALL8
    } else if (type == "piezometrie") {
        Code_shp = CodeALL
    }
    
    Shapefiles = load_shapefile(
        computer_shp_path, Code_shp,
        france_shp_path,
        bassinHydro_shp_path,
        regionHydro_shp_path,
        entiteHydro_shp_path, entiteHydro_coord,
        entitePiezo_shp_path,
        river_shp_path,
        river_selection=river_selection,
        river_length=river_length,
        toleranceRel=toleranceRel)

    if (type == "hydrologie") {
        Shapefiles$entiteHydro$Code =
            codes10_selection[match(Shapefiles$entiteHydro$Code,
                                    codes8_selection)]
    }
}


if ('plot_sheet' %in% to_do & !('plot_doc' %in% to_do)) {
    df_page = NULL
    doc_chunk = NULL
    doc_name = default_doc_name
    plot_list = plot_sheet
}
if ('plot_doc' %in% to_do) {
    df_page = dplyr::tibble()
    doc_chunk = plot_doc$chunk
    doc_name = plot_doc$name
    plot_list = plot_doc[!(names(plot_doc) %in% c("name", "chunk"))]
}


if (is.null(doc_chunk)) {
    if (type == "hydrologie") {
        chunkCode = list(codes10_selection)#list(CodeALL10)
        plotCode = list(CodeALL10)
    } else if (type == "piezometrie") {
        chunkCode = list(codes_selection)
        plotCode = list(CodeALL)
    }
} else if (doc_chunk == "all") {
    chunkCode = list(codes10_selection)
    plotCode = chunkCode
} else if (doc_chunk == "region") {
    letter = factor(substr(CodeALL10, 1, 1))
    chunkCode = split(CodeALL10, letter)
    names(chunkCode) = paste0(iRegHydro()[names(chunkCode)],
                              " - ", levels(letter))
    plotCode = chunkCode
} else if (doc_chunk == "couche") {
    get_chunkCode = function (couche, CodeALL) {
        return (CodeALL[is_in_couche(meta$Couche, couche)])  
    }
    Couche = levels(factor(unlist(meta$Couche)))
    Couche = Couche[nchar(Couche) > 0]
    chunkCode = lapply(Couche, get_chunkCode, CodeALL=CodeALL)
    names(chunkCode) = paste0(
        levels(Shapefiles$entitePiezo$libelleeh)[
            match(Couche,
                  Shapefiles$entitePiezo$codeeh)],
        " - ", Couche)

    plotCode = chunkCode
}

nChunk = length(chunkCode)

for (i in 1:nChunk) {

    chunk = chunkCode[[i]]
    Code_to_plot = plotCode[[i]]
    chunkname = names(chunkCode)[i]

    doc_name_ns = gsub(" ", "_", doc_name)
    
    if (!is.null(chunkname)) {
        doc_chunkname = gsub(" ", "_",
                             gsub(" [-] ", "_",
                                  chunkname))
        today_figdir_leaf = file.path(today_figdir,
                                      doc_name_ns,
                                      doc_chunkname, "PDF")
    } else if ('plot_doc' %in% to_do) {
        today_figdir_leaf = file.path(today_figdir,
                                      doc_name_ns,
                                      "PDF")
    } else {
        today_figdir_leaf = today_figdir
    }

    meta_chunk = meta[meta$Code %in% chunk,]
    dataEXind = dataEX_criteria
    metaEXind_chunk = metaEX_criteria
    dataEXserie = dataEX_serie

    if (exists("dataEXind")) {
        dataEXind_chunk = dataEXind[dataEXind$Code %in% chunk,]
        if (nrow(dataEXind_chunk) == 0) {
            next
        }
    }
    if (exists("dataEXserie")) {
        dataEXserie_chunk = list()
        for (j in 1:length(dataEXserie)) {
            dataEXserie_chunk = append(
                dataEXserie_chunk,
                list(dataEXserie[[j]][dataEXserie[[j]]$Code %in%
                                      chunk,]))
        }
        names(dataEXserie_chunk) = names(dataEXserie)
    }
    
    for (sheet in plot_list) {

        if (sheet == 'summary') {
            post("### Plotting summary")
            df_page = tibble(section='Sommaire', subsection=NA, n=1)
        }

        if (sheet == 'diagnostic_matrix') {
            post("### Plotting correlation matrix")
            group_of_models_to_use =
                list(
                    "CTRIP",
                    "EROS",
                    "GRSD",
                    "J2000",
                    "SIM2",
                    "MORDOR-SD",
                    "MORDOR-TS",
                    "ORCHIDEE",
                    "SMASH",     
                    "Multi-model"=
                        c("CTRIP", "EROS", "GRSD", "J2000", "SIM2",
                          "MORDOR-SD", "MORDOR-TS", "ORCHIDEE", "SMASH")
                )
            df_page = sheet_correlation_matrix(
                dataEXind_chunk,
                metaEXind_chunk,
                ModelGroup=group_of_models_to_use,
                icon_path=icon_path,
                logo_path=logo_path,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=subverbose)
        }


        if (sheet == 'diagnostic_map') {
            post("### Plotting map")
            group_of_models_to_use =
                list(
                    "CTRIP",
                    "EROS",
                    "GRSD",
                    "J2000",
                    "SIM2",
                    "MORDOR-SD",
                    "MORDOR-TS",
                    "ORCHIDEE",
                    "SMASH")
            df_page = sheet_criteria_map(
                dataEXind_chunk,
                metaEXind_chunk,
                meta,
                ModelGroup=group_of_models_to_use,
                Colors=Colors_of_models,
                icon_path=icon_path,
                logo_path=logo_path,
                figdir=today_figdir_leaf,
                df_page=df_page,
                Shapefiles=Shapefiles,
                verbose=subverbose)
        }
        

        if (sheet == 'diagnostic_regime') {
            post("### Plotting sheet diagnostic regime")
            df_page = sheet_diagnostic_regime(
                meta,
                dataEXind_chunk,
                metaEXind_chunk,
                dataEXserie_chunk,
                Colors=Colors_of_models,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=subverbose)
        }

        if (sheet == 'diagnostic_couche') {
            post("### Plotting sheet diagnostic couche")
            df_page = sheet_diagnostic_couche(
                meta_chunk,
                dataEXind_chunk,
                metaEXind_chunk,
                dataEXserie_chunk,
                Colors=Colors_of_models,
                icon_path=icon_path,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=subverbose)
        }


        if (sheet == 'diagnostic_region') {
            post("### Plotting sheet diagnostic region")
            df_page = sheet_diagnostic_region(
                meta,
                dataEXind_chunk,
                metaEXind_chunk,
                dataEXserie_chunk,
                Colors=Colors_of_models,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=subverbose)
        }

        if (sheet == 'diagnostic_station') {
            post("### Plotting sheet diagnostic station")
            df_page = plot_sheet_diagnostic_station(
                dataEXind_chunk,
                dataEXserie_chunk,
                Code_to_plot,
                today_figdir_leaf=today_figdir_leaf,
                df_page=df_page,
                subverbose=subverbose)
        }
    }

    if ('summary' %in% plot_list) {
        sheet_summary(df_page,
                      title=doc_name,
                      subtitle=chunkname,
                      logo_path=logo_path,
                      figdir=today_figdir_leaf)
    }

    
    if ('plot_doc' %in% to_do) {
        post("### Merging pdf")
        details = file.info(list.files(today_figdir_leaf,
                                       recursive=TRUE,
                                       full.names=TRUE))
        details = details[with(details, order(as.POSIXct(mtime))),]
        listfile_path = rownames(details)

        if ('summary' %in% plot_list) {
            summary_path = listfile_path[length(listfile_path)]
            listfile_path = listfile_path[-length(listfile_path)]
            listfile_path = c(summary_path, listfile_path)
        }

        if (!is.null(chunkname)) {            
            pdf_combine(input=listfile_path,
                        output=file.path(today_figdir,
                                         doc_name_ns,
                                         doc_chunkname,
                                         paste0(doc_chunkname,
                                                ".pdf")))
            
        } else {
            pdf_combine(input=listfile_path,
                        output=file.path(today_figdir,
                                         doc_name_ns,
                                         paste0(doc_name_ns,
                                                    ".pdf")))
        }
    }
}
