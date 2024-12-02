



dir_in = "NetCDF"
dir_out = "/media/louis/One Touch/louis/NetCDF_blaise"


climate_chains =
    # c("ADAMONT.*historical-rcp85.*HadGEM2.*ALADIN63",
    #   "ADAMONT.*historical-rcp85.*CNRM-CM5.*ALADIN63",
    #   "ADAMONT.*historical-rcp85.*EC-EARTH.*HadREM3-GA7",
    #   "ADAMONT.*historical-rcp85.*HadGEM2.*.*CCLM4-8-17")
    ".*"
    
HM = c(
    "CTRIP",
    "EROS",
    "GRSD",
    "J2000",
    "MORDOR-SD",
    "MORDOR-TS",
    "ORCHIDEE",
    "SIM2",
    "SMASH"
)

variables = c(
    # "QA_yr",
    "QA_mon",
    "QA_seas"
    # "VCN10_seas",
    # "QJXA"
)


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

start_time = Sys.time()
file.copy(Paths_in, Paths_out)
end_time = Sys.time()

time_taken = end_time - start_time
file_info = file.info(dir_out)
file_size = file_info$size
file_size_MB = file_size / (1024^2)
speed = file_size_MB / as.numeric(time_taken, units="secs")

time_chr = paste0("Time taken : ", time_taken, " ", units(time_taken))
speed_chr = paste0("Speed : ", speed, "MB/s")
print(time_chr)
print(speed_chr)
