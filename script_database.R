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


## 1. DATABASE ______________________________________________
if ('create_database' %in% to_do) {
    
    library(DBI)
    library(RPostgreSQL)
    
    db_host = "127.0.0.1"
    db_port = 5432
    db_name = "explore2"
    db_user = "dora"
    db_password = "Chipeur_arrete_2_chiper"

    con = dbConnect(
        RPostgreSQL::PostgreSQL(),
        dbname=db_name,
        host=db_host,
        port=db_port,
        user=db_user,
        password=db_password
    )

    Projections = dplyr::relocate(Projections, EXP, .before=GCM)
    Projections = dplyr::select(Projections, -Chain)
    Projections$Chain = paste(Projections$EXP,
                              Projections$GCM,
                              Projections$RCM,
                              Projections$BC,
                              Projections$HM, sep="|")
    Projections$Chain = gsub("NA[|]NA[|]NA[|]",
                             "", Projections$Chain)

    Projections = Projections[Projections$EXP != "SAFRAN",]
    DirPaths = Projections$path
    nDirPath = length(DirPaths)
    
    stop()


    # Table for stations
    query = '
CREATE TABLE IF NOT EXISTS stations (
    code VARCHAR(255) PRIMARY KEY,
    code_hydro2 VARCHAR(255),
    name VARCHAR(255),
    hydrological_region VARCHAR(255),
    source VARCHAR(255),
    is_reference BOOLEAN,
    xl93_m DOUBLE PRECISION,
    yl93_m DOUBLE PRECISION,
    lon_deg DOUBLE PRECISION,
    lat_deg DOUBLE PRECISION,
    n INT,
    surface_km2 DOUBLE PRECISION,
    surface_ctrip_km2 DOUBLE PRECISION,
    surface_eros_km2 DOUBLE PRECISION,
    surface_grsd_km2 DOUBLE PRECISION,
    surface_j2000_km2 DOUBLE PRECISION,
    surface_mordor_sd_km2 DOUBLE PRECISION,
    surface_mordor_ts_km2 DOUBLE PRECISION,
    surface_orchidee_km2 DOUBLE PRECISION,
    surface_sim2_km2 DOUBLE PRECISION,
    surface_smash_km2 DOUBLE PRECISION
);
'
    dbExecute(con, query)

    # Table for projections
    query = '      
CREATE TABLE IF NOT EXISTS projections (
    chain VARCHAR(255) PRIMARY KEY,
    exp VARCHAR(255),    
    gcm VARCHAR(255),
    rcm VARCHAR(255),
    bc VARCHAR(255),
    hm VARCHAR(255),
    storylines VARCHAR(255)
);
'
    dbExecute(con, query)
    
    
    # Table for variables
    query = '      
CREATE TABLE IF NOT EXISTS variables (
    variable_en VARCHAR(255) PRIMARY KEY,
    unit_en VARCHAR(255),
    name_en VARCHAR(255),
    description_en VARCHAR(1000),
    method_en VARCHAR(1000),
    sampling_period_en VARCHAR(255),
    topic_en VARCHAR(255),
    variable_fr VARCHAR(255),
    unit_fr VARCHAR(255),
    name_fr VARCHAR(255),
    description_fr VARCHAR(1000),
    method_fr VARCHAR(1000),
    sampling_period_fr VARCHAR(255),
    topic_fr VARCHAR(255),
    is_date BOOLEAN,
    to_normalise BOOLEAN,
    palette VARCHAR(255)
);
'
    dbExecute(con, query)
    
    # Table for time series data
    #         query = "
    # DROP SEQUENCE IF EXISTS data_id_seq;
    # CREATE SEQUENCE data_id_seq START 1 INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1;

    # CREATE TABLE IF NOT EXISTS data (
    #     id BIGINT DEFAULT nextval('data_id_seq'::regclass) PRIMARY KEY,
    #     chain VARCHAR(255) REFERENCES projections(chain),
    #     variable_en VARCHAR(255) REFERENCES variables(variable_en),
    #     code VARCHAR(255) REFERENCES stations(code),
    #     date DATE,
    #     value DOUBLE PRECISION
    # );
    # "
    #         # chain VARCHAR(255) REFERENCES projections(chain),
    #         dbExecute(con, query)




    
    Stations = dplyr::tibble()
    for (j in 1:nDirPath) {
        if (nrow(Stations) == 0) {
            Stations = read_tibble(file.path(DirPaths[j],
                                             "meta.fst"))
        } else {
            Stations =
                dplyr::full_join(
                           Stations,
                           read_tibble(file.path(DirPaths[j],
                                                 "meta.fst")))
        }
    }
    Stations$is_reference = as.logical(Stations$reference)
    Stations = dplyr::select(Stations, -reference)
    Stations =
        dplyr::left_join(Stations,
                         dplyr::select(codes_selection_data,
                                       code_hydro2=CODE,
                                       code=SuggestionCode),
                         by="code")
    Stations = dplyr::rename(Stations,
                             "surface_MORDOR_SD_km2"=
                                 "surface_MORDOR-SD_km2",
                             "surface_MORDOR_TS_km2"=
                                 "surface_MORDOR-TS_km2")
    Stations = dplyr::relocate(Stations,
                               is_reference,
                               .after=code)
    Stations = dplyr::relocate(Stations,
                               code_hydro2,
                               .after=code)
    Stations =
        dplyr::mutate(Stations,
                      n=
                          as.numeric(!is.na(surface_CTRIP_km2)) +
                          as.numeric(!is.na(surface_EROS_km2)) +
                          as.numeric(!is.na(surface_GRSD_km2)) +
                          as.numeric(!is.na(surface_J2000_km2)) +
                          as.numeric(!is.na(surface_MORDOR_SD_km2)) +
                          as.numeric(!is.na(surface_MORDOR_TS_km2)) +
                          as.numeric(!is.na(surface_ORCHIDEE_km2)) +
                          as.numeric(!is.na(surface_SIM2_km2)) +
                          as.numeric(!is.na(surface_SMASH_km2)))
    Stations = dplyr::relocate(Stations, n, .before=code)

    Stations_sf = sf::st_as_sf(Stations, coords=c("XL93_m", "YL93_m"))
    sf::st_crs(Stations_sf) = sf::st_crs(2154)
    Stations_sf = sf::st_transform(Stations_sf, 4326)    
    get_lon = function (id) {
        Stations_sf$geometry[[id]][1]
    }
    get_lat = function (id) {
        Stations_sf$geometry[[id]][2]
    }
    Stations$lon_deg = sapply(1:nrow(Stations_sf), get_lon)
    Stations$lat_deg = sapply(1:nrow(Stations_sf), get_lat)
    Stations = dplyr::relocate(Stations,
                               lon_deg,
                               .after=YL93_m)
    Stations = dplyr::relocate(Stations,
                               lat_deg,
                               .after=lon_deg)
    
    write_tibble(Stations, today_resdir,
                 "stations_selection.csv")


    print("verif I/O for stations")
    HM = levels(factor(Projections$HM))
    for (hm in HM) {
        n =
            sum(sort(Stations$code[!is.na(Stations[[paste0("Surface_",
                                                       hm, "_km2")]])]) !=
                sort(codes_selection_data$SuggestionCode[as.logical(codes_selection_data[[hm]])]))
        print(paste0(hm, " ", n))
    }

    

    DirPaths = Projections$path
    nDirPath = length(DirPaths)
    Projections_tmp = dplyr::select(Projections,
                                    -c(climateChain, regexp,
                                       dir, file, path))
    Projections_tmp$Chain = gsub("[|]", "_", Projections_tmp$Chain)
    

    
    Paths = list.files(DirPaths[1],
                       pattern="metaEX",
                       full.names=TRUE)
    nPath = length(Paths)
    Variables = dplyr::tibble()
    for (j in 1:nPath) {
        Variables_tmp = read_tibble(Paths[j])
        Variables_tmp =
            Variables_tmp[grepl(variables_regexp,
                                Variables_tmp$variable_en),]
        if (nrow(Variables_tmp) == 0) {
            next
        }
        
        Variables = dplyr::bind_rows(Variables, Variables_tmp)
    }


    ###
    names(Stations) = tolower(names(Stations))
    dbWriteTable(con, "stations", Stations,
                 append=TRUE, row.names=FALSE)
    ###
    names(Projections_tmp) = tolower(names(Projections_tmp))
    dbWriteTable(con, "projections", Projections_tmp,
                 append=TRUE, row.names=FALSE)
    ###
    names(Variables_tmp) = tolower(names(Variables_tmp))
    dbWriteTable(con, "variables", Variables,
                 append=TRUE, row.names=FALSE)
    ###
    

    
    
    EXP = levels(factor(Projections$EXP))
    for (exp in EXP) {
        Projections_exp = Projections[Projections$EXP == exp,]

        for (var in Variables$variable_en) {
            print(paste0(exp, " ", var))

            Paths = list.files(Projections_exp$path,
                               pattern="dataEX",
                               include.dirs=TRUE,
                               full.names=TRUE)
            Paths = list.files(Paths,
                               pattern=paste0("^",
                                              gsub("[_]",
                                                   "[_]",
                                                   var),
                                              "[.]fst"),
                               full.names=TRUE)
            nPath = length(Paths)

            
            for (k in 1:nFuturs) {
                futur = Futurs[[k]]
                name_futur = names(Futurs)[k]
                print(name_futur)

                delta_id = tolower(paste0(gsub("[-]", "_", exp),
                                          "_", var,
                                          "_", name_futur))
                delta_name = paste0("delta_", delta_id)
                query = paste0("
CREATE TABLE IF NOT EXISTS ", delta_name, " (
    id SERIAL PRIMARY KEY,
    chain VARCHAR(255) REFERENCES projections(chain),
    exp VARCHAR(255),    
    gcm VARCHAR(255),
    rcm VARCHAR(255),
    bc VARCHAR(255),
    hm VARCHAR(255),
    variable_en VARCHAR(255) REFERENCES variables(variable_en),
    code VARCHAR(255) REFERENCES stations(code),
    n INT,
    value DOUBLE PRECISION
);
")
                dbExecute(con, query)

                for (j in 1:nPath) {
                    print(paste0(j, "/", nPath, " -> ",
                                 round(j/nPath*100, 1), " %"))
                    
                    path = Paths[j]
                    path = gsub("projection",
                                paste0("projection_delta_",
                                       name_futur),
                                path)
                    Delta_tmp = read_tibble(path)
                    Delta_tmp =
                        dplyr::select(Delta_tmp,
                                      -c("historical", "futur"))
                    Delta_tmp =
                        dplyr::rename(Delta_tmp,
                                      value=dplyr::where(is.numeric))
                    Delta_tmp$variable_en = gsub("[.]fst", "",
                                                 basename(Paths[j]))
                    
                    Delta_tmp$Chain = paste(Delta_tmp$EXP,
                                            Delta_tmp$GCM,
                                            Delta_tmp$RCM,
                                            Delta_tmp$BC,
                                            Delta_tmp$HM, sep="_")
                    Delta_tmp =
                        dplyr::left_join(Delta_tmp,
                                         dplyr::select(Stations,
                                                       code, n),
                                         by="code")

                    names(Delta_tmp) = tolower(names(Delta_tmp))
                    ###
                    dbWriteTable(con, delta_name, Delta_tmp,
                                 append=TRUE, row.names=FALSE)
                    ###
                }
            }




#             data_id = tolower(paste0(gsub("[-]", "_", exp),
#                                      "_", var))
#             data_name = paste0("data_", data_id)
#             query = paste0("
# CREATE TABLE IF NOT EXISTS ", data_name, " (
#     id SERIAL PRIMARY KEY,
#     chain VARCHAR(255) REFERENCES projections(chain),
#     exp VARCHAR(255),    
#     gcm VARCHAR(255),
#     rcm VARCHAR(255),
#     bc VARCHAR(255),
#     hm VARCHAR(255),
#     variable_en VARCHAR(255) REFERENCES variables(variable_en),
#     code VARCHAR(255) REFERENCES stations(code),
#     n INT,
#     date DATE,
#     value DOUBLE PRECISION
# );
# ")
#             dbExecute(con, query)
            
#             for (j in 1:nPath) {
#                 print(paste0(j, "/", nPath, " -> ",
#                              round(j/nPath*100, 1), " %"))
                
#                 path = Paths[j]
#                 Data_tmp = read_tibble(path)
#                 Data_tmp =
#                     dplyr::rename(Data_tmp,
#                                   value=dplyr::where(is.numeric))
#                 Data_tmp$variable_en = gsub("[.]fst", "",
#                                             basename(Paths[j]))
                
#                 Data_tmp$Chain = paste(Data_tmp$EXP,
#                                        Data_tmp$GCM,
#                                        Data_tmp$RCM,
#                                        Data_tmp$BC,
#                                        Data_tmp$HM, sep="_")
#                 Data_tmp =
#                     dplyr::left_join(Data_tmp,
#                                      dplyr::select(Stations, code, n),
#                                      by="code")

#                 names(Data_tmp) = tolower(names(Data_tmp))
#                 ###
#                 dbWriteTable(con, data_name, Data_tmp,
#                              append=TRUE, row.names=FALSE)
#                 ###
#             }
        }
    }



    
    dbDisconnect(con)  
}



