

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

data_dir = "data"

# dataJ2K_file = "DATA_DIAGNOSTIC_EXPLORE2_J2000_v0.Rdata"
# dataJ2K = loadRData(file.path(data_dir, dataJ2K_file))
# dataJ2K = convert_J2K(dataJ2K)

dataSMASH_file = "SMASH_20220921.Rdata"
dataSMASH = loadRData(file.path(data_dir, dataSMASH_file))


Code = rle(dataSMASH$Code)$value
# /!\ length(levels(factor(dataSMASH$Date))) /!\ #


