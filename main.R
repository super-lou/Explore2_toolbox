

# Import ashes
dev_path = file.path(dirname(dirname(getwd())),
                     'ashes_project', 'ashes', 'R')
if (file.exists(dev_path)) {
    print('Loading ashes from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading ashes from package')
    library(ashes)
}

# Import Ex2D
dev_path = file.path(dirname(getwd()),
                     'Ex2D', 'R')
if (file.exists(dev_path)) {
    print('Loading Ex2D from local directory')
    list_path = list.files(dev_path, pattern='*.R$', full.names=TRUE)
    for (path in list_path) {
        source(path, encoding='UTF-8')    
    }
} else {
    print('Loading Ex2D from package')
    library(Ex2D)
}


library(dplyr)
library(ncdf4)
library(stringr)

data_dir = "data"

# dataJ2K_file = "DATA_DIAGNOSTIC_EXPLORE2_J2000_v0.Rdata"
# dataJ2K = loadRData(file.path(data_dir, dataJ2K_file))
# dataJ2K = convert_J2K(dataJ2K)

# dataSMASH_file = "SMASH_20220921.Rdata"
# dataSMASH = loadRData(file.path(data_dir, dataSMASH_file))
# Code = rle(dataSMASH$Code)$value
# /!\ length(levels(factor(dataSMASH$Date))) /!\ #


NetCDF_to_tibble = function (NetCDF_path) {
        
    NCdata = nc_open(NetCDF_path)

    print(NCdata)
    
    Date = as.Date(ncvar_get(NCdata, "time"),
               origin=as.Date(str_extract(ncatt_get(NCdata,
                                                    "time")$units,
                                          "[0-9]+-[0-9]+-[0-9]+")))
    CodeRaw = ncvar_get(NCdata, "code_hydro")
    QRaw = ncvar_get(NCdata, "debit")
    nc_close(NCdata)
    
    CodeOrder = order(CodeRaw)
    Code = CodeRaw[CodeOrder]
    Q = QRaw[CodeOrder,]
    nCode = length(Code)
    nDate = length(Date)
    
    data = tibble(
        Code=rep(Code, each=nDate),
        Date=rep(Date, times=nCode),
        Q=c(t(Q))
    )
    return (data)
}

dataSIM2_file = "Debits_modcou_19580801_20210731_day_METADATA.nc"
dataSIM2_path = file.path(data_dir, dataSIM2_file)
dataSIM2 = NetCDF_to_tibble(dataSIM2_path)



