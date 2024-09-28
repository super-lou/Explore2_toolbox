


get_netcdf = function (Urls, outdir) {
    if (!dir.exists(outdir)) {
        dir.create(outdir, showWarnings=FALSE)
    }
    options(timeout=300)
    nUrls = length(Urls)
    
    for (i in 1:nUrls) {
        url = Urls[i]
        print(paste0(i, "/", nUrls, " -> ",
                     round(i/nUrls*100, 2), "%"))
        file = basename(url)
        format = gsub(".*[.]", "", file)
        path = file.path(outdir, file)
        download.file(url, destfile=path, mode="wb")
        if (format == "zip") {
            unzip(path, exdir=outdir)
            Paths = list.files(gsub(".zip", "", path),
                               full.names=TRUE)
            file.rename(Paths,
                        file.path(outdir, basename(Paths)))
            unlink(unique(dirname(Paths)), recursive=TRUE)
            unlink(path, recursive=TRUE)
        }
    }
}




read_netcdf_projections = function (Paths, Codes) {

    data = dplyr::tibble()
    
    for (path in Paths) {
        NC = ncdf4::nc_open(path)

        Date = ncdf4::ncvar_get(NC, "time") +
            as.Date("1950-01-01")
        nDate = length(Date)

        Codes_NC = ncdf4::ncvar_get(NC, "code")
        nCodes_NC = length(Codes_NC)
        
        Codes = Codes[Codes %in% Codes_NC]
        Codes = sort(Codes)
        nCodes = length(Codes)
        
        Id = match(Codes, Codes_NC)
        Id = Id[!is.na(Id)]
        if (all(is.na(Id))) {
            ncdf4::nc_close(NC)
            return (NULL)
        }

        start = min(Id)
        count = max(Id) - start + 1
        Id = Id - start + 1
        Q = ncdf4::ncvar_get(NC, "debit",
                             start=c(start, 1),
                             count=c(count, -1))
        Q = matrix(Q, nrow=count)
        Q = Q[Id,, drop=FALSE]
        Q = c(t(Q))

        path_info = unlist(strsplit(path, "_"))
        
        data_tmp =
            dplyr::tibble(EXP=path_info[5],
                          GCM=path_info[4],
                          RCM=path_info[7],
                          BC=path_info[9],
                          HM=path_info[10],
                          code=rep(Codes, each=nDate),
                          date=rep(Date, times=nCodes),
                          Q=Q)

        data = dplyr::bind_rows(data, data_tmp)
        
        ncdf4::nc_close(NC)
    }

    # Il y a une erreur dans le formatage des noms de fichier pour J2000
    data$BC = gsub("MF-ADAMONT-SAFRAN-France-1980-2011",
                   "MF-ADAMONT-SAFRAN-1980-2011", data$BC)

    data$climate_chain = paste(data$EXP,
                               data$GCM,
                               data$RCM,
                               data$BC,
                               sep="|")
    data = dplyr::relocate(data, climate_chain, .after=HM)
    data$chain = paste(data$climate_chain,
                       data$HM,
                       sep="|")
    data = dplyr::relocate(data, chain, .after=climate_chain)
    return (data)
}


merge_data_projections = function (data) {
    
    Chain = data$chain
    
    
    return (data)
}



get_breaks = function(X) {
    breaks = "10 years"
    Xmin = round(lubridate::year(min(X)), -1)
    Xmax = round(lubridate::year(max(X)), -1)
    if (Xmax-Xmin <= 1) {
        Xmin = lubridate::year(X)[1]
        Xmax = lubridate::year(X)[1] + 1
    }
    res = seq.Date(from=as.Date(paste0(Xmin, "-01-01")),
                   to=as.Date(paste0(Xmax, "-01-01")),
                   by=breaks)
    return (res)
}

get_minor_breaks = function(X) {
    breaks = "10 years"
    minor_breaks = "2 years"
    Xmin = round(lubridate::year(min(X)), -1)
    Xmax = round(lubridate::year(max(X)), -1)
    if (Xmax-Xmin <= 1) {
        Xmin = lubridate::year(X)[1]
        Xmax = lubridate::year(X)[1] + 1
    }
    res = seq.Date(from=as.Date(
                       as.Date(paste0(Xmin, "-01-01")) -
                       lubridate::duration(breaks)),
                   to=as.Date(
                       as.Date(paste0(Xmax, "-01-01")) +
                       lubridate::duration(breaks)),
                   by=minor_breaks)
    return (res)
}
