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


any_grepl = function (pattern, x, ...) {
    return (any(grepl(pattern=pattern, x=x, ...)))
}

apply_grepl = function (x, table, target=NULL) {
    if (is.null(target)) {
        target = table
    }
    return (target[grepl(x, table)])
}

apply_match = function (x, table, target=NULL) {
    if (is.null(target)) {
        target = table
    }
    return (target[match(x, table)])
}

apply_bra = function (id, target) {
    return (target[id])
}

convert2bool = function (X, true) {
    ok = X == true
    X[ok] = TRUE
    X[!ok] = FALSE
    return (X)
}


get_couche_in_meta = function (meta) {
    Couche = sapply(meta$Couche, strsplit, "|", fixed=TRUE, USE.NAMES=FALSE)
    Couche[lapply(Couche, length) == 0] = ""
    meta$Couche = Couche
    return (meta)
}

any_in = function (x, y) {
    return (any(x %in% y))
}

is_in_couche = function (Couche, couche) {
    return (sapply(Couche, any_in, couche))
}
    

convert_codeNtoM = function (Code, N=8, M=10, crop=TRUE, top="0") {
    Code_save = Code

    CodeN_table = get(paste0("codes", N, "_selection"))
    CodeM_table = get(paste0("codes", M, "_selection"))

    if (any(nchar(Code) == N)) {
        matchCode = match(Code, CodeN_table)
        Code[!is.na(matchCode)] =
            CodeM_table[matchCode[!is.na(matchCode)]]
        
        Code_try = lapply(paste0(Code_save[is.na(Code)],
                                 ".*"), apply_grepl,
                          table=CodeM_table)
        Code_len = sapply(Code_try, length)
        Code_NOk = Code_len > 1 | Code_len == 0
        Code_try[Code_NOk] = ""
        Code_try = unlist(Code_try)
        Code[is.na(Code)] = Code_try
    }
    
    if (crop) {
        Code[nchar(Code) > M] =
            substr(Code[nchar(Code) > M], 1, M)
    }
    if (!is.null(top)) {
        Code[nchar(Code) < M] =
            gsub(" ", top,
                 formatC(Code[nchar(Code) < M],
                         width=M, flag="-"))
    }
    
    return (Code)
}


NetCDF_extrat_time = function (NCdata, data_name="time") {
    Date = ncdf4::ncvar_get(NCdata, data_name)
    # if (Date[2] - Date[1] == 86400) {
        # Date = Date/86400
    # }
    Date = as.Date(Date,
                   origin=
                       as.Date(str_extract(
                           ncdf4::ncatt_get(NCdata,
                                            data_name)$units,
                           "[0-9]+-[0-9]+-[0-9]+")))

    Date = as.Date(as.character(Date), origin=as.Date("1970-01-01"))
    return (Date)
}

NetCDF_to_tibble = function (NetCDF_path,
                             chain="",
                             type="hydrologie",
                             mode="diagnostic") {
    
    NCdata = ncdf4::nc_open(NetCDF_path)

    # print(NCdata)

    Date = NetCDF_extrat_time(NCdata)
    nDate = length(Date)

    if (type == "hydrologie") {
        if (grepl("diagnostic", mode)) {

            CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
            CodeRaw = convert_codeNtoM(CodeRaw)
            
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
            
            data = dplyr::tibble(code=rep(Code, each=nDate),
                                 date=rep(Date, times=nCode),
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
                S = ncdf4::ncvar_get(NCdata, "surface_HM",
                                     start=start,
                                     count=count)
            }
            S = S[station]
            S = S[CodeOrder]
            data = dplyr::bind_cols(data, S=rep(S, each=nDate))
            
            if (!(chain %in% c("CTRIP", "EROS", "SIM2"))) {
                R = ncdf4::ncvar_get(NCdata, "R",
                                     start=c(start, 1),
                                     count=c(count, -1))
                R = matrix(R, nrow=count)
                R = R[station,,drop=FALSE]
                R = R[CodeOrder,,drop=FALSE]
                R = c(t(R))
                data = dplyr::bind_cols(data, R=R)

                if (!(chain %in% c("GRSD"))) {
                    Rl = ncdf4::ncvar_get(NCdata, "Rl",
                                          start=c(start, 1),
                                          count=c(count, -1))
                    Rl = matrix(Rl, nrow=count)
                    Rl = Rl[station,,drop=FALSE]
                    Rl = Rl[CodeOrder,,drop=FALSE]
                    Rl = c(t(Rl))
                    data = dplyr::bind_cols(data, Rl=Rl)
                    
                    Rs = ncdf4::ncvar_get(NCdata, "Rs",
                                          start=c(start, 1),
                                          count=c(count, -1))
                    Rs = matrix(Rs, nrow=count)
                    Rs = Rs[station,,drop=FALSE]
                    Rs = Rs[CodeOrder,,drop=FALSE]
                    Rs = c(t(Rs))
                    data = dplyr::bind_cols(data, Rs=Rs)
                }
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
            
            data = dplyr::bind_cols(HM=chain, data)
            data = dplyr::filter(data, !is.nan(Q_sim))
            
        } else if (grepl("projection", mode)) {
            CodeRaw = ncdf4::ncvar_get(NCdata, "code")
            
            CodeRaw = convert_codeNtoM(CodeRaw)

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

            Q_sim = ncdf4::ncvar_get(NCdata, "debit",
                                     start=c(start, 1),
                                     count=c(count, -1))

            
            Q_sim = matrix(Q_sim, nrow=count)
            Q_sim = Q_sim[station,,drop=FALSE]
            Q_sim = Q_sim[CodeOrder,,drop=FALSE]
            Q_sim = c(t(Q_sim))

            if ("topologicalSurface_model" %in%
                names(NCdata$var)) {
                S = ncdf4::ncvar_get(NCdata,
                                     "topologicalSurface_model",
                                     start=start,
                                     count=count)
            } else {
                S = ncdf4::ncvar_get(NCdata,
                                     "surface_model",
                                     start=start,
                                     count=count)
            }
            S = S[station]
            S = S[CodeOrder]
            # else {
            # S = rep(NA, times=nCode)
            # }

            data = dplyr::tibble(code=rep(Code, each=nDate),
                                 date=rep(Date, times=nCode),
                                 Q_sim=Q_sim,
                                 S=rep(S, each=nDate))
            
            data = dplyr::filter(data, !is.nan(Q_sim))
            chainValue = unlist(strsplit(chain, "[|]"))
            chainName = c("GCM", "EXP", "RCM", "BC", "HM")
            chainName = chainName[nchar(chainValue) > 0]
            chainValue = chainValue[nchar(chainValue) > 0]
            Chain = dplyr::tibble(!!!chainValue)
            names(Chain) = chainName
            
            data = dplyr::bind_cols(Chain, data)
        }

    }
    
    ncdf4::nc_close(NCdata)
    return (data)
}



get_select = function (dataEX, metaEX,
                       select="") {
    if (!any(select == "all")) {
        select = paste0("(",
                        paste0(c("HM", "code", select),
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
        
        metaEX = metaEX[metaEX$variable_en %in% select,]
    }
    return (list(metaEX=metaEX, dataEX=dataEX))
}




find_Warnings = function (dataEXind, metaEXind,
                          resdir="", codeLight=NULL, save=FALSE) {

    tick_range = list(
        "^KGE"=c(0.5, 1),
        "^Bias$"=c(-0.2, 0.2),
        "(^epsilon.*)|(^alpha)|(^a)"=c(0.5, 2),
        "^Q10$"=c(-0.2, 0.2),
        "^Q90$"=c(-0.8, 0.8),
        "[{]t.*[}]"=c(-1, 1),
        "^RAT"=c(FALSE, TRUE))

    all_HM = "<b>L'ensemble des modèles</b>"
    
    tick_line = list(
        
        "^KGE"=c(
            ":reproduit|reproduisent: mal les observations.",
            ":reproduit|reproduisent: correctement les observations.",
            ":reproduit|reproduisent: mal les observations."),
        
        "^Bias$"=c(
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

        "^epsilon.*R.*DJF"=c(
            ":n'est|ne sont: pas assez :sensible|sensibles: aux variations de précipitations hivernales.",
            ":a|ont: une sensibilité acceptable aux variations de précipitations hivernales.",
            ":est|sont: trop :sensible|sensibles: aux variations de précipitations hivernales."),

        "^epsilon.*R.*JJA"=c(
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

        "^aFDC$"=c(
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

        "RAT_R"=c(
            ":montre|montrent: une robustesse temporelle satisfaisante aux précipitations (RAT<sub>R</sub>).",
            ":montre|montrent: une faible robustesse temporelle aux précipitations (RAT<sub>R</sub>).")
    )

    
    tick_nline = list(
        
        "^KGE"=c(
            ":reproduit|reproduisent: correctement les observations.",
            ":reproduit|reproduisent: mal les observations.",
            ":reproduit|reproduisent: correctement les observations."),
        
        "^Bias$"=c(
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

        "^epsilon.*R.*DJF"=c(
            ":a|ont: une sensibilité acceptable aux variations de précipitations hivernales.",
            ":n'est|ne sont: pas correctement :sensible|sensibles: aux variations de précipitations hivernales.",
            ":a|ont: une sensibilité acceptable aux variations de précipitations hivernales."),

        "^epsilon.*R.*JJA"=c(
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

        "^aFDC$"=c(
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

        "RAT_R"=c(
            ":montre|montrent: une faible robustesse temporelle aux précipitations (RAT<sub>R</sub>).",
            ":montre|montrent: une robustesse temporelle satisfaisante aux précipitations (RAT<sub>R</sub>).")
    )
    
    
    line_allOK = "<b>Tous les modèles</b> semblent simuler de manière acceptable le régime."
    line_OK = "Les modèles semblent simuler de manière acceptable le régime sauf "
    line_NOK = "Les modèles ont des difficultés à reproduire le régime sauf "
    line_allNOK = "<b>Aucun modèle</b> ne semble simuler de manière acceptable le régime."

    orderVariable = c("Général", "^RAT.*T$",  "^RAT.*R$", "^KGE",
                 "^Bias$", "^Q[[:digit:]]+$", "[{]t.*[}]",
                 "^alpha", "^epsilon.*")

    if (is.null(codeLight)) {
        Code = levels(factor(dataEXind$code))  
    } else {
        Code = codeLight
    }
    nCode = length(Code)

    HM = levels(factor(dataEXind$HM))
    nHM = length(HM)
    
    Warnings = dplyr::tibble()
    allLines = dplyr::tibble()
    
    for (k in 1:nCode) {

        if ((k-1) %% 25 == 0) {
            print(paste0(round(k/nCode*100), " %"))
        }
        
        code = Code[k]

        dataEXind_code = dataEXind[dataEXind$code == code,]
        
        variables2keep = names(dataEXind_code)
        variables2keep = variables2keep[!grepl("([_]obs)|([_]sim)", variables2keep)]

        dataEXind_code = dplyr::mutate(dataEXind_code,
                                       dplyr::across(where(is.logical),
                                                     as.numeric),
                                       .keep="all")
        
        dataEXind_code = dplyr::select(dataEXind_code, variables2keep)
        
        HM = levels(factor(dataEXind_code$HM))
        nHM = length(HM)
        
        dataEXind_code_tmp = dataEXind_code
        dataEXind_code_tmp = dplyr::select(dataEXind_code_tmp,
                                           -c(code, HM))

        matchVariable = match(names(dataEXind_code_tmp), metaEXind$variable_en)
        matchVariable = matchVariable[!is.na(matchVariable)]
        dataEXind_code_tmp = dataEXind_code_tmp[matchVariable]

        nameCol = names(dataEXind_code_tmp)
        Variable = nameCol
        nVariable = length(Variable)
        
        Lines = dplyr::tibble()
        
        for (i in 1:nVariable) {
            variable = Variable[i]
            x = dataEXind_code[[variable]]

            range = unlist(tick_range[sapply(names(tick_range),
                                             grepl, variable)],
                           use.names=FALSE)

            lines = tick_line[sapply(names(tick_line),
                                     grepl,
                                     variable)][[1]]
            nlines = tick_nline[sapply(names(tick_nline),
                                       grepl,
                                       variable)][[1]]
            
            for (j in 1:nHM) {
                hm = HM[j]
                x = dataEXind_code[dataEXind_code$HM == hm,][[variable]]
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
                    Lines = dplyr::tibble(variable=variable,
                                          hm=hm,
                                          niveau=niveau,
                                          line=lines[id],
                                          nline=nlines[id])
                } else {
                    Lines =
                        dplyr::bind_rows(Lines,
                                         dplyr::tibble(
                                                    variable=variable,
                                                    hm=hm,
                                                    niveau=niveau,
                                                    line=lines[id],
                                                    nline=nlines[id]))
                }
            }
        }

        allLines = dplyr::bind_rows(allLines,
                                    dplyr::select(Lines, c(variable,
                                                           niveau,
                                                           line,
                                                           nline)))
        
        statLines =
            dplyr::summarise(
                       dplyr::group_by(Lines, variable, niveau),
                       n=dplyr::n(),
                       hm=
                           list(hm[niveau ==
                                      dplyr::cur_group()$niveau]),
                       line=line[1],
                       nline=nline[1],
                       .groups="drop")

        Line_KGE = statLines[statLines$variable_en == "KGEsqrt",]
        Line_Bias = statLines[statLines$variable_en == "Bias",]

        if (all(Line_KGE$niveau == 0) &
            all(Line_Bias$niveau == 0)) {
            
            # if (Line_KGE$niveau == 0 & Line_Bias$niveau == 0) {
            hm_OK = HM
            line = line_allOK
            niveau = 1
            line_hm = line_allOK
            Warnings_code = statLines[statLines$niveau != 0,]
            Warnings_code = Warnings_code[c("variable", "hm",
                                            "line", "nline")]
            Warnings_code =
                dplyr::bind_rows(dplyr::tibble(variable="Général",
                                               hm=NA,
                                               line=line_hm,
                                               nline=NA),
                                 Warnings_code)
        } else if (all(Line_KGE$niveau != 0) &
                   all(Line_Bias$niveau != 0)) {
            hm_OK = c()
            line = line_allNOK
            niveau = -1
            line_hm = line_allNOK
            Warnings_code = dplyr::tibble(variable="Général",
                                          hm=NA,
                                          line=line_hm,
                                          nline=NA)
            # }

        } else {            
            hm_KGE_OK = unlist(Line_KGE$hm[Line_KGE$niveau == 0])
            hm_Bias_OK =
                unlist(Line_Bias$hm[Line_Bias$niveau == 0])
            hm_OK = c(hm_KGE_OK, hm_Bias_OK)
            hm_OK = hm_OK[duplicated(hm_OK)]

            hm_KGE_NOK = unlist(Line_KGE$hm[Line_KGE$niveau != 0])
            hm_Bias_NOK =
                unlist(Line_Bias$hm[Line_Bias$niveau != 0])
            hm_NOK = c(hm_KGE_NOK, hm_Bias_NOK)
            hm_NOK = hm_NOK[!duplicated(hm_NOK)]

            if (length(hm_OK) >= nHM/2) {
                line = line_OK
                niveau = 0.5
                hms = paste0("<b>", hm_NOK, "</b>")
            } else {
                line = line_NOK
                niveau = -0.5
                hms = paste0("<b>", hm_OK, "</b>")
            }
            hms_len = length(hms)
            if (hms_len > 1) {
                hms = paste0(
                    paste0(hms[-hms_len],
                           collapse=", "),
                    " et ", hms[hms_len], ".")
            }
            line_hm = paste0(line, hms)

            rm_NOK = function (X) {
                X = X[!(X %in% hm_NOK)]
                if (length(X) == 0) {
                    X = NA
                }
                return (X)
            }
            
            Warnings_code = statLines[statLines$niveau != 0,]
            Warnings_code = Warnings_code[c("variable", "hm",
                                            "line", "nline")]
            Warnings_code$hm = lapply(Warnings_code$hm, rm_NOK)
            Warnings_code = Warnings_code[!is.na(Warnings_code$hm),]
            
            Warnings_code =
                dplyr::bind_rows(dplyr::tibble(variable="Général",
                                               hm=NA,
                                               line=line_hm,
                                               nline=NA),
                                 Warnings_code)
        }

        Warnings_code$hm_OK = list(hm_OK)
        
        allLines = dplyr::bind_rows(allLines,
                                    dplyr::tibble(variable="Général",
                                                  niveau=niveau,
                                                  line=line,
                                                  nline=NA))

        for (i in 1:nrow(Warnings_code)) {
            Line = Warnings_code[i,]
            if (is.null(unlist(Line$hm))) {
                next
            }
            
            HM_OK = unlist(Line$hm_OK)
            nHM_OK = length(HM_OK)

            if (length(unlist(Line$hm)) == nHM_OK) {
                Line$line =
                    paste0(all_HM, " ",
                           gsub("([|][^:]*[:])|([:])",
                                "",
                                Line$line))
            } else if (nHM_OK > 0) {
                hms = unlist(Line$hm)
                hms_len = length(hms)
                
                if (hms_len > nHM_OK/2) {
                    hms = HM_OK[!(HM_OK %in% hms)]
                    hms_len = length(hms)
                    hms_str = paste0("<b>", hms, "</b>")
                    if (hms_len == 1) {
                        Line$line =
                            paste0("Seul ", hms_str, " ",
                                   gsub("([|][^:]*[:])|([:])",
                                        "",
                                        Line$nline))
                    } else {
                        hms_str = paste0(
                            paste0(hms_str[-hms_len],
                                   collapse=", "),
                            " et ", hms_str[hms_len])
                        Line$line =
                            paste0("Seuls ", hms_str, " ",
                                   gsub("([:][^:]*[|])|([:])",
                                        "",
                                        Line$nline))
                    }
                    
                } else {
                    hms_str = paste0("<b>", hms, "</b>")
                    if (hms_len == 1) {
                        Line$line =
                            paste0(hms_str, " ",
                                   gsub("([|][^:]*[:])|([:])",
                                        "",
                                        Line$line))
                    } else {
                        hms_str = paste0(
                            paste0(hms_str[-hms_len],
                                   collapse=", "),
                            " et ", hms_str[hms_len])
                        Line$line =
                            paste0(hms_str, " ",
                                   gsub("([:][^:]*[|])|([:])",
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
            variable = Warnings_code$variable_en[i]
            warningsOrder = c(warningsOrder,
                              which(sapply(orderVariable, grepl,
                                           x=variable)))
        }
        warningsOrder = order(warningsOrder)
        Warnings_code = Warnings_code[warningsOrder,]
        
        if (nrow(Warnings) == 0) {
            Warnings = dplyr::tibble(code=code,
                                     warning=Warnings_code$line)
        } else {
            Warnings =
                dplyr::bind_rows(Warnings,
                                 dplyr::tibble(code=code,
                                               warning=
                                                   Warnings_code$line))
        }
    }
    
    frq = dplyr::summarise(dplyr::group_by(allLines,
                                           line),
                           variable=variable[1],
                           niveau=niveau[1],
                           n=dplyr::n(),
                           .groups="drop")
    frq = dplyr::summarise(dplyr::group_by(frq,
                                           variable),
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
        write_tibble(frq,
                     filedir=resdir,
                     filename="Warnings_frequency.fst")
    }
    return (list(Warnings=Warnings, frq=frq))
}

# res_Warnings = find_Warnings(dataEX_Explore2_diag_criteria_select,
                  # metaEX_Explore2_diag_criteria_select,
                  # codeLight="K298191001",
                  # codeLight="V232000000",
                  # save=FALSE)
# Warnings_frequency_short =
    # select(Warnings_frequency, c(variable, niveau, npv_pct))
# Warnings_frequency_short =
    # arrange(group_by(Warnings_frequency_short, variable),
            # desc(niveau), .by_group=TRUE)
# Warnings_frequency_short$npv_pct =
    # round(Warnings_frequency_short$npv_pct)
# print(Warnings_frequency_short, n=Inf)


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
