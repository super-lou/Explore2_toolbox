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


NetCDF_to_tibble = function (NetCDF_path, type="diag") {
    
    NCdata = ncdf4::nc_open(NetCDF_path)
    
    Date = as.Date(ncdf4::ncvar_get(NCdata, "time"),
                   origin=
                       as.Date(str_extract(
                           ncdf4::ncatt_get(NCdata,
                                            "time")$units,
                           "[0-9]+-[0-9]+-[0-9]+")))

    Date = as.Date(as.character(Date), origin=as.Date("1970-01-01"))

    if (type == "diag") { 
        if ("code" %in% names(NCdata$var)) {
            CodeRaw = ncdf4::ncvar_get(NCdata, "code")
        } else if ("code_hydro" %in% names(NCdata$var)) {
            CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        }
        
    } else if (type == "proj") {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code")
    }

    if ("debit" %in% names(NCdata$var)) {
        QRaw = ncdf4::ncvar_get(NCdata, "debit")
    } else if ("Q" %in% names(NCdata$var)) {
        QRaw = ncdf4::ncvar_get(NCdata, "Q")
    }
    
    ncdf4::nc_close(NCdata)

    CodeOrder = order(CodeRaw)
    Code = CodeRaw[CodeOrder]
    nCode = length(Code)
    nDate = length(Date)
    dimCode = dim(QRaw) == nCode
    if (dimCode[1]) {
        Q_sim = QRaw[CodeOrder,]
    } else if (dimCode[2]) {
        Q_sim = QRaw[, CodeOrder]
    }
    data = tibble(
        Code=rep(Code, each=nDate),
        Date=rep(Date, times=nCode),
        Q_sim=c(t(Q_sim))
    )    
    return (data)
}

convert_diag_data = function (model, data) {

    if (grepl("EROS", model)) {
        names(data) = c("Code", "Date", "Q_sim",
                        "Pl", "ET0", "Ps", "T")
        data$Code = substr(data$Code, 1, 8)

    } else if (grepl("GRSD", model)) {
        names(data) = c("Code", "Date", "Q_sim",
                        "T", "Pl", "ET0", "S")
        data$Date = as.Date(data$Date)
        # data = dplyr::arrange(data, Code)
        data = dplyr::select(data, -"S")
        
    } else if (grepl("J2000", model)) {
        data$Date = as.Date(data$Date)
        names(data) = c("Date", "Code", "Q_sim",
                        "ET0", "T", "Pl", "Ps", "P")
        data = dplyr::select(data, -"P")
        
    } else if (model == "MODCOU") {
        names(data) = c("Code", "Date", "Q_sim")

    } else if (model == "MORDOR-SD") {
        data$Date = as.Date(data$Date)
        names(data) = c("Code", "Date", "Q_sim",
                        "Pl", "Ps", "T", "ET0")
        
    } else if (model == "MORDOR-TS") {
        data$Date = as.Date(data$Date)
        names(data) = c("Code", "Date", "Q_sim",
                        "T", "Pl", "Ps", "ET0")
        
    } else if (model == "SMASH") {
        names(data) = c("Code", "Date", "Q_sim",
                        "T", "Pl", "ET0", "Ps")
    }

    data = dplyr::bind_cols(Model=model, data)
    
    return (data)
}


read_shp = function (path) {
    shp = st_read(path)
    shp = st_transform(shp, 2154) 
    return (shp)
}


get_select = function (dataEXind, metaEXind, select="") {
    if (!any(select == "all")) {
        select = paste0("(",
                        paste0(c("Model", "Code", select),
                               collapse=")|("), ")")

        select = gsub("[{]", "[{]", select)
        select = gsub("[}]", "[}]", select)
        select = gsub("[_]", "[_]", select)
        select = gsub("[,]", "[,]", select)

        select = names(dataEXind)[grepl(select,
                                        names(dataEXind))]
        
        dataEXind = dplyr::select(dataEXind, select)
        metaEXind = metaEXind[metaEXind$var %in% select,]
    }
    res = list(metaEXind=metaEXind, dataEXind=dataEXind)
    return (res)
}


# W = find_Warnings(dataEXind, metaEXind, codeLight="A4362030", save=FALSE)
# W[grepl("hydrologique", W$warning),]
find_Warnings = function (dataEXind, metaEXind, lim=5,
                          resdir="", codeLight=NULL, save=FALSE) {

    tick_range = list(
        "^KGE"=c(0.5, 1),
        "(^epsilon.*)|(^alpha)"=c(0.5, 2),
        "(^Biais$)|(^Q[[:digit:]]+$)|([{]t.*[}])"=c(-1, 1))

    all_model = "<b>L'ensemble des modèles</b>"
    
    tick_text = list(
        
        "^KGE"=c(
            ":reproduit/reproduisent: mal les observations.",
            ":reproduit/reproduisent: correctement les observations.",
            ":reproduit/reproduisent: mal les observations."),
        
        "^Biais$"=c(
            ":a/ont: un biais positif important.",
            ":a/ont: un biais acceptable.",
            ":a/ont: un biais négatif important."),
        
        "^epsilon.*P.*DJF"=c(
            ":n'est/ne sont: pas assez sensible aux variations de précipitations hivernales.",
            ":a/ont: une bonne sensibilité aux variations de précipitations hivernales.",
            ":est/sont: trop sensible aux variations de précipitations hivernales."),

        "^epsilon.*P.*JJA"=c(
            ":n'est/ne sont: pas assez sensible aux variations de précipitations estivales.",
            ":a/ont: une bonne sensibilité aux variations de précipitations estivales.",
            ":est/sont: trop sensible aux variations de précipitations estivales."),

        "^epsilon.*T.*DJF"=c(
            ":n'est/ne sont: pas assez sensible aux variations de température en hiver.",
            ":a/ont: une bonne sensibilité aux variations de température en hiver.",
            ":est/sont: trop sensible aux variations de température en hiver."),

        "^epsilon.*T.*JJA"=c(
            ":n'est/ne sont: pas assez sensible aux variations de température en été.",
            ":a/ont: une bonne sensibilité aux variations de température en été.",
            ":est/sont: trop sensible aux variations de température en été."),

        "^Q10$"=c(
            ":atténue/atténuent: l'intensité des hautes eaux.",
            ":restitue/restituent: bien l'intensité des hautes eaux.",
            ":accentue/accentuent: l'intensité des hautes eaux."),

        "tQJXA"=c(
            ":produit/produisent: des crues trop tôt dans l'année.",
            ":restitue/restituent: bien la temporalité annuelle des crues.",
            ":produit/produisent: des crues trop tard dans l'année."),

        "^alphaCDC$"=c(
            ":atténue/atténuent: le régime des moyennes eaux.",
            ":restitue/restituent: bien le régime des moyennes eaux.",
            ":accentue/accentuent: le régime des moyennes eaux."),

        "^alphaQA$"=c(
            ":accentue/accentuent: la baisse au cours du temps du débit moyen annuel.",
            ":restitue/restituent: bien l'évolution au cours du temps du débit moyen annuel.",
            ":accentue/accentuent: la hausse au cours du temps du débit moyen annuel."),

        "^Q90$"=c(
            ":accentue/accentuent: l'intensité des basses eaux.",
            ":restitue/restituent: bien l'intensité des basses eaux.",
            ":atténue/atténuent: l'intensité des basses eaux."),

        "tVCN10"=c(
            ":produit/produisent: des étiages trop tôt dans l'année.",
            ":restitue/restituent: bien la temporalité annuelle des étiages.",
            ":produit/produisent: des étiages trop tard dans l'année."))


    if (is.null(codeLight)) {
        Code = levels(factor(dataEXind$Code))  
    } else {
        Code = codeLight
    }
    nCode = length(Code)

    Model = levels(factor(dataEXind$Model))
    nModel = length(Model)
    
    Warnings = dplyr::tibble()
    
    for (k in 1:nCode) {

        if ((k-1) %% 10 == 0) {
            print(paste0(round(k/nCode*100), " %"))
        }
        
        code = Code[k]

        dataEXind_code = dataEXind[dataEXind$Code == code,]
        
        logicalCol = names(dataEXind_code)[sapply(dataEXind_code, class) == "logical"]
        dataEXind_code = dataEXind_code[!(names(dataEXind_code) %in% logicalCol)]
        metaEXind = metaEXind[!(metaEXind$var %in% logicalCol),]
        
        vars2keep = names(dataEXind_code)
        vars2keep = vars2keep[!grepl("([_]obs)|([_]sim)", vars2keep)]

        dataEXind_code = dplyr::mutate(dataEXind_code,
                                       dplyr::across(where(is.logical),
                                                     as.numeric),
                                       .keep="all")

        dataEXind_code = dplyr::select(dataEXind_code, vars2keep)

        Model = levels(factor(dataEXind_code$Model))
        nModel = length(Model)

        dataEXind_code_tmp = dataEXind_code
        dataEXind_code_tmp = dplyr::select(dataEXind_code_tmp, -c(Code, Model))

        matchVar = match(names(dataEXind_code_tmp), metaEXind$var)
        matchVar = matchVar[!is.na(matchVar)]
        dataEXind_code_tmp = dataEXind_code_tmp[matchVar]

        nameCol = names(dataEXind_code_tmp)
        Var = nameCol
        nVar = length(Var)
        
        Lines = dplyr::tibble()
        
        for (i in 1:nVar) {
            var = Var[i]
            x = dataEXind_code[[var]]

            range = unlist(tick_range[sapply(names(tick_range), grepl, var)],
                           use.names=FALSE)
            text = tick_text[sapply(names(tick_text), grepl, var)][[1]]

            for (j in 1:nModel) {
                model = Model[j]
                x = dataEXind_code[dataEXind_code$Model == model,][[var]]
                if (is.na(x)) {
                    next 
                }

                low = c(-Inf, range)
                up = c(range, Inf)
                id = which(low <= x & x <= up)
                niveau = (id-2)
                
                if (nrow(Lines) == 0) {
                    Lines = dplyr::tibble(var=var,
                                          model=model,
                                          niveau=niveau,
                                          text=text[id])
                } else {
                    Lines =
                        dplyr::bind_rows(Lines,
                                         dplyr::tibble(var=var,
                                                       model=model,
                                                       niveau=niveau,
                                                       text=text[id]))
                }
            }
        }
        stat_Lines =
            dplyr::summarise(
                       dplyr::group_by(Lines, var, niveau),
                       n=dplyr::n(),
                       model=list(model[niveau==dplyr::cur_group()$niveau]),
                       text=text[1],
                       .groups="drop")

        for (i in 1:nrow(stat_Lines)) {

            line = stat_Lines[i,]
            
            if (line$n == nModel) {
                line$text =
                    paste0(all_model, " ",
                           gsub("([:].*[/])|([:])",
                                "",
                                line$text))
            } else {
                model = paste0("<b>",
                               unlist(line$model),
                               "</b>")
                if (line$n == 1) {
                    line$text =
                        paste0(model, " ",
                               gsub("([/].*[:])|([:])",
                                    "",
                                    line$text))
                } else {
                    model = paste0(
                        paste0(model[-length(model)],
                               collapse=", "),
                        " et ", model[length(model)])
                    line$text =
                        paste0(model, " ",
                               gsub("([:].*[/])|([:])",
                                    "",
                                    line$text))
                }
            }
            stat_Lines[i,] = line
        }

        line_KGE = stat_Lines[stat_Lines$var == "KGEracine",]
        line_Biais = stat_Lines[stat_Lines$var == "Biais",]

        if (nrow(line_KGE) == 1 & nrow(line_Biais) == 1) {            
            if (line_KGE$niveau == 0 & line_Biais$niveau == 0) {
                text = "<b>Tous les modèles hydrologiques</b> semblent restituer de manière acceptable le régime."
            } else {
                text = "<b>Aucun modèle hydrologique</b> ne semble restituer de manière acceptable le régime."
            }

        } else {            
            model_KGE_OK = unlist(line_KGE$model[line_KGE$niveau == 0])
            model_Biais_OK =
                unlist(line_Biais$model[line_Biais$niveau == 0])
            model_OK = c(model_KGE_OK, model_Biais_OK)
            model_OK = model_OK[duplicated(model_OK)]

            model_KGE_NOK = unlist(line_KGE$model[line_KGE$niveau != 0])
            model_Biais_NOK =
                unlist(line_Biais$model[line_Biais$niveau != 0])
            model_NOK = c(model_KGE_NOK, model_Biais_NOK)
            model_NOK = model_NOK[!duplicated(model_NOK)]

            if (length(model_OK) == 1) {
                text = paste0("Les modèles hydrologiques ont des difficultés à reproduire le régime sauf ", model_OK)

            } else {
                if (length(model_NOK) == 1) {
                    model = model_NOK
                } else {
                    model = paste0(
                        paste0(model_NOK[-length(model_NOK)],
                               collapse=", "),
                        " et ", model_NOK[length(model_NOK)])
                }
                text = paste0("Les modèles hydrologiques semblent restituer de manière acceptable le régime sauf ", model)
            }
        }
        Warnings_code = stat_Lines$text[stat_Lines$niveau != 0]
        Warnings_code = c(text, Warnings_code)

        if (nrow(Warnings) == 0) {
            Warnings = dplyr::tibble(Code=code,
                                     warning=Warnings_code)
        } else {
            Warnings =
                dplyr::bind_rows(Warnings,
                                 dplyr::tibble(Code=code,
                                               warning=Warnings_code))
        }
    }

    if (save) {
        write_tibble(Warnings,
                     filedir=resdir,
                     filename="Warnings.fst")
    }
    
    return (Warnings)
}
