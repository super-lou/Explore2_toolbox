# Copyright 2021-2024 Louis Héraut (louis.heraut@inrae.fr)*1,
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
# Explore2 R toolbox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Explore2 R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


historical = c("1976-01-01", "2005-08-31")
Futurs = list(H1=c("2021-01-01", "2050-12-31"),
              H2=c("2041-01-01", "2070-12-31"),
              H3=c("2070-01-01", "2099-12-31"))

futur = Futurs$H3
var = "VCN10_summer"
to_normalise = TRUE


dataEX =
    full_join(
        summarise(group_by(
            filter(dataEX,
                   historical[1] <= date &
                   date <= historical[2]),
            code, Chain, GCM, RCM, BC, HM),
            historical=mean(get(var)),
            .groups="drop"),

        summarise(group_by(
            filter(dataEX,
                   futur[1] <= date &
                   date <= futur[2]),
            code, Chain),
            futur=mean(get(var)),
            .groups="drop"),

        by=c("code", "Chain"))


if (to_normalise) {
    dataEX$delta =
        (dataEX$futur - dataEX$historical) /
        dataEX$historical * 100
} else {
    dataEX$delta =
        dataEX$futur - dataEX$historical
}

dataEX = summarize(group_by(dataEX,
                            code, GCM, RCM, BC),
                   meanDelta=mean(delta),
                   .groups="drop")

dataEX = summarize(group_by(dataEX,
                            code, GCM, RCM),
                   meanDelta=mean(meanDelta),
                   .groups="drop")

dataEX = summarize(group_by(dataEX,
                            code),
                   meanDelta=mean(meanDelta),
                   .groups="drop")
