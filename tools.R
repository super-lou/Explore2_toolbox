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

    if (type == "diag") { 
        if ("code" %in% names(NCdata$var)) {
            CodeRaw = ncdf4::ncvar_get(NCdata, "code")
        } else if ("code_hydro" %in% names(NCdata$var)) {
            CodeRaw = ncdf4::ncvar_get(NCdata, "code_hydro")
        }
        
    } else if (type == "proj") {
        CodeRaw = ncdf4::ncvar_get(NCdata, "code")
    }
 
    QRaw = ncdf4::ncvar_get(NCdata, "debit")
    ncdf4::nc_close(NCdata)
    
    CodeOrder = order(CodeRaw)
    Code = CodeRaw[CodeOrder]
    Q_sim = QRaw[CodeOrder,]
    nCode = length(Code)
    nDate = length(Date)
    
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
