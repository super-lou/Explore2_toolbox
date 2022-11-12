# \\\
# Copyright 2021-2022 Louis Héraut*1
#
# *1   INRAE, France
#      louis.heraut@inrae.fr
#
# This file is part of Ashes R toolbox.
#
# Ashes R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ashes R toolbox is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.
# ///


#  ___            _     
# | _ ) __ _  ___(_) __ 
# | _ \/ _` |(_-<| |/ _|
# |___/\__,_|/__/|_|\__| _____________________________________________
## 1. MIN MAX ________________________________________________________                   
minNA = function (X, na.rm=TRUE) {
    if (all(is.na(X))) {
        return (NA)
    } else {
        return (min(X, na.rm=na.rm))
    }
}

maxNA = function (X, na.rm=TRUE) {
    if (all(is.na(X))) {
        return (NA)
    } else {
        return (max(X, na.rm=na.rm))
    }
}


## 2. WHICH MIN MAX __________________________________________________
which.minNA = function (x) {
    idMin = which.min(x)
    if (identical(idMin, integer(0))) {
        idMin = NA
    }
    return (idMin)
}

which.maxNA = function (x) {
    idMax = which.max(x)
    if (identical(idMax, integer(0))) {
        idMax = NA
    }
    return (idMax)
}
