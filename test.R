library(dplyr)

loadRData = function(fileName) {
    #loads an RData file, and returns it
    load(fileName)
    get(ls()[ls() != "fileName"])
}

set.seed(100)

# Number of point per stations
N = 20
# Code of stations
Code = c("A", "B", "C", "D", "E")
# Number of stations
nCode = length(Code)

# Date vector identical for each station
Date = seq.Date(from=as.Date("2000-01-01"),
                by="day", length.out=N)

# List of vector of value for a variable for each station
X = replicate(nCode, list(rnorm(N, mean=10, sd=1)))
names(X) = Code

# Creation of tibble
dataMordorTS =
    tibble(
        Code=rep(Code, each=N),
        Date=rep(Date, times=nCode),
        X=unlist(X, use.names=FALSE)
    )
dataMordorTS

# Creates filename
dataMordorTS_file = paste0("MordorTS", "_",
                           format(Sys.Date(), "%Y%m%d"),
                           ".Rdata")

# Writes data
save(dataMordorTS, file=dataMordorTS_file)

# Reads data
dataMordorTS_read = loadRData(dataMordorTS_file)
dataMordorTS_read
