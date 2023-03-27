

## 1. DOWNNLOAD ______________________________________________________
url = "https://filesender.renater.fr/download.php?token=09bc8cc9-dcf0-4306-8a71-476538b6d25d&files_ids=23308689"
data_dir = "J2000"


## 2. CHAIN __________________________________________________________
GCM = "CNRM-CM5"
EXP = "rcp26"
RCM = "ALADIN63"
BC = "ADAMONT"
Model = "J2000"


## 3. EXECUTION (do not modify if you are not aware) _________________
# import of install useful package
if (!require(ASHE)) remotes::install_gitub("super-lou/ASHE")
# link to data
if (!file.exists(data_dir)) {
    download.file(url, paste0(data_dir, ".zip"))
    unzip(zipfile=paste0(data_dir, ".zip"))
}

chain_dir = paste(GCM, EXP, RCM, BC, Model, sep="_")
dataEX_path = file.path(data_dir,
                        chain_dir,
                        "dataEXserie.fst")
metaEX_path = file.path(data_dir,
                        chain_dir,
                        "metaEXserie.fst")

dataEX = read_tibble(filepath=dataEX_path)
metaEX = read_tibble(filepath=metaEX_path)

print(dataEX)
print(metaEX)
