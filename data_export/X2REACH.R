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


library(sf)

Xdir = "pointSimulationHYDRO_20220928"
Xfile = "pointSimulationHYDRO_20220928.shp"

REACHdir = "COURS D EAU FXX-shp"
REACHfile = "COURS_D_EAU.shp"


# path
Xpath = file.path(Xdir, Xfile)
REACHpath = file.path(REACHdir, REACHfile)

# X
X = st_read(Xpath)
X = st_cast(X, "POINT")

# REACH
REACH = st_read(REACHpath)
REACH = st_transform(REACH, 2154)

# Get id
ID = st_nearest_feature(X, REACH)

# Extract code hydro
CODE = as.character(REACH$CODE_HYDRO[ID])
