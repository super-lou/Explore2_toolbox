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

    if (model == "J2000") {
        data$Date = as.Date(data$Date)
        names(data) = c("Date", "Code", "Q_sim",
                        "ET0", "T", "Pl", "Ps", "P")
        data = dplyr::select(data, -"P")
        
    } else if (model == "MODCOU") {
        names(data) = c("Code", "Date", "Q_sim")

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

