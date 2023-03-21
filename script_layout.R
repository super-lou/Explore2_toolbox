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


plot_sheet_diagnostic_station = function (dataEXind_to_plot,
                                          dataEXserie_to_plot,
                                          Code_to_plot,
                                          today_figdir_leaf,
                                          df_page=NULL,
                                          verbose=FALSE) {
    Paths = list.files(file.path(resdir, read_saving),
                       pattern="^data[_].*[.]fst$",
                       include.dirs=TRUE,
                       full.names=TRUE)
    letterPaths = gsub("(.*[_])|([[:digit:]][.]fst)", "", Paths)
    Paths = Paths[letterPaths %in% substr(Code_to_plot, 1, 1)]
    for (path in Paths) {
        data = read_tibble(filepath=path) 
        Code_tmp = levels(factor(data$Code))

        if (any(Code_tmp %in% Code_to_plot)) {
            data = data[data$Code %in% Code_to_plot,]
            df_page = sheet_diagnostic_station(
                data,
                meta,
                dataEXind_to_plot,
                metaEXind,
                dataEXserie_to_plot,
                Colors=Colors_of_models,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=verbose)
        }
    }
    return (df_page)
}


logo_path = load_logo(resources_path, logo_dir, logo_to_show)
icon_path = file.path(resources_path, icon_dir)


if (!exists("Shapefiles")) {
    post("### Loading shapefiles")
    Shapefiles = load_shapefile(
        computer_data_path, CodeALL,
        france_dir, france_file,
        bassinHydro_dir, bassinHydro_file,
        regionHydro_dir, regionHydro_file,
        entiteHydro_dir, entiteHydro_file, entiteHydro_coord,
        river_dir, river_file, river_selection=river_selection,
        toleranceRel=toleranceRel)
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
    chunkCode = list(CodeALL)

} else if (doc_chunk == "all") {
    chunkCode = list(CodeALL)
    
} else if (doc_chunk == "region") {
    letter = factor(substr(CodeALL, 1, 1))
    chunkCode = split(CodeALL, letter)
    names(chunkCode) = paste0(iRegHydro()[names(chunkCode)],
                              " - ", levels(letter))
}

nChunk = length(chunkCode)

for (i in 1:nChunk) {

    Code_to_plot = chunkCode[[i]]
    chunkname = names(chunkCode)[i]

    doc_name_ns = gsub(" ", "_", doc_name)
    
    if (!is.null(chunkname)) {
        doc_chunkname = paste0(doc_name_ns, "_",
                               gsub(" ", "_",
                                    gsub(" [-] ", "_",
                                         chunkname)))
        today_figdir_leaf = file.path(today_figdir,
                                      doc_chunkname, "PDF")
    } else if ('plot_doc' %in% to_do) {
        today_figdir_leaf = file.path(today_figdir, doc_name_ns,
                                      "PDF")
    } else {
        today_figdir_leaf = today_figdir
    }

    dataEXind_to_plot = dataEXind[dataEXind$Code %in% Code_to_plot,]
    if (nrow(dataEXind_to_plot) == 0) {
        next
    }
    dataEXserie_to_plot = list()
    for (j in 1:length(dataEXserie)) {
        dataEXserie_to_plot = append(
            dataEXserie_to_plot,
            list(dataEXserie[[j]][dataEXserie[[j]]$Code %in%
                                  Code_to_plot,]))
    }
    names(dataEXserie_to_plot) = names(dataEXserie)
    
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
                    "Multi-Model"=
                        c("CTRIP", "EROS", "GRSD", "J2000", "SIM2",
                          "MORDOR-SD", "MORDOR-TS", "ORCHIDEE", "SMASH")
                )
            df_page = sheet_correlation_matrix(
                dataEXind_to_plot,
                metaEXind,
                ModelGroup=group_of_models_to_use,
                icon_path=icon_path,
                logo_path=logo_path,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=verbose)
        }

        if (sheet == 'diagnostic_regime') {
            post("### Plotting sheet diagnostic regime")
            df_page = sheet_diagnostic_regime(
                meta,
                dataEXind_to_plot,
                metaEXind,
                dataEXserie_to_plot,
                Colors=Colors_of_models,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=verbose)
        }


        if (sheet == 'diagnostic_region') {
            post("### Plotting sheet diagnostic region")
            df_page = sheet_diagnostic_region(
                meta,
                dataEXind_to_plot,
                metaEXind,
                dataEXserie_to_plot,
                Colors=Colors_of_models,
                icon_path=icon_path,
                Warnings=Warnings,
                logo_path=logo_path,
                Shapefiles=Shapefiles,
                figdir=today_figdir_leaf,
                df_page=df_page,
                verbose=verbose)
        }

        if (sheet == 'diagnostic_station') {
            post("### Plotting sheet diagnostic station")
            df_page = plot_sheet_diagnostic_station(
                dataEXind_to_plot,
                dataEXserie_to_plot,
                Code_to_plot,
                today_figdir_leaf=today_figdir_leaf,
                df_page=df_page,
                verbose=verbose)
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


# if ('plot_doc' %in% to_do) {

# }





# if ('diagnostic_station' %in% plot_sheet |
#     'diagnostic_region' %in% plot_sheet |
#     'diagnostic_regime' %in% plot_sheet) {
#     if (!exists("Shapefiles")) {
#         print("### Loading shapefiles")
#         Shapefiles = load_shapefile(
#             computer_data_path, CodeALL,
#             france_dir, france_file,
#             bassinHydro_dir, bassinHydro_file,
#             regionHydro_dir, regionHydro_file,
#             entiteHydro_dir, entiteHydro_file, entiteHydro_coord,
#             river_dir, river_file, river_selection=river_selection,
#             toleranceRel=toleranceRel)
#     }
# }


# if ('summary' %in% plot_sheet) {
#     print("### Plotting summary")
#     df_page = tibble(section='Sommaire', subsection=NA, n=1)
# } else {
#     df_page = tibble()
# }

# if ('diagnostic_matrix' %in% plot_sheet) {
#     print("### Plotting correlation matrix")
#     df_page = sheet_diagnostic_matrix(
#         dataEXind,
#         metaEXind,
#         ModelGroup=group_of_models_to_use,
#         icon_path=icon_path,
#         logo_path=logo_path,
#         figdir=file.path(today_figdir_leaf,
#                          "diagnostic_diagnostic_matrix"),
#         df_page=df_page)
# }

# if ('diagnostic_regime' %in% plot_sheet) {
#     print("### Plotting sheet diagnostic regime")
#     df_page = sheet_diagnostic_regime(
#         meta,
#         dataEXind,
#         metaEXind,
#         dataEXserie,
#         Colors=Colors_of_models,
#         ModelGroup=group_of_models_to_use,
#         icon_path=icon_path,
#         Warnings=Warnings,
#         logo_path=logo_path,
#         Shapefiles=Shapefiles,
#         figdir=file.path(today_figdir_leaf,
#                          "diagnostic_regime"),
#         df_page=df_page)
# }

# if ('diagnostic_region' %in% plot_sheet) {
#     print("### Plotting sheet diagnostic region")
#     df_page = sheet_diagnostic_region(
#         meta,
#         dataEXind,
#         metaEXind,
#         dataEXserie,
#         Colors=Colors_of_models,
#         ModelGroup=group_of_models_to_use,
#         icon_path=icon_path,
#         Warnings=Warnings,
#         logo_path=logo_path,
#         Shapefiles=Shapefiles,
#         figdir=file.path(today_figdir_leaf,
#                          "diagnostic_region"),
#         df_page=df_page)
# }

# if ('diagnostic_station' %in% plot_sheet) {
#     print("### Plotting sheet diagnostic station")
#     df_page = plot_sheet_diagnostic_station(df_page=df_page)
# }

# if ('summary' %in% plot_sheet) {
#     summary(df_page,
#                   title="title", subtitle="subtitle",
#                   logo_path=logo_path,
#                   figdir=today_figdir_leaf)
# }

# # Combine independant pages into one PDF
# details = file.info(list.files(today_figdir_leaf,
#                                recursive=TRUE,
#                                full.names=TRUE))
# details = details[with(details, order(as.POSIXct(mtime))),]
# listfile_path = rownames(details)

# if ('summary' %in% plot_sheet) {
#     summary_path = listfile_path[length(listfile_path)]
#     listfile_path = listfile_path[-length(listfile_path)]
#     listfile_path = c(summary_path, listfile_path)
# }

# if (pdf_chunk == 'all') {
#     print("### Merging pdf")
#     pdf_combine(input=listfile_path,
#                 output=doc_path)
# }
