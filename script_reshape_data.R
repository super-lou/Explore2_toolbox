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




if (type == "piezometrie") {
    NCdata = ncdf4::nc_open(file.path(
                        computer_data_path,
                        type,
                        raw_data_piezo_file))


    Date = NetCDF_extrat_time(NCdata)
    nDate = length(Date)

    Code_bss = ncdf4::ncvar_get(NCdata, "code_bss")
    nCode = length(Code_bss)
    Code_bdlisa = ncdf4::ncvar_get(NCdata, "codes_bdlisa")

    Model = ncdf4::ncvar_get(NCdata, "MODELE")
    
    libelle_pe = ncdf4::ncvar_get(NCdata, "libelle_pe")
    nb_mesures_piezo = ncdf4::ncvar_get(NCdata, "nb_mesures_piezo")
    altitude_sation = ncdf4::ncvar_get(NCdata, "altitude_sation")
    X = ncdf4::ncvar_get(NCdata, "x")
    Y = ncdf4::ncvar_get(NCdata, "y")

    hobs = ncdf4::ncvar_get(NCdata, "hobs")
    hsim = ncdf4::ncvar_get(NCdata, "hsim")
    nash_spli = ncdf4::ncvar_get(NCdata, "nash_spli")
    nash_spli[!is.finite(nash_spli)] = NA
    correlation = ncdf4::ncvar_get(NCdata, "correlation")
    bias = ncdf4::ncvar_get(NCdata, "bias")
    nash_ss_biais = ncdf4::ncvar_get(NCdata, "nash_ss_biais")

    # date_debut_mesure = ncdf4::ncvar_get(NCdata, "date_debut_mesure")
    # date_fin_mesure = ncdf4::ncvar_get(NCdata, "date_fin_mesure")

    ncdf4::nc_close(NCdata)
    
    H_obs = matrix(hobs, nrow=nCode)
    H_obs = c(t(H_obs))
    H_sim = matrix(hsim, nrow=nCode)
    H_sim = c(t(H_sim))
    
    data = dplyr::tibble(Model=rep(Model, each=nDate),
                         Code=rep(Code_bss, each=nDate),
                         Date=rep(Date, times=nCode),
                         H_obs=H_obs,
                         H_sim=H_sim)

    meta = dplyr::tibble(Code=Code_bss,
                         Couche=Code_bdlisa,
                         Nom=libelle_pe,
                         Altitude_m=altitude_sation,
                         XL93_m=X,
                         YL93_m=Y)

    Couche = strsplit(meta$Couche, "', '")
    Couche[lapply(Couche, length) == 0] = ""
    meta$Couche = sapply(lapply(Couche, substr, 1, 3), paste0, collapse="|")
    
    meta$Nom =
        gsub(" A ", " à ",
             gsub("L ", "l'",
                  gsub("^L ", "L'",
                       stringr::str_to_title(
                                    gsub("L'", "L ",
                                         meta$Nom
                                         )))))
    
    dataEX_Explore2_criteria_diag_performance =
        dplyr::tibble(Model=Model,
                      Code=Code_bss,
                      NSEbiais=nash_ss_biais,
                      NSEips=nash_spli,
                      Biais=bias,
                      r=correlation)
    
    metaEX_Explore2_criteria_diag_performance =
        dplyr::tibble(
                   var=c("NSEbiais",
                         "NSEips", "Biais",
                         "r"),
                   unit="sans unité",
                   is_date=FALSE,
                   normalize=FALSE,
                   reverse_palette=FALSE,
                   glose=c(
                       "Coeffcient d'efficacité de Nash-Sutcliffe des débits retranchés du biais",
                       "Coeffcient d'efficacité de Nash-Sutcliffe entre l’Indicateur Piézomètre Standardisé (IPS) simulé et l’IPS observé",
                       "Différence entre les moyennes des débits journaliers simulés et observés",
                       "Corrélation"),
                   topic="Performance",
                   samplePeriod="")

    write_tibble(data,
                 filedir=tmppath,
                 filename="data.fst")
    
    write_tibble(meta,
                 filedir=tmppath,
                 filename="meta.fst")

    write_tibble(dataEX_Explore2_criteria_diag_performance,
                 filedir=tmppath,
                 filename="dataEX_Explore2_criteria_diag_performance.fst")
    
    write_tibble(metaEX_Explore2_criteria_diag_performance,
                 filedir=tmppath,
                 filename="metaEX_Explore2_criteria_diag_performance.fst")


    create_ok = TRUE
}


