
dir_in = "NetCDF"
dir_out = "NetCDF_JP" 

climate_chains =
    c("ADAMONT.*historical-rcp85.*HadGEM2.*ALADIN63",
      "ADAMONT.*historical-rcp85.*CNRM-CM5.*ALADIN63",
      "ADAMONT.*historical-rcp85.*EC-EARTH.*HadREM3-GA7",
      "ADAMONT.*historical-rcp85.*HadGEM2.*.*CCLM4-8-17")

HM =
    c("GRSD", "SIM2")

variables =
    c("QA_yr", "VCN10_seas", "QJXA")


chains = paste0(rep(climate_chains, each=length(HM)),
                ".*",
                rep(HM, length(climate_chains)))

variables_chains =
    paste0("^",
           rep(variables, each=length(chains)),
           ".*",
           rep(chains, length(variables)),
           ".*")

regexp = paste0(variables_chains, collapse="|")

Paths = list.files(dir_in, full.names=TRUE, recursive=TRUE)
Paths_in = Paths[grepl(regexp, basename(Paths))]

if (!dir.exists(dir_out)) {
    dir.create(dir_out)
}
Paths_out = file.path(dir_out, basename(Paths_in))

file.copy(Paths_in, Paths_out)
