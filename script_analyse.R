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


## 1. ANALYSING OF DATA ______________________________________________
if ('analyse_data' %in% to_do) {
    post("### Analaysing data")
    
    print("number of simulated station")
    print(summarise(group_by(dataEX_criteria, HM),
                    n=length(unique(code))))
    print("")
    
    print("Choice of best modele for complete")
    # which(is.na(meta$Surface_km2))
    # which(is.na(meta[["Surface_MORDOR-SD_km2"]]))
    # which(is.na(meta$Surface_SMASH_km2))
    SMASH_surface =
        sum(abs(meta$surface_km2 - meta[["surface_SMASH_km2"]]) /
            meta$surface_km2,
            na.rm=TRUE)
    MORDOR_SD_surface =
        sum(abs(meta$surface_km2 - meta[["surface_MORDOR-SD_km2"]]) /
        meta$surface_km2,
        na.rm=TRUE)
    print("SMASH")
    print(SMASH_surface)
    print("MORDOR-SD")
    print(MORDOR_SD_surface)
    print("")
    
    print("Surface relative supérieur à 50 %")
    for (hm in HM_to_use) {
        dS_rel = abs(meta[[paste0("surface_", hm, "_km2")]] - meta$surface_km2)/meta$surface_km2
        dS_rel[is.na(dS_rel)] = 0
        print(hm)
        print(meta$code[dS_rel>0.2])
    }
}
