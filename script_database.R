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
    dotenv::load_dot_env()
    
    db_host = "127.0.0.1"
    db_port = 5432
    db_name = "explore2"
    db_user = "dora"
    db_password = Sys.getenv("DB_PASSWORD")

    con = dbConnect(
        RPostgreSQL::PostgreSQL(),
        dbname=db_name,
        host=db_host,
        port=db_port,
        user=db_user,
        password=db_password
    )
    
    
    ## Stations
    Stations = codes_selection_data

    ## Projections
    Projections = Projections[Projections$EXP != "SAFRAN",]
    Projections = dplyr::relocate(Projections, EXP, .before=GCM)
    Projections = dplyr::select(Projections, -Chain)
    Projections = tidyr::unite(Projections,
                               "Chain",
                               "EXP", "GCM", 
                               "RCM", "BC",
                               "HM",
                               sep="|",
                               remove=FALSE)
    
    DirPaths = Projections$path
    nDirPath = length(DirPaths)
    Projections_tmp = dplyr::select(Projections,
                                    -c(climateChain, regexp,
                                       dir, file, path))
    Projections_tmp$Chain = gsub("[|]", "_", Projections_tmp$Chain)
    

    ## Variables
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
    
    # stop()
    

#     # Table for stations
#     query = '
# CREATE TABLE IF NOT EXISTS stations (
#     n INT,
#     n_rcp26 INT,    
#     n_rcp45 INT,
#     n_rcp85 INT,
#     code VARCHAR(255) PRIMARY KEY,
#     code_hydro2 VARCHAR(255),
#     is_reference BOOLEAN,
#     name VARCHAR(255),
#     hydrological_region VARCHAR(255),
#     source VARCHAR(255),
#     xl93_m DOUBLE PRECISION,
#     yl93_m DOUBLE PRECISION,
#     lon_deg DOUBLE PRECISION,
#     lat_deg DOUBLE PRECISION,
#     surface_km2 DOUBLE PRECISION,
#     surface_ctrip_km2 DOUBLE PRECISION,
#     surface_eros_km2 DOUBLE PRECISION,
#     surface_grsd_km2 DOUBLE PRECISION,
#     surface_j2000_km2 DOUBLE PRECISION,
#     surface_mordor_sd_km2 DOUBLE PRECISION,
#     surface_mordor_ts_km2 DOUBLE PRECISION,
#     surface_orchidee_km2 DOUBLE PRECISION,
#     surface_sim2_km2 DOUBLE PRECISION,
#     surface_smash_km2 DOUBLE PRECISION,
#     n_ctrip INT,
#     n_eros INT,
#     n_grsd INT,
#     n_j2000 INT,
#     n_mordor_sd INT,
#     n_mordor_ts INT,
#     n_orchidee INT,
#     n_sim2 INT,
#     n_smash INT,
#     n_rcp26_ctrip INT,
#     n_rcp26_eros INT,
#     n_rcp26_grsd INT,
#     n_rcp26_j2000 INT,
#     n_rcp26_mordor_sd INT,
#     n_rcp26_mordor_ts INT,
#     n_rcp26_orchidee INT,
#     n_rcp26_sim2 INT,
#     n_rcp26_smash INT,
#     n_rcp45_ctrip INT,
#     n_rcp45_eros INT,
#     n_rcp45_grsd INT,
#     n_rcp45_j2000 INT,
#     n_rcp45_mordor_sd INT,
#     n_rcp45_mordor_ts INT,
#     n_rcp45_orchidee INT,
#     n_rcp45_sim2 INT,
#     n_rcp45_smash INT,
#     n_rcp85_ctrip INT,
#     n_rcp85_eros INT,
#     n_rcp85_grsd INT,
#     n_rcp85_j2000 INT,
#     n_rcp85_mordor_sd INT,
#     n_rcp85_mordor_ts INT,
#     n_rcp85_orchidee INT,
#     n_rcp85_sim2 INT,
#     n_rcp85_smash INT
# );
# '
#     dbExecute(con, query)

#     # Table for projections
#     query = '      
# CREATE TABLE IF NOT EXISTS projections (
#     chain VARCHAR(255) PRIMARY KEY,
#     exp VARCHAR(255),    
#     gcm VARCHAR(255),
#     rcm VARCHAR(255),
#     bc VARCHAR(255),
#     hm VARCHAR(255),
#     storylines VARCHAR(255)
# );
# '
#     dbExecute(con, query)
    
    
#     # Table for variables
#     query = '      
# CREATE TABLE IF NOT EXISTS variables (
#     variable_en VARCHAR(255) PRIMARY KEY,
#     unit_en VARCHAR(255),
#     name_en VARCHAR(255),
#     description_en VARCHAR(1000),
#     method_en VARCHAR(1000),
#     sampling_period_en VARCHAR(255),
#     topic_en VARCHAR(255),
#     variable_fr VARCHAR(255),
#     unit_fr VARCHAR(255),
#     name_fr VARCHAR(255),
#     description_fr VARCHAR(1000),
#     method_fr VARCHAR(1000),
#     sampling_period_fr VARCHAR(255),
#     topic_fr VARCHAR(255),
#     is_date BOOLEAN,
#     to_normalise BOOLEAN,
#     palette VARCHAR(255)
# );
# '
#     dbExecute(con, query)

#     ###
#     names(Stations) = tolower(names(Stations))
#     dbWriteTable(con, "stations", Stations,
#                  append=TRUE, row.names=FALSE)
#     ###
#     names(Projections_tmp) = tolower(names(Projections_tmp))
#     dbWriteTable(con, "projections", Projections_tmp,
#                  append=TRUE, row.names=FALSE)
#     ###
#     names(Variables) = tolower(names(Variables))
#     dbWriteTable(con, "variables", Variables,
#                  append=TRUE, row.names=FALSE)
#     ###
    


    Variables_delta = Variables$variable_en
    Variables_delta = Variables_delta[grepl("delta", Variables_delta)]
    Variables_delta = gsub("[_]H[[:digit:]]", "_H", Variables_delta)
    Variables_delta = Variables_delta[!duplicated(Variables_delta)]
    
    Variables_serie = Variables$variable_en
    Variables_serie = Variables_serie[!grepl("delta", Variables_serie)]

    EXP = levels(factor(Projections$EXP))
    
    for (exp in EXP) {
        # exp=EXP[1]
        exp_no_hist = gsub(".*[-]", "", exp)
        n_exp = paste0("n_", exp_no_hist)
        
        Projections_exp = Projections[Projections$EXP == exp,]

#         ## Delta
#         for (var in Variables_delta) {
#             # var = Variables_delta[4]
#             print(paste0(exp, " ", var))
            
#             Paths = list.files(Projections_exp$path,
#                                pattern="dataEX",
#                                include.dirs=TRUE,
#                                full.names=TRUE)
#             var_no_delta = gsub("([{])|([}])", "",
#                                 gsub("delta", "",
#                                      gsub("[_]H",
#                                           "", var)))
#             pattern = paste0("^", var_no_delta, "[.]fst")
#             Paths = list.files(Paths,
#                                pattern=pattern,
#                                full.names=TRUE)
#             Paths = paste0(gsub("serie", "criteria",
#                                 dirname(Paths)), ".fst")
#             Paths = Paths[!duplicated(Paths)]
#             nPath = length(Paths)

#             for (k in 1:nFuturs) {
#                 var_h = paste0(var, k)
#                 futur = Futurs[[k]]
#                 name_futur = names(Futurs)[k]
#                 print(name_futur)

#                 delta_id = tolower(paste0(gsub("[-]", "_", exp),
#                                           "_", var_no_delta,
#                                           "_", name_futur))
#                 table_name = paste0("delta_", delta_id)
#                 query = paste0("
# CREATE TABLE IF NOT EXISTS ", table_name, " (
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
#     value DOUBLE PRECISION
# );
# ")
#                 dbExecute(con, query)

#                 for (j in 1:nPath) {
#                     print(paste0(j, "/", nPath, " -> ",
#                                  round(j/nPath*100, 1), " %"))
#                     path = Paths[j]
#                     dataEX = read_tibble(path)
#                     dataEX = dplyr::select(dataEX,
#                                            EXP, GCM, RCM, BC, HM,
#                                            code,
#                                            value=dplyr::all_of(var_h))
#                     dataEX$variable_en = var_h
#                     dataEX = tidyr::unite(dataEX,
#                                           "Chain",
#                                           "EXP", "GCM", 
#                                           "RCM", "BC",
#                                           "HM",
#                                           sep="_",
#                                           remove=FALSE)

#                     dataEX$code_Chain = paste0(dataEX$code, "_",
#                                                dataEX$Chain)
#                     dataEX = filter(dataEX,
#                                     !(code_Chain %in%
#                                       chain_to_remove$code_Chain))
#                     dataEX = select(dataEX, -code_Chain)
                    
#                     dataEX =
#                         left_join(dataEX,
#                                   select(Stations,
#                                          code, n=all_of(n_exp)),
#                                   by="code")
#                     dataEX = relocate(dataEX,
#                                       variable_en, .before=code)
#                     dataEX = relocate(dataEX, n, .before=value)

#                     names(dataEX) = tolower(names(dataEX))
#                     ###
#                     dbWriteTable(con, table_name, dataEX,
#                                  append=TRUE, row.names=FALSE)
#                     ###
#                 }

#                 index_name = paste0("idx_chain_n_", table_name)
#                 query = paste0("CREATE INDEX ", index_name,
#                                " ON ", table_name, " (chain, n);")
#                 dbExecute(con, query)

#                 index_name = paste0("idx_code_gcm_rcm_bc_", table_name)
#                 query = paste0("CREATE INDEX ", index_name,
#                                " ON ", table_name, " (code, gcm, rcm, bc);")
#                 dbExecute(con, query)
#             }
#         }

        
        ## Serie
        for (var in Variables_serie) {
            print(paste0(exp, " ", var))
            
            Paths = list.files(Projections_exp$path,
                               pattern="dataEX",
                               include.dirs=TRUE,
                               full.names=TRUE)
            pattern = paste0("^", var, "[.]fst")
            Paths = list.files(Paths,
                               pattern=pattern,
                               full.names=TRUE)
            Paths = Paths[!duplicated(Paths)]
            nPath = length(Paths)

            data_id = tolower(paste0(gsub("[-]", "_", exp), "_", var))
            table_name = paste0("delta_", data_id)
            query = paste0("
CREATE TABLE IF NOT EXISTS ", table_name, " (
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
    date DATE,
    value DOUBLE PRECISION
);
")
            dbExecute(con, query)

            for (j in 1:nPath) {
                print(paste0(j, "/", nPath, " -> ",
                             round(j/nPath*100, 1), " %"))
                
                path = Paths[j]
                dataEX = read_tibble(path)
                dataEX = dplyr::select(dataEX,
                                       EXP, GCM, RCM, BC, HM,
                                       code, date,
                                       value=dplyr::all_of(var))
                dataEX$variable_en = var
                dataEX = tidyr::unite(dataEX,
                                      "Chain",
                                      "EXP", "GCM", 
                                      "RCM", "BC",
                                      "HM", sep="_",
                                      remove=FALSE)

                dataEX$code_Chain = paste0(dataEX$code, "_",
                                           dataEX$Chain)
                dataEX = filter(dataEX,
                                !(code_Chain %in%
                                  chain_to_remove$code_Chain))
                dataEX = select(dataEX, -code_Chain)
                
                dataEX =
                    left_join(dataEX,
                              select(Stations,
                                     code, n=all_of(n_exp)),
                              by="code")
                dataEX = relocate(dataEX,
                                  variable_en, .before=code)
                dataEX = relocate(dataEX, n, .before=date)

                if (!grepl("medQJ", var)) {
                    dataEX_historical =
                        summarise(group_by(filter(dataEX,
                                                  historical[1] <= date &
                                                  date <= historical[2]),
                                           Chain, code),
                                  mean_value=mean(value, na.rm=TRUE),
                                  .groups="drop")
                    
                    dataEX = dplyr::left_join(dataEX, dataEX_historical,
                                              by=c("Chain", "code"))
                    dataEX$value =
                        (dataEX$value - dataEX$mean_value) /
                        dataEX$mean_value * 100
                    dataEX = select(dataEX, -mean_value)
                    dataEX$date =
                        as.Date(paste0(lubridate::year(dataEX$date), "-01-01"))
                    date_stat =
                        summarise(group_by(filter(dataEX, !is.na(value)),
                                           Chain, code),
                                  min_date=min(date, na.rm=TRUE),
                                  max_date=max(date, na.rm=TRUE),
                                  .groups="drop")
                    min_date = max(date_stat$min_date)
                    max_date = min(date_stat$max_date)
                    dataEX = dplyr::filter(dataEX,
                                           min_date <= date &
                                           date <= max_date)
                }

                names(dataEX) = tolower(names(dataEX))
                ###
                dbWriteTable(con, table_name, dataEX,
                             append=TRUE, row.names=FALSE)
                ###
            }
            
            index_name = paste0("idx_chain_code_", table_name)
            query = paste0("CREATE INDEX ", index_name,
                           " ON ", table_name, " (chain, code);")
            dbExecute(con, query)
        }
    }
    dbDisconnect(con)  
}



