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



get_warning_Lines = function (dataEXind, metaEXind, codeLight) {

    logicalCol = names(dataEXind)[sapply(dataEXind, class) == "logical"]
    dataEXind = dataEXind[!(names(dataEXind) %in% logicalCol)]
    metaEXind = metaEXind[!(metaEXind$var %in% logicalCol),]
    
    vars2keep = names(dataEXind)
    vars2keep = vars2keep[!grepl("([_]obs)|([_]sim)", vars2keep)]

    dataEXind = dplyr::mutate(dataEXind,
                              dplyr::across(where(is.logical),
                                            as.numeric),
                              .keep="all")

    dataEXind = dplyr::select(dataEXind, vars2keep)

    Model = levels(factor(dataEXind$Model))
    nModel = length(Model)

    dataEXind_tmp = dataEXind
    dataEXind_tmp = dplyr::select(dataEXind_tmp, -c(Code, Model))

    matchVar = match(names(dataEXind_tmp), metaEXind$var)
    matchVar = matchVar[!is.na(matchVar)]
    dataEXind_tmp = dataEXind_tmp[matchVar]

    nameCol = names(dataEXind_tmp)
    Var = nameCol
    nVar = length(Var)
    
    tick_perfect = c(
        "(KGE)|(^epsilon)|(^alpha)"=1,
        "(^Biais$)|(^Q[[:digit:]]+$)|([{]t.*[}])"=0)

    tick_rel = list(
        "^KGE"=FALSE,
        "^Biais$"=FALSE,
        "(^epsilon.*)|(^alphaQA$)|([{]t.*[}])"=TRUE,
        "(^Q[[:digit:]]+$)|(^alphaCDC$)"=TRUE)
    

    # abs(res - perfect) si que +
    # res - perfect si + et -
    tick_diff = list(
        "(^KGE)|(^epsilon.*)|(^alphaQA$)|([{]t.*[}])"=c(0.2, 0.4),
        "(^Biais$)|(^Q[[:digit:]]+$)|(^alphaCDC$)"=c(0.1, 0.2))


    # if rel [1]+ [2]-
    tick_text = list(
        
        "^KGE"=c(
            "reproduit/reproduisent correctement les observations.",
            "reproduit/reproduisent partielement les observations.",
            "reproduit/reproduisent mal les observations."),
        
        "^Biais$"=c(
            "a/ont un biais faible.",
            "a/ont un biais.",
            "a/ont un biais important."),
        
        "^epsilon.*P.*DJF"=list(
            c("a/ont une bonne sensibilité aux variations de précipitations hivernales.",
              "est/sont un peu trop sensible aux variations de précipitations hivernales.",
              "est/sont trop sensible aux variations de précipitations hivernales."),
            c("a/ont une bonne sensibilité aux variations de précipitations hivernales.",
              "est/sont peu sensible aux variations de précipitations hivernales.",
              "n'/ne est/sont pas assez sensible aux variations de précipitations hivernales.")),

        "^epsilon.*P.*JJA"=list(
            c("a/ont une bonne sensibilité aux variations de précipitations estivales.",
              "est/sont un peu trop sensible aux variations de précipitations estivales.",
              "est/sont trop sensible aux variations de précipitations estivales."),            
            c("a/ont une bonne sensibilité aux variations de précipitations estivales.",
              "est/sont peu sensible aux variations de précipitations estivales.",
              "n'/ne est/sont pas assez sensible aux variations de précipitations estivales.")),

        "^epsilon.*T.*DJF"=list(
            c("a/ont une bonne sensibilité aux variations de température en hiver.",
              "est/sont un peu trop sensible aux variations de température en hiver.",
              "est/sont trop sensible aux variations de température en hiver."),

            c("a/ont une bonne sensibilité aux variations de température en hiver.",
              "est/sont peu sensible aux variations de température en hiver.",
              "n'/ne est/sont pas assez sensible aux variations de température en hiver.")),

        "^epsilon.*T.*JJA"=list(
            c("a/ont une bonne sensibilité aux variations de température en été.",
              "est/sont un peu trop sensible aux variations de température en été.",
              "est/sont trop sensible aux variations de température en été."),
            c("a/ont une bonne sensibilité aux variations de température en été.",
              "est/sont peu sensible aux variations de température en été.",
              "n'/ne est/sont pas assez sensible aux variations de température en été.")),

        "^Q10$"=list(
            c("restitue/restituent bien l'intensité des hautes eaux.",
              "accentue/accentuent l'intensité des hautes eaux.",
              "accentue/accentuent trop l'intensité des hautes eaux."),
            c("restitue/restituent bien l'intensité des hautes eaux.",
              "atténue/atténuent l'intensité des hautes eaux.",
              "atténue/atténuent trop l'intensité des hautes eaux.")),

        "tQJXA"=list(
            c("restitue/restituent bien la temporalité annuelle des crues.",
              "produit/produisent des crues plus tard dans l'année.",
              "produit/produisent des crues trop tard dans l'année."),
            c("restitue/restituent bien la temporalité annuelle des crues.",
              "produit/produisent des crues plus tôt dans l'année.",
              "produit/produisent des crues trop tôt dans l'année.")),

        "^alphaCDC$"=list(
            c("restitue/restituent bien le régime des moyennes eaux.",
              "accentue/accentuent le régime des moyennes eaux.",
              "accentue/accentuent trop le régime des moyennes eaux."),
            c("restitue/restituent bien le régime des moyennes eaux.",
              "atténue/atténuent le régime des moyennes eaux.",
              "atténue/atténuent trop le régime des moyennes eaux.")),

        "^alphaQA$"=list(
            c("restitue/restituent bien l'évolution au cours du temps du débit moyen annuel.",
              "accentue/accentuent la hausse au cours du temps du débit moyen annuel.",
              "accentue/accentuent trop la hausse au cours du temps du débit moyen annuel."),
            c("restitue/restituent bien l'évolution au cours du temps du débit moyen annuel.",
              "accentue/accentuent la baisse au cours du temps du débit moyen annuel.",
              "accentue/accentuent trop la baisse au cours du temps du débit moyen annuel.")),

        "^Q90$"=list(
            c("restitue/restituent bien l'intensité des basses eaux.",
              "atténue/atténuent l'intensité des basses eaux.",
              "atténue/atténuent trop l'intensité des basses eaux."),
            c("restitue/restituent bien l'intensité des basses eaux.",
              "accentue/accentuent l'intensité des basses eaux.",
              "accentue/accentuent trop l'intensité des basses eaux.")),

        "tVCN10"=list(
            c("restitue/restituent bien la temporalité annuelle des étiages.",
              "produit/produisent des étiages plus tard dans l'année.",
              "produit/produisent des étiages trop tard dans l'année."),
            c("restitue/restituent bien la temporalité annuelle des étiages.",
              "produit/produisent des étiages plus tôt dans l'année.",
              "produit/produisent des étiages trop tôt dans l'année.")))

    
    Lines = dplyr::tibble()
    for (i in 1:nVar) {
        var = Var[i]
        x = dataEXind[dataEXind$Code == codeLight,][[var]]

        per = tick_perfect[sapply(names(tick_perfect), grepl, var)]
        names(per) = NULL
        dif = unlist(tick_diff[sapply(names(tick_diff), grepl, var)], use.names=FALSE)
        rel = unlist(tick_rel[sapply(names(tick_rel), grepl, var)], use.names=FALSE)
        text = tick_text[sapply(names(tick_text), grepl, var)][[1]]

        for (j in 1:nModel) {
            model = Model[j]
            x = dataEXind[dataEXind$Model == model &
                          dataEXind$Code == codeLight,][[var]]

            if (rel) {
                ec = x - per
            } else {
                ec = abs(x - per)
            }

            if (rel) {
                if (ec > 0) {
                    text_model = unlist(text[[1]])
                    id = min(which(ec <= c(dif, 10**99)))
                } else {
                    text_model = unlist(text[[2]])
                    id = min(which(ec >= c(-dif, -10**99)))
                }
            } else {
                text_model = text
                id = min(which(ec <= c(dif, 10**99)))
            }

            if (nrow(Lines) == 0) {
                Lines = dplyr::tibble(var=var,
                                      model=model,
                                      niveau=id,
                                      line=text_model[id])
            } else {
                Lines =
                    dplyr::bind_rows(Lines,
                                     dplyr::tibble(var=var,
                                                   model=model,
                                                   niveau=id,
                                                   line=text_model[id]))
            }
        }
    }

    stat_Lines =
        dplyr::summarise(
                   dplyr::group_by(Lines, var, niveau),
                   n=dplyr::n(),
                   model=list(model[niveau==dplyr::cur_group()$niveau]),
                   .groups="drop")
    
    return (Lines)
}
