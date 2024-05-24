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


plot_sheet_diagnostic_station = function (dataEX_criteria_chunk,
                                          dataEX_serie_chunk,
                                          Code_to_plot,
                                          today_figdir_leaf,
                                          Pages=NULL,
                                          subverbose=FALSE) {
    
    Paths = list.files(file.path(resdir, read_saving),
                       pattern="^data[_].*[.]fst$",
                       include.dirs=TRUE,
                       full.names=TRUE)
    letterPaths = gsub("(.*[_])|([[:digit:]]+[.]fst)", "", Paths)
    Paths = Paths[letterPaths %in% substr(Code_to_plot, 1, 1)]
    for (path in Paths) {
        data = read_tibble(filepath=path) 
        Code_tmp = levels(factor(data$code))

        if (any(Code_tmp %in% Code_to_plot)) {
            data = data[data$code %in% Code_to_plot,]
            Pages = sheet_diagnostic_station(
                data,
                meta,
                dataEX_criteria_chunk,
                metaEX_criteria_chunk,
                dataEX_serie_chunk,
                Colors=Colors_of_HM,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                Pages=Pages,
                verbose=subverbose)
            break
        }
    }
    return (Pages)
}

plot_sheet_projection_station = function (Code_to_plot,
                                          today_figdir_leaf,
                                          Pages=NULL,
                                          subverbose=FALSE) {
    
    Paths = list.files(file.path(resdir,
                                 gsub("projection",
                                      "projection_for_figure",
                                      read_saving)),
                       pattern="^dataEX[_]serie.*$",
                       include.dirs=TRUE,
                       full.names=TRUE)
    letterPaths = gsub("(.*[_])|([[:digit:]]+)", "", Paths)
    Paths = Paths[letterPaths %in% substr(Code_to_plot, 1, 1)]
    for (path in Paths) {
        meta_path = paste0(gsub("dataEX[_]serie",
                                "meta", path), ".fst")
        meta_tmp = read_tibble(meta_path)
        Code_tmp = levels(factor(meta_tmp$code))

        if (any(Code_tmp %in% Code_to_plot)) {
            meta_tmp = meta_tmp[meta_tmp$code %in% Code_to_plot,]
            dataEX_serie_tmp = read_tibble(paste0(path, ".fst"))
            for (k in 1:length(dataEX_serie_tmp)) {
                dataEX_serie_tmp[[k]] =
                    dplyr::filter(dataEX_serie_tmp[[k]],
                                  code %in% Code_to_plot)
            }
            metaEX_serie_path = file.path(dirname(path),
                                          "metaEX_serie.fst")
            metaEX_serie_tmp = read_tibble(metaEX_serie_path)

            code_letter = substr(Code_tmp[1], 1, 1)
            dataEX_criteria_path = file.path(dirname(path),
                                             paste0("dataEX_criteria_",
                                                    code_letter,
                                                    ".fst"))
            dataEX_criteria_tmp = read_tibble(dataEX_criteria_path)
            metaEX_criteria_path = file.path(dirname(path),
                                             "metaEX_criteria.fst")
            metaEX_criteria_tmp = read_tibble(metaEX_criteria_path)

            data_QUALYPSO_path =
                file.path(dirname(path),
                          paste0(gsub("EX[_]serie",
                                      "_QUALYPSO",
                                      basename(path)),
                                 ".fst"))
            data_QUALYPSO_tmp = read_tibble(data_QUALYPSO_path)

            Pages = sheet_projection_station(
                meta_tmp,
                dataEX_serie_tmp,
                metaEX_serie_tmp,
                dataEX_criteria_tmp,
                metaEX_criteria_tmp,
                data_QUALYPSO_tmp,
                Colors=Colors_of_storylines,
                Colors_light=Colors_light_of_storylines,
                Names=storylines,
                historical=historical,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_info=logo_info,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                Pages=Pages,
                verbose=subverbose)
            break
        }
    }
    return (Pages)
}


add_path = function (x) {
    x = c(x, file.path(resources_path, logo_dir, x["file"]))
    names(x)[length(x)] = "path"
    return (x)
}
logo_info = lapply(logo_info, add_path)
icon_path = file.path(resources_path, icon_dir)



stop()

if (!exists("Shapefiles")) {
    post("### Loading shapefiles")

    if (type == "hydrologie") {
        Code_shp = CodeALL8
    } else if (type == "piezometrie") {
        Code_shp = CodeALL
    }
    Shapefiles = load_shapefile(
        computer_shp_path, Code_shp,
        france_shp_path=france_shp_path,
        bassinHydro_shp_path=bassinHydro_shp_path,
        regionHydro_shp_path=regionHydro_shp_path,
        secteurHydro_shp_path=secteurHydro_shp_path,
        entiteHydro_shp_path=entiteHydro_shp_path,
        entitePiezo_shp_path=entitePiezo_shp_path,
        river_shp_path=river_shp_path,
        river_selection=river_selection,
        river_length=river_length,
        toleranceRel=toleranceRel)
    
    if (type == "hydrologie") {
        Shapefiles$entiteHydro$code =
            codes10_selection[match(Shapefiles$entiteHydro$code,
                                    codes8_selection)]
    }
}


if (add_multi) {
    group_of_HM_to_use = as.list(HM_to_use)
    names(group_of_HM_to_use) = HM_to_use
    if (length(HM_to_use) > 2) {
        group_of_HM_to_use =
            append(group_of_HM_to_use,
                   list(HM_to_use))
        names(group_of_HM_to_use)[
            length(group_of_HM_to_use)] = "Multi-modèle"
    }
} else {
    group_of_HM_to_use = as.list(HM_to_use)
    names(group_of_HM_to_use) = HM_to_use
}


if ('plot_sheet' %in% to_do & !('plot_doc' %in% to_do)) {
    Pages = dplyr::tibble()
    doc_chunk = ""
    doc_title = default_doc_title
    doc_subtitle = NULL
    sheet_list = plot_sheet
}
if ('plot_doc' %in% to_do) {
    Pages = dplyr::tibble()
    doc_chunk = plot_doc$chunk
    doc_title = plot_doc$title
    doc_subtitle = plot_doc$subtitle
    sheet_list = plot_doc$sheet
}


if (doc_chunk == "") {  
    chunkCode = list(codes10_selection)#list(CodeALL10)
    plotCode = list(CodeALL10)
    
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
    
} else if (doc_chunk == "hm") {
    chunkCode = replicate(length(group_of_HM_to_use),
                         codes10_selection,
                         simplify=FALSE)
    names(chunkCode) = names(group_of_HM_to_use)
    plotCode = chunkCode

} else if (doc_chunk == "critere") {
    chunkCode = replicate(length(metaEX_criteria$variable_en),
                         codes10_selection,
                         simplify=FALSE)
    names(chunkCode) = metaEX_criteria$variable_en
    plotCode = chunkCode
}


nChunk = length(chunkCode)

for (i in 1:nChunk) {

    chunk = chunkCode[[i]]
    Code_to_plot = plotCode[[i]]
    chunkname = names(chunkCode)[i]

    doc_title_ns = gsub(" ", "_", doc_title)

    if (!is.null(doc_subtitle)) {
        doc_title_ns = paste0(doc_title_ns,
                              "_",
                              gsub(" ", "_", doc_subtitle))
    }
    
    if (!is.null(chunkname)) {
        doc_chunkname = gsub(" ", "_",
                             gsub(" [-] ", "_",
                                  chunkname))
        today_figdir_leaf = file.path(today_figdir,
                                      mode,
                                      doc_title_ns,
                                      doc_chunkname, "PDF")
    } else if ('plot_doc' %in% to_do) {
        today_figdir_leaf = file.path(today_figdir,
                                      mode,
                                      doc_title_ns,
                                      "PDF")
    } else {
        today_figdir_leaf = file.path(today_figdir,
                                      mode)
    }

    if ("code" %in% names("data")) {
        data_chunk = data[data$code %in% chunk,]
    }
    if (exists("meta")) {
        meta_chunk = meta[meta$code %in% chunk,]
    }
    if (exists("metaEX_criteria")) {
        metaEX_criteria_chunk = metaEX_criteria
    }
    if (exists("metaEX_serie")) {
        metaEX_serie_chunk = metaEX_serie
    }
    
    if (exists("dataEX_criteria")) {
        if (nrow(dataEX_criteria) > 0) {
            dataEX_criteria_chunk = dataEX_criteria[dataEX_criteria$code %in% chunk,]
            if (nrow(dataEX_criteria_chunk) == 0 & nrow(dataEX_criteria) != 0) {
                next
            }
        }
    }
    if (exists("dataEX_serie")) {
        if (length(dataEX_serie) > 0) {
            dataEX_serie_chunk = list()
            for (j in 1:length(dataEX_serie)) {
                dataEX_serie_chunk = append(
                    dataEX_serie_chunk,
                    list(dataEX_serie[[j]][dataEX_serie[[j]]$code %in%
                                          chunk,]))
            }
            names(dataEX_serie_chunk) = names(dataEX_serie)
        }
    }

    
    for (sheet in sheet_list) {
        
        if (sheet == 'sommaire') {
            post("### Plotting summary")
            Pages = tibble(section='Sommaire', subsection=NA, n=1)
        }


## DIAGNOSTIC ________________________________________________________
        if (sheet == 'correlation_matrix') {
            post("### Plotting correlation matrix")

            group_of_HM_to_use = as.list(HM_to_use)
            names(group_of_HM_to_use) = HM_to_use
            if (length(HM_to_use) > 2) {
                group_of_HM_to_use =
                    append(group_of_HM_to_use,
                           list(HM_to_use))
                names(group_of_HM_to_use)[
                    length(group_of_HM_to_use)] = "Multi-modèle"
            }

            Pages = sheet_correlation_matrix(
                dataEX_criteria_chunk,
                metaEX_criteria_chunk,
                HMGroup=group_of_HM_to_use,
                Colors=Colors_of_HM,
                subtitle=doc_subtitle,
                criteria_selection=diag_criteria_selection,
                icon_path=icon_path,
                logo_path=logo_path,
                figdir=today_figdir_leaf,
                Pages=Pages,
                verbose=subverbose)
        }


        if (sheet == 'carte_regime') {
            post("### Plotting regime map")
            sheet_regime_map(meta,
                             icon_path=icon_path,
                             logo_path=logo_path,
                             is_foot=FALSE,
                             # is_secteur=is_secteur,
                             figdir=today_figdir_leaf,
                             Pages=Pages,
                             Shapefiles=Shapefiles,
                             verbose=subverbose)
        }
        
        if (grepl('carte[_]critere', sheet)) {
            post("### Plotting map")
            one_colorbar = FALSE
            if (doc_chunk == "hm") {
                HMSelection = group_of_HM_to_use[chunkname]
                names(HMSelection) = chunkname
            } else {
                HMSelection = group_of_HM_to_use
            }

            if (doc_chunk == "critere") {
                one_colorbar = TRUE
                metaEX_criteria_chunk =
                    metaEX_criteria_chunk[metaEX_criteria_chunk$variable_en == chunkname,]
            } else {
                metaEX_criteria_chunk = metaEX_criteria_chunk
            }

            if (grepl('secteur', sheet)) {
                is_secteur = TRUE
            } else {
                is_secteur = FALSE
            }

            if (grepl('avertissement', sheet)) {
                is_warning = TRUE
            } else {
                is_warning = FALSE
            }

            if (grepl('shape', sheet)) {
                hm_by_shape = TRUE
            } else {
                hm_by_shape = FALSE
            }

            if (grepl('piezo', sheet)) {
                remove_warning_lim = TRUE
            } else {
                remove_warning_lim = FALSE
            }

            if (any(sapply(extract_data, '[[', "name") %in%
                    c('Explore2_criteria_diagnostic_SAFRAN',
                      'Explore2_criteria_more_diagnostic_SAFRAN'))) {

                to_NA = function (X, Code, code_warning) {
                    X[!(Code %in% code_warning)] = NA
                    return (X)
                }
                dataEX_criteria_chunk =
                    mutate(group_by(dataEX_criteria_chunk, HM),
                           across(names(dataEX_criteria_chunk)[
                               !(names(dataEX_criteria_chunk) %in%
                                 c("code", "HM"))],
                               to_NA,
                               code=code, 
                               code_warning=MORDOR_code_warning))
            }

            Pages = sheet_criteria_map(
                dataEX_criteria_chunk,
                metaEX_criteria_chunk,
                meta,
                prob=prob_of_quantile_for_palette,
                HMSelection=HMSelection,
                Colors=Colors_of_HM,
                subtitle=doc_subtitle,
                one_colorbar=one_colorbar,
                icon_path=icon_path,
                logo_path=logo_path,
                is_foot=FALSE,
                is_secteur=is_secteur,
                is_warning=is_warning,
                hm_by_shape=hm_by_shape,
                remove_warning_lim=remove_warning_lim,
                figdir=today_figdir_leaf,
                Pages=Pages,
                Shapefiles=Shapefiles,
                verbose=subverbose)
        }
        
        if (sheet == 'fiche_diagnostic_regime') {
            post("### Plotting sheet diagnostic regime")
            Pages = sheet_diagnostic_regime(
                meta,
                dataEX_criteria_chunk,
                metaEX_criteria_chunk,
                dataEX_serie_chunk,
                Colors=Colors_of_HM,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                Pages=Pages,
                verbose=subverbose)
        }

        if (sheet == 'fiche_diagnostic_piezometre') {
            post("### Plotting sheet diagnostic couche")
            Pages = sheet_diagnostic_couche(
                data_chunk,
                meta_chunk,
                dataEX_criteria_chunk,
                metaEX_criteria_chunk,
                dataEX_serie_chunk,
                Colors=Colors_of_HM,
                icon_path=icon_path,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                Pages=Pages,
                verbose=subverbose)
        }

        if (sheet == 'fiche_diagnostic_region') {
            post("### Plotting sheet diagnostic region")
            Pages = sheet_diagnostic_region(
                meta,
                dataEX_criteria_chunk,
                metaEX_criteria_chunk,
                dataEX_serie_chunk,
                Colors=Colors_of_HM,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                Pages=Pages,
                verbose=subverbose)
        }

        if (sheet == 'fiche_diagnostic_station') {
            post("### Plotting sheet diagnostic station")
            Pages = plot_sheet_diagnostic_station(
                dataEX_criteria_chunk,
                dataEX_serie_chunk,
                Code_to_plot,
                today_figdir_leaf=today_figdir_leaf,
                Pages=Pages,
                subverbose=subverbose)
        }

        if (sheet == 'fiche_precip_ratio') {            
            HMGroup = lapply(HM_to_use, c, "SAFRAN")       
            Pages = sheet_precip_ratio(dataEX_serie_chunk,
                                         HMGroup=HMGroup,
                                         Colors=Colors_of_HM,
                                         refCOL=refCOL,
                                         figdir=today_figdir_leaf,
                                         Pages=Pages,
                                         verbose=subverbose)
        }

        if (sheet == 'stripes') {
            Pages = sheet_stripes(dataEX_serie_chunk,
                                  metaEX_serie_chunk,
                                  meta,
                                  Projections,
                                  prob=prob_of_quantile_for_palette,
                                  period_reference=period_reference,
                                  icon_path=icon_path,
                                  figdir=today_figdir_leaf,
                                  Pages=Pages,
                                  verbose=subverbose)
        }
        

## PROJECTIONS _______________________________________________________
        if (sheet == 'fiche_projection_station') {
            post("### Plotting sheet projection station")
            Pages = plot_sheet_projection_station(
                Code_to_plot,
                today_figdir_leaf=today_figdir_leaf,
                Pages=Pages,
                subverbose=subverbose)
        }

        
    }
    

    if ('sommaire' %in% sheet_list) {
        if (is.null(chunkname) & !is.null(doc_subtitle)) {
            subtitle = doc_subtitle
        } else if (!is.null(chunkname) & is.null(doc_subtitle)) {
            subtitle = chunkname
        } else if (!is.null(chunkname) & !is.null(doc_subtitle)) {
            subtitle = paste0(chunkname, " ", doc_subtitle)
        } else {
            subtitle = ""
        }
        sheet_summary(Pages,
                      title=doc_title,
                      subtitle=subtitle,
                      logo_info=logo_info,
                      figdir=today_figdir_leaf)
    }

    
    if ('plot_doc' %in% to_do) {
        post("### Merging pdf")
        details = file.info(list.files(today_figdir_leaf,
                                       recursive=TRUE,
                                       full.names=TRUE))
        details = details[with(details, order(as.POSIXct(mtime))),]
        listfile_path = rownames(details)

        if ('sommaire' %in% sheet_list) {
            summary_path = listfile_path[length(listfile_path)]
            listfile_path = listfile_path[-length(listfile_path)]
            listfile_path = c(summary_path, listfile_path)
        }

        if (!is.null(chunkname)) {            
            pdf_combine(input=listfile_path,
                        output=file.path(today_figdir,
                                         doc_title_ns,
                                         doc_chunkname,
                                         paste0(doc_chunkname,
                                                ".pdf")))
            
        } else {
            pdf_combine(input=listfile_path,
                        output=file.path(today_figdir,
                                         doc_title_ns,
                                         paste0(doc_title_ns,
                                                    ".pdf")))
        }
    }
}
