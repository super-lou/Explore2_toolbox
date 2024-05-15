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
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


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
