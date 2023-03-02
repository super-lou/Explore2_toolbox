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


NetCDF_to_tibble = function (NetCDF_path, model="", type="diag") {
    
    NCdata = ncdf4::nc_open(NetCDF_path)

    Date = as.Date(ncdf4::ncvar_get(NCdata, "time"),
                   origin=
                       as.Date(str_extract(
                           ncdf4::ncatt_get(NCdata,
                                            "time")$units,
                           "[0-9]+-[0-9]+-[0-9]+")))

    Date = as.Date(as.character(Date), origin=as.Date("1970-01-01"))

    if (grepl("CTRIP", model)) {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        QRaw = ncdf4::ncvar_get(NCdata, "Q")
        ncdf4::nc_close(NCdata)
        
        CodeOrder = order(CodeRaw)
        Code = CodeRaw[CodeOrder]
        Q_sim = QRaw[CodeOrder,]

        nCode = length(Code)
        nDate = length(Date)
        data = dplyr::tibble(Code=rep(Code, each=nDate),
                             Date=rep(Date, times=nCode),
                             Q_sim=c(t(Q_sim)))
        
    } else if (grepl("EROS", model)) {
        NULL
        
    } else if (grepl("GRSD", model)) {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        QRaw = ncdf4::ncvar_get(NCdata, "Q")
        SRaw = ncdf4::ncvar_get(NCdata, "surface_model")
        PRaw = ncdf4::ncvar_get(NCdata, "P")
        TRaw = ncdf4::ncvar_get(NCdata, "T")
        ET0Raw = ncdf4::ncvar_get(NCdata, "ET0")
        ncdf4::nc_close(NCdata)
        
        CodeOrder = order(CodeRaw)
        Code = CodeRaw[CodeOrder]
        Q_sim = QRaw[CodeOrder,]
        P = PRaw[CodeOrder,]
        T = TRaw[CodeOrder,]
        ET0 = ET0Raw[CodeOrder,]

        nCode = length(Code)
        nDate = length(Date)
        data = dplyr::tibble(Code=rep(Code, each=nDate),
                             Date=rep(Date, times=nCode),
                             Q_sim=c(t(Q_sim)),
                             P=c(t(P)),
                             T=c(t(T)),
                             ET0=c(t(ET0)))
        
    } else if (grepl("J2000", model)) {
        NULL
        
    } else if (model == "SIM2") {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        QRaw = ncdf4::ncvar_get(NCdata, "debit")
        SRaw = ncdf4::ncvar_get(NCdata, "surface_mod")
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
        data = dplyr::tibble(
            Code=rep(Code, each=nDate),
            Date=rep(Date, times=nCode),
            Q_sim=c(t(Q_sim))
        )    
        return (data)
    
    } else if (model == "MORDOR-SD") {
        NULL
        
    } else if (model == "MORDOR-TS") {
        NULL
        
    } else if (model == "ORCHIDEE") {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        QRaw = ncdf4::ncvar_get(NCdata, "Q")
        SRaw = ncdf4::ncvar_get(NCdata, "surface_model")
        PRaw = ncdf4::ncvar_get(NCdata, "P")
        PlRaw = ncdf4::ncvar_get(NCdata, "Pl")
        PsRaw = ncdf4::ncvar_get(NCdata, "Ps")
        TRaw = ncdf4::ncvar_get(NCdata, "T")
        ncdf4::nc_close(NCdata)
        
        CodeOrder = order(CodeRaw)
        Code = CodeRaw[CodeOrder]
        Q_sim = QRaw[CodeOrder,]
        S = SRaw[CodeOrder]
        P = PRaw[CodeOrder,]
        Pl = PlRaw[CodeOrder,]
        Ps = PsRaw[CodeOrder,]
        T = TRaw[CodeOrder,] - 273.15

        nCode = length(Code)
        nDate = length(Date)
        data = dplyr::tibble(Code=rep(Code, each=nDate),
                             Date=rep(Date, times=nCode),
                             Q_sim=c(t(Q_sim)),
                             P=c(t(P)),
                             Pl=c(t(Pl)),
                             Ps=c(t(Ps)),
                             T=c(t(T)))

    } else if (model == "SMASH") {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        QRaw = ncdf4::ncvar_get(NCdata, "Q")
        SRaw = ncdf4::ncvar_get(NCdata, "surface_model")
        PRaw = ncdf4::ncvar_get(NCdata, "P")
        PlRaw = ncdf4::ncvar_get(NCdata, "Pl")
        PsRaw = ncdf4::ncvar_get(NCdata, "Ps")
        TRaw = ncdf4::ncvar_get(NCdata, "T")
        ET0Raw = ncdf4::ncvar_get(NCdata, "ET0")
        ncdf4::nc_close(NCdata)
        
        CodeOrder = order(CodeRaw)
        Code = CodeRaw[CodeOrder]
        Q_sim = QRaw[CodeOrder,]
        S = SRaw[CodeOrder]
        P = PRaw[CodeOrder,]
        Pl = PlRaw[CodeOrder,]
        Ps = PsRaw[CodeOrder,]
        T = TRaw[CodeOrder,]
        ET0 = ET0Raw[CodeOrder,]
        
        nCode = length(Code)
        nDate = length(Date)
        data = dplyr::tibble(Code=rep(Code, each=nDate),
                             Date=rep(Date, times=nCode),
                             Q_sim=c(t(Q_sim)),
                             P=c(t(P)),
                             Pl=c(t(Pl)),
                             Ps=c(t(Ps)),
                             T=c(t(T)),
                             ET0=c(t(ET0)))
    }
    
    return (data)
}

convert_diag_data = function (model, data) {

    if (grepl("CTRIP", model)) {
        NULL
            
    } else if (grepl("EROS", model)) {
        names(data) = c("Code", "Date", "Q_sim",
                        "Pl", "ET0", "Ps", "T")
        data$P = data$Pl + data$Ps
        data$Code = substr(data$Code, 1, 8)

    } else if (grepl("GRSD", model)) {
        NULL
        
    } else if (grepl("J2000", model)) {
        data$Date = as.Date(data$Date)
        names(data) = c("Date", "Code", "Q_sim",
                        "ET0", "T", "Pl", "Ps", "P")
        data = dplyr::select(data, -"P")
        
    } else if (model == "SIM2") {
        NULL
        
    } else if (model == "MORDOR-SD") {
        data$Date = as.Date(data$Date)
        names(data) = c("Code", "Date", "Q_sim",
                        "Pl", "Ps", "T", "ET0")
        data$P = data$Pl + data$Ps
        
    } else if (model == "MORDOR-TS") {
        data$Date = as.Date(data$Date)
        names(data) = c("Code", "Date", "Q_sim",
                        "T", "Pl", "Ps", "ET0")
        data$P = data$Pl + data$Ps

    } else if (model == "ORCHIDEE") {
        NULL

    } else if (model == "SMASH") {
        NULL
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


find_Warnings = function (dataEXind, metaEXind,
                          resdir="", codeLight=NULL, save=FALSE) {

    tick_range = list(
        "^KGE"=c(0.5, 1),
        "^Biais$"=c(-0.2, 0.2),
        "(^epsilon.*)|(^alpha)"=c(0.5, 2),
        "(^Q[[:digit:]]+$)|([{]t.*[}])"=c(-1, 1),
        "^RAT"=c(TRUE, FALSE))

    all_model = "<b>L'ensemble des modèles</b>"
    
    tick_line = list(
        
        "^KGE"=c(
            ":reproduit/reproduisent: mal les observations.",
            ":reproduit/reproduisent: correctement les observations.",
            ":reproduit/reproduisent: mal les observations."),
        
        "^Biais$"=c(
            ":a/ont: un biais négatif important.",
            ":a/ont: un biais acceptable.",
            ":a/ont: un biais positif important."),

        "^epsilon.*T.*DJF"=c(
            ":n'est/ne sont: pas assez sensible aux variations de température en hiver.",
            ":a/ont: une sensibilité acceptable aux variations de température en hiver.",
            ":est/sont: trop sensible aux variations de température en hiver."),

        "^epsilon.*T.*JJA"=c(
            ":n'est/ne sont: pas assez sensible aux variations de température en été.",
            ":a/ont: une sensibilité acceptable aux variations de température en été.",
            ":est/sont: trop sensible aux variations de température en été."),

        "^epsilon.*P.*DJF"=c(
            ":n'est/ne sont: pas assez sensible aux variations de précipitations hivernales.",
            ":a/ont: une sensibilité acceptable aux variations de précipitations hivernales.",
            ":est/sont: trop sensible aux variations de précipitations hivernales."),

        "^epsilon.*P.*JJA"=c(
            ":n'est/ne sont: pas assez sensible aux variations de précipitations estivales.",
            ":a/ont: une sensibilité acceptable aux variations de précipitations estivales.",
            ":est/sont: trop sensible aux variations de précipitations estivales."),

        "^Q10$"=c(
            ":sous-estime/sous-estiment: les débits en hautes eaux.",
            ":simule/simulent: de manière correcte les débits en hautes eaux.",
            ":surestime/surestiment: les débits en hautes eaux."),

        "tQJXA"=c(
            ":produit/produisent: des crues trop tôt dans l'année.",
            ":simule/simulent: de manière correcte la temporalité annuelle des crues.",
            ":produit/produisent: des crues trop tard dans l'année."),

        "^alphaCDC$"=c(
            ":simule/simulent: un régime des moyennes eaux pas suffisamment contrasté.",
            ":simule/simulent: de manière correcte le régime des moyennes eaux.",
            ":simule/simulent: un régime des moyennes eaux trop contrasté."),

        "^alphaQA$"=c(
            ":s'écarte/s'écartent: sensiblement de la tendance observée sur les débits moyens annuels.",
            ":simule/simulent: de manière correcte l'évolution au cours du temps du débit moyen annuel.",
            ":s'écarte/s'écartent: sensiblement de la tendance observée sur les débits moyens annuels."),

        "^Q90$"=c(
            ":sous-estime/sous-estiment: les débits en étiage.",
            ":simule/simulent: de manière correcte les débits d'étiage.",
            ":surestime/surestiment: les débits en étiage."),

        "tVCN10"=c(
            ":produit/produisent: des étiages trop tôt dans l'année.",
            ":simule/simulent: de manière correcte temporalité annuelle des étiages.",
            ":produit/produisent: des étiages trop tard dans l'année."),

        "RAT_T"=c(
            ":montre/montrent: une robustesse temporelle satisfaisante à la température (test RAT).",
            ":montre/montrent: une faible robustesse temporelle à la température (test RAT)."),

        "RAT_P"=c(
            ":montre/montrent: une robustesse temporelle satisfaisante aux précipitations (test RAT).",
            ":montre/montrent: une faible robustesse temporelle aux précipitations (test RAT)."))

    
    tick_nline = list(
        
        "^KGE"=c(
            ":reproduit/reproduisent: correctement les observations.",
            ":reproduit/reproduisent: mal les observations.",
            ":reproduit/reproduisent: correctement les observations."),
        
        "^Biais$"=c(
            ":a/ont: un biais acceptable.",
            ":a/ont: un biais important.",
            ":a/ont: un biais acceptable."),

        "^epsilon.*T.*DJF"=c(
            ":a/ont: une sensibilité acceptable aux variations de température en hiver.",
            ":n'est/ne sont: pas correctement sensible aux variations de température en hiver.",
            ":a/ont: une sensibilité acceptable aux variations de température en hiver."),

        "^epsilon.*T.*JJA"=c(
            ":a/ont: une sensibilité acceptable aux variations de température en été.",
            ":n'est/ne sont: pas correctement sensible aux variations de température en été.",
            ":a/ont: une sensibilité acceptable aux variations de température en été."),

        "^epsilon.*P.*DJF"=c(
            ":a/ont: une sensibilité acceptable aux variations de précipitations hivernales.",
            ":n'est/ne sont: pas correctement sensible aux variations de précipitations hivernales.",
            ":a/ont: une sensibilité acceptable aux variations de précipitations hivernales."),

        "^epsilon.*P.*JJA"=c(
            ":a/ont: une sensibilité acceptable aux variations de précipitations estivales.",
            ":n'est/ne sont: pas correctement sensible aux variations de précipitations estivales.",
            ":a/ont: une sensibilité acceptable aux variations de précipitations estivales."),

        "^Q10$"=c(
            ":simule/simulent: de manière correcte les débits en hautes eaux.",
            "ne :simule/simulent: pas de manière correcte les débits en hautes eaux.",
            ":simule/simulent: de manière correcte les débits en hautes eaux."),

        "tQJXA"=c(
            ":simule/simulent: de manière correcte la temporalité annuelle des crues.",
            "ne :simule/simulent: pas de manière correcte la temporalité annuelle des crues.",
            ":simule/simulent: de manière correcte la temporalité annuelle des crues."),

        "^alphaCDC$"=c(
            ":simule/simulent: de manière correcte le régime des moyennes eaux.",
            "ne :simule/simulent: pas de manière correcte le régime des moyennes eaux.",
            ":simule/simulent: de manière correcte le régime des moyennes eaux."),

        "^alphaQA$"=c(
            ":simule/simulent: de manière correcte l'évolution au cours du temps du débit moyen annuel.",
            ":s'écarte/s'écartent: sensiblement de la tendance observée sur les débits moyens annuels.",
            ":simule/simulent: de manière correcte l'évolution au cours du temps du débit moyen annuel."),

        "^Q90$"=c(
            ":simule/simulent: de manière correcte les débits d'étiage.",
            "ne :simule/simulent: pas de manière correcte les débits d'étiage.",
            ":simule/simulent: de manière correcte les débits d'étiage."),

        "tVCN10"=c(
            ":simule/simulent: de manière correcte temporalité annuelle des étiages.",
           "ne :simule/simulent: pas de manière correcte temporalité annuelle des étiages.",
            ":simule/simulent: de manière correcte temporalité annuelle des étiages."),

        "RAT_T"=c(
            ":montre/montrent: une faible robustesse temporelle à la température (test RAT).",
            ":montre/montrent: une robustesse temporelle satisfaisante à la température (test RAT)."),

        "RAT_P"=c(
            ":montre/montrent: une faible robustesse temporelle aux précipitations (test RAT).",
            ":montre/montrent: une robustesse temporelle satisfaisante aux précipitations (test RAT)."))
    
    
    line_allOK = "<b>Tous les modèles hydrologiques</b> semblent simuler de manière acceptable le régime."
    line_OK = "Les modèles hydrologiques semblent simuler de manière acceptable le régime sauf "
    line_NOK = "Les modèles hydrologiques ont des difficultés à reproduire le régime sauf "
    line_allNOK = "<b>Aucun modèle hydrologique</b> ne semble simuler de manière acceptable le régime."

    orderVar = c("Général", "^RAT.*T$", "^KGE",
                 "^Biais$", "^Q[[:digit:]]+$", "[{]t.*[}])",
                 "^alpha", "^epsilon.*")

    if (is.null(codeLight)) {
        Code = levels(factor(dataEXind$Code))  
    } else {
        Code = codeLight
    }
    nCode = length(Code)

    Model = levels(factor(dataEXind$Model))
    nModel = length(Model)
    
    Warnings = dplyr::tibble()
    allLines = dplyr::tibble()
    
    for (k in 1:nCode) {

        if ((k-1) %% 25 == 0) {
            print(paste0(round(k/nCode*100), " %"))
        }
        
        code = Code[k]

        dataEXind_code = dataEXind[dataEXind$Code == code,]
        
        # logicalCol = names(dataEXind_code)[sapply(dataEXind_code, class) == "logical"]
        # dataEXind_code = dataEXind_code[!(names(dataEXind_code) %in% logicalCol)]
        # metaEXind = metaEXind[!(metaEXind$var %in% logicalCol),]
        
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
        dataEXind_code_tmp = dplyr::select(dataEXind_code_tmp,
                                           -c(Code, Model))

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

            range = unlist(tick_range[sapply(names(tick_range),
                                             grepl, var)],
                           use.names=FALSE)

            lines = tick_line[sapply(names(tick_line),
                                     grepl,
                                     var)][[1]]
            nlines = tick_nline[sapply(names(tick_nline),
                                       grepl,
                                       var)][[1]]
            
            for (j in 1:nModel) {
                model = Model[j]
                x = dataEXind_code[dataEXind_code$Model == model,][[var]]
                if (is.na(x)) {
                    next 
                }

                if (is.logical(range)) {
                    id = which(range == x)
                    niveau = id-1
                } else {
                    low = c(-Inf, range)
                    up = c(range, Inf)
                    id = which(low <= x & x <= up)
                    niveau = (id-2)
                }
                
                if (nrow(Lines) == 0) {
                    Lines = dplyr::tibble(var=var,
                                          model=model,
                                          niveau=niveau,
                                          line=lines[id],
                                          nline=nlines[id])
                } else {
                    Lines =
                        dplyr::bind_rows(Lines,
                                         dplyr::tibble(
                                                    var=var,
                                                    model=model,
                                                    niveau=niveau,
                                                    line=lines[id],
                                                    nline=nlines[id]))
                }
            }
        }

        allLines = dplyr::bind_rows(allLines,
                                    dplyr::select(Lines, c(var,
                                                           niveau,
                                                           line,
                                                           nline)))
            
        statLines =
            dplyr::summarise(
                       dplyr::group_by(Lines, var, niveau),
                       n=dplyr::n(),
                       model=
                           list(model[niveau ==
                                      dplyr::cur_group()$niveau]),
                       line=line[1],
                       nline=nline[1],
                       .groups="drop")

        Line_KGE = statLines[statLines$var == "KGEracine",]
        Line_Biais = statLines[statLines$var == "Biais",]
        
        if (nrow(Line_KGE) == 1 & nrow(Line_Biais) == 1) {            
            if (Line_KGE$niveau == 0 & Line_Biais$niveau == 0) {
                line = line_allOK
                niveau = 1
                line_model = line_allOK
                Warnings_code = statLines[statLines$niveau != 0,]
                Warnings_code = Warnings_code[c("var", "model",
                                                "line", "nline")]
                Warnings_code =
                    dplyr::bind_rows(dplyr::tibble(var="Général",
                                                   model=NA,
                                                   line=line_model,
                                                   nline=NA),
                                     Warnings_code)
            } else {
                line = line_allNOK
                niveau = -1
                line_model = line_allNOK
                Warnings_code = dplyr::tibble(var="Général",
                                              model=NA,
                                              line=line_model,
                                              nline=NA)
            }

        } else {            
            model_KGE_OK = unlist(Line_KGE$model[Line_KGE$niveau == 0])
            model_Biais_OK =
                unlist(Line_Biais$model[Line_Biais$niveau == 0])
            model_OK = c(model_KGE_OK, model_Biais_OK)
            model_OK = model_OK[duplicated(model_OK)]

            model_KGE_NOK = unlist(Line_KGE$model[Line_KGE$niveau != 0])
            model_Biais_NOK =
                unlist(Line_Biais$model[Line_Biais$niveau != 0])
            model_NOK = c(model_KGE_NOK, model_Biais_NOK)
            model_NOK = model_NOK[!duplicated(model_NOK)]

            if (length(model_OK) >= nModel/2) {
                line = line_OK
                niveau = 0.5
                models = paste0("<b>", model_NOK, ".</b>")
            } else {
                line = line_NOK
                niveau = -0.5
                models = paste0("<b>", model_OK, ".</b>")
            }
            models_len = length(models)
            if (models_len > 1) {
                models = paste0(
                    paste0(models[-models_len],
                           collapse=", "),
                    " et ", models[models_len], ".")
            }
            line_model = paste0(line, models)

            rm_NOK = function (X) {
                X = X[!(X %in% model_NOK)]
                if (length(X) == 0) {
                    X = NA
                }
                return (X)
            }
            
            Warnings_code = statLines[statLines$niveau != 0,]
            Warnings_code = Warnings_code[c("var", "model",
                                            "line", "nline")]
            Warnings_code$model = lapply(Warnings_code$model, rm_NOK)
            Warnings_code = Warnings_code[!is.na(Warnings_code$model),]
            
            Warnings_code =
                dplyr::bind_rows(dplyr::tibble(var="Général",
                                               model=NA,
                                               line=line_model,
                                               nline=NA),
                                 Warnings_code)
        }

        allLines = dplyr::bind_rows(allLines,
                                    dplyr::tibble(var="Général",
                                                  niveau=niveau,
                                                  line=line,
                                                  nline=NA))
        
        for (i in 1:nrow(Warnings_code)) {

            Line = Warnings_code[i,]
            if (is.null(unlist(Line$model))) {
                next
            }
            
            if (length(unlist(Line$model)) == nModel) {
                Line$line =
                    paste0(all_model, " ",
                           gsub("([:].*[/])|([:])",
                                "",
                                Line$line))
            } else {
                # model = paste0("<b>",
                #                unlist(Line$model),
                #                "</b>")
                # if (length(unlist(Line$model)) == 1) {
                #     Line$line =
                #         paste0(model, " ",
                #                gsub("([/].*[:])|([:])",
                #                     "",
                #                     Line$line))
                # } else {
                #     model = paste0(
                #         paste0(model[-length(model)],
                #                collapse=", "),
                #         " et ", model[length(model)])
                #     Line$line =
                #         paste0(model, " ",
                #                gsub("([:].*[/])|([:])",
                #                     "",
                #                     Line$line))
                # }

                ##
                models = unlist(Line$model)
                models_len = length(models)
                if (models_len > nModel/2) {
                    models = Model[!(Model %in% models)]
                    models_len = length(models)
                    models_str = paste0("<b>", models, "</b>")
                    if (models_len == 1) {
                        Line$line =
                            paste0("Seul ", models_str, " ",
                                   gsub("([/].*[:])|([:])",
                                        "",
                                        Line$nline))
                    } else {
                        models_str = paste0(
                            paste0(models_str[-models_len],
                                   collapse=", "),
                            " et ", models_str[models_len])
                        Line$line =
                            paste0("Seuls ", models_str, " ",
                                   gsub("([:].*[/])|([:])",
                                        "",
                                        Line$nline))
                    }
                    
                } else {
                    models_str = paste0("<b>", models, "</b>")
                    if (models_len == 1) {
                        Line$line =
                            paste0(models_str, " ",
                                   gsub("([/].*[:])|([:])",
                                        "",
                                        Line$line))
                    } else {
                        models_str = paste0(
                            paste0(models_str[-models_len],
                                   collapse=", "),
                            " et ", models_str[models_len])
                        Line$line =
                            paste0(models_str, " ",
                                   gsub("([:].*[/])|([:])",
                                        "",
                                        Line$line))
                    }
                }
                ##
            }
            Warnings_code[i,] = Line
        }


        warningsOrder = c()
        for (i in 1:nrow(Warnings_code)) {
            var = Warnings_code$var[i]
            warningsOrder = c(warningsOrder,
                              which(sapply(orderVar, grepl,
                                           x=var)))
        }
        warningsOrder = order(warningsOrder)
        Warnings_code = Warnings_code[warningsOrder,]
        
        if (nrow(Warnings) == 0) {
            Warnings = dplyr::tibble(Code=code,
                                     warning=Warnings_code$line)
        } else {
            Warnings =
                dplyr::bind_rows(Warnings,
                                 dplyr::tibble(Code=code,
                                               warning=
                                                   Warnings_code$line))
        }
    }
    
    frq = dplyr::summarise(dplyr::group_by(allLines,
                                           line),
                           var=var[1],
                           niveau=niveau[1],
                           n=dplyr::n(),
                           .groups="drop")
    frq = dplyr::summarise(dplyr::group_by(frq,
                                           var),
                           n=n,
                           Npv=sum(n),
                           niveau=niveau,
                           line=line,
                           .groups="drop")
    frq$npv_pct = frq$n/frq$Npv*100

    if (save) {
        write_tibble(Warnings,
                     filedir=resdir,
                     filename="Warnings.fst")
    }
    res = list(Warnings=Warnings, frq=frq)
    return (res)
}

# W = find_Warnings(dataEXind, metaEXind,
                  # codeLight="K2981910",
                  # save=FALSE)
# W = find_Warnings(dataEXind, metaEXind)
# Warnings = W$Warnings
# frq = W$frq
# frq_short=select(frq, c(var, niveau, npv_pct))
# frq_short = arrange(group_by(frq_short, var), desc(niveau), .by_group=TRUE)
# frq_short$npv_pct = round(frq_short$npv_pct)
# Warnings[grepl("hydrologique", Warnings$warning),]
