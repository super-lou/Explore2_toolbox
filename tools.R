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


convert_code8to10 = function (Code) {
    Code_save = Code
    if (any(nchar(Code) == 8)) {
        Code[nchar(Code) == 8] =
            codes10_selection[match(Code[nchar(Code) == 8],
                                    codes8_selection)]
        Code_try = lapply(paste0(Code_save[is.na(Code)],
                                 ".*"), apply_grepl,
                          table=codes10_selection)
        Code_len = sapply(Code_try, length)
        Code_NOk = Code_len > 1 | Code_len == 0
        Code_try[Code_NOk] = ""
        Code_try = unlist(Code_try)
        Code[is.na(Code)] = Code_try
    }
    Code[nchar(Code) > 10] =
        substr(Code[nchar(Code) > 10], 1, 10)
    Code[nchar(Code) < 10] =
        gsub(" ", "0",
             formatC(Code[nchar(Code) < 10],
                     width=10, flag="-"))
    return (Code)
}

NetCDF_extrat_time = function (NCdata) {
    Date = ncdf4::ncvar_get(NCdata, "time")
    if (Date[2] - Date[1] == 86400) {
        Date = Date/86400
    }
    
    Date = as.Date(Date,
                   origin=
                       as.Date(str_extract(
                           ncdf4::ncatt_get(NCdata,
                                            "time")$units,
                           "[0-9]+-[0-9]+-[0-9]+")))

    Date = as.Date(as.character(Date), origin=as.Date("1970-01-01"))
    return (Date)
}

NetCDF_to_tibble = function (NetCDF_path,
                             chain="", mode="diag") {
    
    NCdata = ncdf4::nc_open(NetCDF_path)

    print(NCdata)

    Date = NetCDF_extrat_time(NCdata)
    nDate = length(Date)

    if (mode == "diag") {

        CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")

        CodeRaw = convert_code8to10(CodeRaw)
        
        CodeRawSUB10 = CodeRaw[CodeRaw %in% CodeSUB10]
        CodeOrder = order(CodeRawSUB10)
        Code = CodeRawSUB10[CodeOrder]
        nCode = length(Code)
        
        station = match(CodeRawSUB10, CodeRaw)
        if (length(station) == 0) {
            ncdf4::nc_close(NCdata)
            return (NULL)
        }
        
        start = min(station)
        count = max(station) - start + 1
        station = station - start + 1

        if (chain %in% c("SIM2")) {
            Q_sim = ncdf4::ncvar_get(NCdata, "debit",
                                     start=c(start, 1),
                                     count=c(count, -1))
        } else {
            Q_sim = ncdf4::ncvar_get(NCdata, "Q",
                                     start=c(start, 1),
                                     count=c(count, -1))
        }

        Q_sim = matrix(Q_sim, nrow=count)
        Q_sim = Q_sim[station,,drop=FALSE]
        Q_sim = Q_sim[CodeOrder,,drop=FALSE]
        Q_sim = c(t(Q_sim))
        
        data = dplyr::tibble(Code=rep(Code, each=nDate),
                             Date=rep(Date, times=nCode),
                             Q_sim=Q_sim)
        
        if (chain %in% c("CTRIP")) {
            S = ncdf4::ncvar_get(NCdata, "trip_area",
                                 start=start,
                                 count=count)
        } else if (chain %in% c("SIM2")) {

            S = ncdf4::ncvar_get(NCdata, "surface_mod",
                                 start=start,
                                 count=count)
        } else {
            S = ncdf4::ncvar_get(NCdata, "surface_model",
                                 start=start,
                                 count=count)
        }
        S = S[station]
        S = S[CodeOrder]
        data = dplyr::bind_cols(data, S=rep(S, each=nDate))
        
        if (!(chain %in% c("CTRIP", "EROS", "GRSD", "SIM2"))) {
            P = ncdf4::ncvar_get(NCdata, "P",
                                 start=c(start, 1),
                                 count=c(count, -1))
            P = matrix(P, nrow=count)
            P = P[station,,drop=FALSE]
            P = P[CodeOrder,,drop=FALSE]
            P = c(t(P))
            data = dplyr::bind_cols(data, P=P)
            
            Pl = ncdf4::ncvar_get(NCdata, "Pl",
                                  start=c(start, 1),
                                  count=c(count, -1))
            Pl = matrix(Pl, nrow=count)
            Pl = Pl[station,,drop=FALSE]
            Pl = Pl[CodeOrder,,drop=FALSE]
            Pl = c(t(Pl))
            data = dplyr::bind_cols(data, Pl=Pl)
            
            Ps = ncdf4::ncvar_get(NCdata, "Ps",
                                  start=c(start, 1),
                                  count=c(count, -1))
            Ps = matrix(Ps, nrow=count)
            Ps = Ps[station,,drop=FALSE]
            Ps = Ps[CodeOrder,,drop=FALSE]
            Ps = c(t(Ps))
            data = dplyr::bind_cols(data, Ps=Ps)
        }
        
        if (!(chain %in% c("CTRIP", "SIM2"))) {
            T = ncdf4::ncvar_get(NCdata, "T",
                                 start=c(start, 1),
                                 count=c(count, -1))
            T = matrix(T, nrow=count)
            T = T[station,,drop=FALSE]
            T = T[CodeOrder,,drop=FALSE]
            T = c(t(T))
            data = dplyr::bind_cols(data, T=T)
        }
        
        if (!(chain %in% c("CTRIP", "ORCHIDEE", "SIM2"))) {
            ET0 = ncdf4::ncvar_get(NCdata, "ET0",
                                   start=c(start, 1),
                                   count=c(count, -1))
            ET0 = matrix(ET0, nrow=count)
            ET0 = ET0[station,,drop=FALSE]
            ET0 = ET0[CodeOrder,,drop=FALSE]
            ET0 = c(t(ET0))
            data = dplyr::bind_cols(data, ET0=ET0)
        }
        
        if (chain == "ORCHIDEE") {
            data$T = data$T - 273.15
        }
        
        data = dplyr::bind_cols(Model=chain, data)
        
    } else if (mode == "proj") {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code")
        
        CodeRaw = convert_code8to10(CodeRaw)

        CodeRawSUB10 = CodeRaw[CodeRaw %in% CodeSUB10]
        CodeOrder = order(CodeRawSUB10)
        Code = CodeRawSUB10[CodeOrder]
        nCode = length(Code)
        
        station = match(CodeRawSUB10, CodeRaw)
        if (length(station) == 0) {
            ncdf4::nc_close(NCdata)
            return (NULL)
        }
        start = min(station)
        count = max(station) - start + 1
        station = station - start + 1

        print(start)
        print(count)
        print(station)

        
        
        Q_sim = ncdf4::ncvar_get(NCdata, "debit",
                                 start=c(start, 1),
                                 count=c(count, -1))

        # print(Q_sim)
        
        Q_sim = matrix(Q_sim, nrow=count)
        Q_sim = Q_sim[station,,drop=FALSE]
        Q_sim = Q_sim[CodeOrder,,drop=FALSE]
        Q_sim = c(t(Q_sim))

        if ("topologicalSurface_model" %in% names(NCdata$var)) {
            S = ncdf4::ncvar_get(NCdata, "topologicalSurface_model",
                                 start=start,
                                 count=count)
            S = S[station]
            S = S[CodeOrder]
        } else {
            S = rep(NA, times=nCode)
        }

        data = dplyr::tibble(Code=rep(Code, each=nDate),
                             Date=rep(Date, times=nCode),
                             Q_sim=Q_sim,
                             S=rep(S, each=nDate))
        data = dplyr::filter(data, !is.nan(Q_sim))
        IDvalue = unlist(strsplit(chain, "[|]"))
        IDname = c("GCM", "EXP", "RCM", "BC", "Model")
        ID = dplyr::tibble(!!!IDvalue)
        names(ID) = IDname
        data = dplyr::bind_cols(ID, data)
    }
    
    ncdf4::nc_close(NCdata)
    return (data)
}



get_select = function (dataEX, metaEX,
                       select="") {
    if (!any(select == "all")) {
        select = paste0("(",
                        paste0(c("Model", "Code", select),
                               collapse=")|("), ")")

        select = gsub("[{]", "[{]", select)
        select = gsub("[}]", "[}]", select)
        select = gsub("[_]", "[_]", select)
        select = gsub("[,]", "[,]", select)
        
        if (is.tbl(dataEX)) {
            select_in = c(sapply(select, apply_grepl,
                                 table=names(dataEX)))
            dataEX = dplyr::select(dataEX, select_in)

        } else {
            for (i in 1:length(dataEX)) {
                select_in = c(sapply(select, apply_grepl,
                                     table=names(dataEX[[i]])))
                dataEX[[i]] = dplyr::select(dataEX[[i]], select_in)
            }
        }
        
        metaEX = metaEX[metaEX$var %in% select,]
    }
    return (list(metaEX=metaEX, dataEX=dataEX))
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
            ":reproduit|reproduisent: mal les observations.",
            ":reproduit|reproduisent: correctement les observations.",
            ":reproduit|reproduisent: mal les observations."),
        
        "^Biais$"=c(
            ":a|ont: un biais négatif important.",
            ":a|ont: un biais acceptable.",
            ":a|ont: un biais positif important."),

        "^epsilon.*T.*DJF"=c(
            ":n'est|ne sont: pas assez :sensible|sensibles: aux variations de température en hiver.",
            ":a|ont: une sensibilité acceptable aux variations de température en hiver.",
            ":est|sont: trop :sensible|sensibles: aux variations de température en hiver."),

        "^epsilon.*T.*JJA"=c(
            ":n'est|ne sont: pas assez :sensible|sensibles: aux variations de température en été.",
            ":a|ont: une sensibilité acceptable aux variations de température en été.",
            ":est|sont: trop :sensible|sensibles: aux variations de température en été."),

        "^epsilon.*P.*DJF"=c(
            ":n'est|ne sont: pas assez :sensible|sensibles: aux variations de précipitations hivernales.",
            ":a|ont: une sensibilité acceptable aux variations de précipitations hivernales.",
            ":est|sont: trop :sensible|sensibles: aux variations de précipitations hivernales."),

        "^epsilon.*P.*JJA"=c(
            ":n'est|ne sont: pas assez :sensible|sensibles: aux variations de précipitations estivales.",
            ":a|ont: une sensibilité acceptable aux variations de précipitations estivales.",
            ":est|sont: trop :sensible|sensibles: aux variations de précipitations estivales."),

        "^Q10$"=c(
            ":sous-estime|sous-estiment: les débits en hautes eaux.",
            ":simule|simulent: de manière correcte les débits en hautes eaux.",
            ":surestime|surestiment: les débits en hautes eaux."),

        "tQJXA"=c(
            ":produit|produisent: des crues trop tôt dans l'année.",
            ":simule|simulent: de manière correcte la temporalité annuelle des crues.",
            ":produit|produisent: des crues trop tard dans l'année."),

        "^alphaCDC$"=c(
            ":simule|simulent: un régime des moyennes eaux pas suffisamment contrasté.",
            ":simule|simulent: de manière correcte le régime des moyennes eaux.",
            ":simule|simulent: un régime des moyennes eaux trop contrasté."),

        "^alphaQA$"=c(
            ":s'écarte|s'écartent: sensiblement de la tendance observée sur les débits moyens annuels.",
            ":simule|simulent: de manière correcte l'évolution au cours du temps du débit moyen annuel.",
            ":s'écarte|s'écartent: sensiblement de la tendance observée sur les débits moyens annuels."),

        "^Q90$"=c(
            ":sous-estime|sous-estiment: les débits en étiage.",
            ":simule|simulent: de manière correcte les débits d'étiage.",
            ":surestime|surestiment: les débits en étiage."),

        "tVCN10"=c(
            ":produit|produisent: des étiages trop tôt dans l'année.",
            ":simule|simulent: de manière correcte temporalité annuelle des étiages.",
            ":produit|produisent: des étiages trop tard dans l'année."),

        "RAT_T"=c(
            ":montre|montrent: une robustesse temporelle satisfaisante à la température (RAT<sub>T</sub>).",
            ":montre|montrent: une faible robustesse temporelle à la température (RAT<sub>T</sub>)."),

        "RAT_P"=c(
            ":montre|montrent: une robustesse temporelle satisfaisante aux précipitations (RAT<sub>P</sub>).",
            ":montre|montrent: une faible robustesse temporelle aux précipitations (RAT<sub>P</sub>)."))

    
    tick_nline = list(
        
        "^KGE"=c(
            ":reproduit|reproduisent: correctement les observations.",
            ":reproduit|reproduisent: mal les observations.",
            ":reproduit|reproduisent: correctement les observations."),
        
        "^Biais$"=c(
            ":a|ont: un biais acceptable.",
            ":a|ont: un biais important.",
            ":a|ont: un biais acceptable."),

        "^epsilon.*T.*DJF"=c(
            ":a|ont: une sensibilité acceptable aux variations de température en hiver.",
            ":n'est|ne sont: pas correctement :sensible|sensibles: aux variations de température en hiver.",
            ":a|ont: une sensibilité acceptable aux variations de température en hiver."),

        "^epsilon.*T.*JJA"=c(
            ":a|ont: une sensibilité acceptable aux variations de température en été.",
            ":n'est|ne sont: pas correctement :sensible|sensibles: aux variations de température en été.",
            ":a|ont: une sensibilité acceptable aux variations de température en été."),

        "^epsilon.*P.*DJF"=c(
            ":a|ont: une sensibilité acceptable aux variations de précipitations hivernales.",
            ":n'est|ne sont: pas correctement :sensible|sensibles: aux variations de précipitations hivernales.",
            ":a|ont: une sensibilité acceptable aux variations de précipitations hivernales."),

        "^epsilon.*P.*JJA"=c(
            ":a|ont: une sensibilité acceptable aux variations de précipitations estivales.",
            ":n'est|ne sont: pas correctement :sensible|sensibles: aux variations de précipitations estivales.",
            ":a|ont: une sensibilité acceptable aux variations de précipitations estivales."),

        "^Q10$"=c(
            ":simule|simulent: de manière correcte les débits en hautes eaux.",
            "ne :simule|simulent: pas de manière correcte les débits en hautes eaux.",
            ":simule|simulent: de manière correcte les débits en hautes eaux."),

        "tQJXA"=c(
            ":simule|simulent: de manière correcte la temporalité annuelle des crues.",
            "ne :simule|simulent: pas de manière correcte la temporalité annuelle des crues.",
            ":simule|simulent: de manière correcte la temporalité annuelle des crues."),

        "^alphaCDC$"=c(
            ":simule|simulent: de manière correcte le régime des moyennes eaux.",
            "ne :simule|simulent: pas de manière correcte le régime des moyennes eaux.",
            ":simule|simulent: de manière correcte le régime des moyennes eaux."),

        "^alphaQA$"=c(
            ":simule|simulent: de manière correcte l'évolution au cours du temps du débit moyen annuel.",
            ":s'écarte|s'écartent: sensiblement de la tendance observée sur les débits moyens annuels.",
            ":simule|simulent: de manière correcte l'évolution au cours du temps du débit moyen annuel."),

        "^Q90$"=c(
            ":simule|simulent: de manière correcte les débits d'étiage.",
            "ne :simule|simulent: pas de manière correcte les débits d'étiage.",
            ":simule|simulent: de manière correcte les débits d'étiage."),

        "tVCN10"=c(
            ":simule|simulent: de manière correcte temporalité annuelle des étiages.",
            "ne :simule|simulent: pas de manière correcte temporalité annuelle des étiages.",
            ":simule|simulent: de manière correcte temporalité annuelle des étiages."),

        "RAT_T"=c(
            ":montre|montrent: une faible robustesse temporelle à la température (RAT<sub>T</sub>).",
            ":montre|montrent: une robustesse temporelle satisfaisante à la température (RAT<sub>T</sub>)."),

        "RAT_P"=c(
            ":montre|montrent: une faible robustesse temporelle aux précipitations (RAT<sub>P</sub>).",
            ":montre|montrent: une robustesse temporelle satisfaisante aux précipitations (RAT<sub>P</sub>)."))
    
    
    line_allOK = "<b>Tous les modèles</b> semblent simuler de manière acceptable le régime."
    line_OK = "Les modèles semblent simuler de manière acceptable le régime sauf "
    line_NOK = "Les modèles ont des difficultés à reproduire le régime sauf "
    line_allNOK = "<b>Aucun modèle</b> ne semble simuler de manière acceptable le régime."

    orderVar = c("Général", "^RAT.*T$",  "^RAT.*P$", "^KGE",
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
                models = paste0("<b>", model_NOK, "</b>")
            } else {
                line = line_NOK
                niveau = -0.5
                models = paste0("<b>", model_OK, "</b>")
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
                           gsub("([|].*[:])|([:])",
                                "",
                                Line$line))
            } else {
                # model = paste0("<b>",
                #                unlist(Line$model),
                #                "</b>")
                # if (length(unlist(Line$model)) == 1) {
                #     Line$line =
                #         paste0(model, " ",
                #                gsub("([|].*[:])|([:])",
                #                     "",
                #                     Line$line))
                # } else {
                #     model = paste0(
                #         paste0(model[-length(model)],
                #                collapse=", "),
                #         " et ", model[length(model)])
                #     Line$line =
                #         paste0(model, " ",
                #                gsub("([:].*[|])|([:])",
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
                                   gsub("([|].*[:])|([:])",
                                        "",
                                        Line$nline))
                    } else {
                        models_str = paste0(
                            paste0(models_str[-models_len],
                                   collapse=", "),
                            " et ", models_str[models_len])
                        Line$line =
                            paste0("Seuls ", models_str, " ",
                                   gsub("([:].*[|])|([:])",
                                        "",
                                        Line$nline))
                    }
                    
                } else {
                    models_str = paste0("<b>", models, "</b>")
                    if (models_len == 1) {
                        Line$line =
                            paste0(models_str, " ",
                                   gsub("([|].*[:])|([:])",
                                        "",
                                        Line$line))
                    } else {
                        models_str = paste0(
                            paste0(models_str[-models_len],
                                   collapse=", "),
                            " et ", models_str[models_len])
                        Line$line =
                            paste0(models_str, " ",
                                   gsub("([:].*[|])|([:])",
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
    return (list(Warnings=Warnings, frq=frq))
}

# W = find_Warnings(dataEX_Explore2_diag_criteria_select,
#                   metaEX_Explore2_diag_criteria_select,
#                   codeLight="K298191001",
#                   save=FALSE)
# W = find_Warnings(dataEXind, metaEXind)
# Warnings = W$Warnings
# frq = W$frq
# frq_short=select(frq, c(var, niveau, npv_pct))
# frq_short = arrange(group_by(frq_short, var), desc(niveau), .by_group=TRUE)
# frq_short$npv_pct = round(frq_short$npv_pct)
# Warnings[grepl("hydrologique", Warnings$warning),]



start_timer = function (timer, rank, process_type, process_name) {
    timer = dplyr::bind_rows(timer,
                             dplyr::tibble(rank=rank,
                                           process_type=process_type,
                                           process_name=process_name,
                                           start=Sys.time(),
                                           stop=Sys.time()))
    return (timer)
}

stop_timer = function (timer, rank, process_type, process_name) {
    timer$stop[timer$rank == rank &
               timer$process_type == process_type &
               timer$process_name == process_name] = Sys.time()
    return (timer)
}
