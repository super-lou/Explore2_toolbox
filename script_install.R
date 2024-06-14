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
# along with Explore2 R toolbox.
# If not, see <https://www.gnu.org/licenses/>.

# module load cv-standard
# module load gcc/4.9.3
# module load python
# module load geos
# module load proj
# module load gdal
# module load R/3.6.3

sudo apt install libcurl4-openssl-dev libxml2-dev libudunits2-dev libssl-dev
sudo apt-get install libgdal-dev gdal-bin
sudo apt-get install libcairo2-dev

if (!require(fst)) install.packages("fst")
if (!require(dplyr)) install.packages("dplyr")
if (!require(tidyr)) install.packages("tidyr")
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(ggtext)) install.packages("ggtext")
if (!require(qpdf)) install.packages("qpdf")
if (!require(gridExtra)) install.packages("gridExtra")
if (!require(gridtext)) install.packages("gridtext")
if (!require(ggh4x)) install.packages("ggh4x")
if (!require(shadowtext)) install.packages("shadowtext")
if (!require(png)) install.packages("png")
if (!require(ggrepel)) install.packages("ggrepel")
if (!require(latex2exp)) install.packages("latex2exp")
if (!require(sf)) install.packages("sf")
if (!require(stringr)) install.packages("stringr")
if (!require(ggtext)) install.packages("ggtext")
# if (!require(ncdf4)) install.packages("ncdf4")
if (!require(lubridate)) install.packages("lubridate")
if (!require(Cairo)) install.packages("Cairo")
if (!require(extrafont)) install.packages("extrafont")
if (!require(remotes)) install.packages("remotes")

remotes::install_github("coolbutuseless/svgparser")
