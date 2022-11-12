# \\\
# Copyright 2021-2022 Louis Héraut*1,
#                     Éric Sauquet*2,
#                     Valentin Mansanarez
#
# *1   INRAE, France
#      louis.heraut@inrae.fr
# *2   INRAE, France
#      eric.sauquet@inrae.fr
#
# This file is part of ash R toolbox.
#
# Ash R toolbox is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Ash R toolbox is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.
# ///
#
#
# R/script_analyse.R
#
# Script that manages the call to the right process in order to
# realise analyses.


## 1. STATION TREND ANALYSIS _________________________________________
if ('station_trend_analyse' %in% to_do) {

    script_to_analyse_dirpath = file.path('R', var_dir, var_to_analyse_dir)
    
    script_to_analyse = list.files(script_to_analyse_dirpath,
                                   pattern=".R$",
                                   recursive=TRUE,
                                   include.dirs=FALSE,
                                   full.names=FALSE)

    script_to_analyse = script_to_analyse[!grepl("default.R",
                                                 script_to_analyse)]

    event_to_analyse = list.dirs(script_to_analyse_dirpath,
                                 recursive=TRUE, full.names=FALSE)
    event_to_analyse = event_to_analyse[event_to_analyse != ""]
    event_to_analyse = gsub('.*_', '', event_to_analyse)

    structure = replicate(length(event_to_analyse), c())
    names(structure) = event_to_analyse
    
    var_analyse = c()
    type_analyse = c()
    event_analyse = c()
    unit_analyse = c()
    samplePeriod_analyse = list()
    glose_analyse = c()
    df_data_analyse = list()
    df_trend_analyse = list()
    
### 1.3. Trend analyses ______________________________________________
    for (script in script_to_analyse) {

        if (samplePeriodY_mode == 'every') {
            nSamplePeriod = 12
        } else {
            nSamplePeriod = 1
        }
            
        for (iHY in 1:nSamplePeriod) {

            source(file.path('R', var_dir, init_var_file),
                   encoding='UTF-8')
            source(file.path('R', var_dir, init_tools_file),
                   encoding='UTF-8')
            source(file.path(script_to_analyse_dirpath, script),
                   encoding='UTF-8')
            split_script = split_path(script)
            
            if (length(split_script) == 1) {
                if (!('None' %in% names(structure))) {
                    structure = append(list(None=c()), structure)
                }
                structure[['None']] = c(structure[['None']], var)
            } else if (length(split_script) == 2) {
                dir = split_script[2]
                dir = gsub('.*_', '', dir)
                structure[[dir]] = c(structure[[dir]], var)
            }
            
            if (samplePeriodY_mode == 'every') {
                samplePeriodY = paste0(formatC(iHY, width=2, flag="0"),
                                     '-01')
                
            } else if (samplePeriodY_mode == 'optimale') {
                if (identical(samplePeriodY_opti[[event]], "min")) {
                    Value = paste0(formatC(df_meta$minQM,
                                           width=2,
                                           flag="0"),
                                   '-01')
                    samplePeriodY = tibble(Code=df_meta$Code,
                                         Value=Value)
                } else if (identical(samplePeriodY_opti[[event]], "max")) {
                    Value = paste0(formatC(df_meta$maxQM,
                                           width=2,
                                           flag="0"),
                                   '-01')
                    samplePeriodY = tibble(Code=df_meta$Code,
                                         Value=Value)
                } else {
                    samplePeriodY = samplePeriodY_opti[[event]]
                }
            }
            monthSamplePeriod = substr(samplePeriodY[1], 1, 2)

            if (var %in% var_analyse) {
                next
            }
            
            var_analyse = c(var_analyse, var)
            type_analyse = c(type_analyse, type)
            event_analyse = c(event_analyse, event)
            unit_analyse = c(unit_analyse, unit)
            samplePeriod_analyse = append(samplePeriod_analyse,
                                          list(samplePeriodY))
            glose_analyse = c(glose_analyse, glose)

            missingCode = c()
            if (read_results) {
                trend_path = file.path(trend_dir, var, monthSamplePeriod)
                isExtract = file.exists(file.path(resdir, trend_path,
                                                  'extract.txt'))
                isEstimate = file.exists(file.path(resdir, trend_path,
                                                   'estimate.txt'))

                if (isExtract & isEstimate) {
                    res_Xanalyse_save = read_analyse(resdir, trend_path)
                    df_XEx_save = res_Xanalyse_save$extract
                    df_Xtrend_save = res_Xanalyse_save$estimate

                    df_XEx_read = df_XEx_save[df_XEx_save$Code %in% Code,]
                    df_Xtrend_read = df_Xtrend_save[df_Xtrend_save$Code %in% Code,]
                    df_Xtrend_read = df_Xtrend_read[df_Xtrend_read$input_period %in% input_trend_period,]
                    res_Xanalyse_read = list(extract=df_XEx_read, estimate=df_Xtrend_read)
                    
                    # modified_data_path = file.path(modified_data_dir, var,
                                                   # monthSamplePeriod)
                    
                    # df_Xdata_read = tibble()
                    # df_Xmod_read = tibble()
                    for (code in Code) {
                        # nameDataMod = paste0(code, '.txt')
                        # isCodeDataMod = file.exists(
                        #     file.path(resdir,
                        #               modified_data_path,
                        #               nameDataMod))
                        
                        # nameMod = paste0(code, '_modification.txt')
                        # isCodeMod = file.exists(
                        #     file.path(resdir,
                        #               modified_data_path,
                        #               nameMod))

                        # if (isCodeDataMod & isCodeMod) {
                        #     df_Xdata_code = read_data(resdir,
                        #                               modified_data_path,
                        #                               nameDataMod)
                        #     df_Xmod_code = read_data(resdir,
                        #                              modified_data_path,
                        #                              nameMod)
                        #     df_Xdata_read = rbind(df_Xdata_read, df_Xdata_code)
                        #     df_Xmod_read = rbind(df_Xmod_read, df_Xmod_code)
                        # }

                        isCodeExtract = any(code %in% df_XEx_read$Code)
                        isCodeEstimate = any(code %in% df_Xtrend_read$Code)

                        for (per in input_trend_period) {
                            df_Xtrend_code =
                                df_Xtrend_read[df_Xtrend_read$Code == code,]
                            isPerEstimate = any(per %in% df_Xtrend_code$input_period)

                            # if (!isCodeDataMod | !isCodeMod | !isCodeExtract | !isCodeEstimate | !isPerEstimate) {
                            if (!isCodeExtract | !isCodeEstimate | !isPerEstimate) {
                                missingCode = c(missingCode, code)
                            }
                        }
                    }
                    
                } else {
                    missingCode = Code
                }                
            } else {
                missingCode = Code
            }


            if (!is.null(missingCode)) {
                df_data_missing = df_data[df_data$Code %in% missingCode,]
                df_meta_missing = df_meta[df_meta$Code %in% missingCode,]
                
                res = get_Xtrend(var,
                                 df_data_missing,# df_meta_missing,
                                 period=trend_period,
                                 df_flag=df_flag,
                                 NApct_lim=NApct_lim,
                                 NAyear_lim=NAyear_lim,
                                 day_to_roll=day_to_roll,
                                 functM=functM,
                                 functM_args=functM_args,
                                 isDateM=isDateM,
                                 samplePeriodM=samplePeriodM,
                                 functY=functY,
                                 functY_args=functY_args,
                                 isDateY=isDateY,
                                 samplePeriodY=samplePeriodY,
                                 functYT_ext=functYT_ext,
                                 functYT_ext_args=functYT_ext_args,
                                 isDateYT_ext=isDateYT_ext,
                                 functYT_sum=functYT_sum,
                                 functYT_sum_args=functYT_sum_args)

                df_Xdata = res$data
                df_Xmod = res$mod
                res_Xanalyse = res$analyse
                # Gets the extracted data for the variable
                df_XEx = res_Xanalyse$extract
                # Gets the trend results for the variable
                df_Xtrend = res_Xanalyse$estimate

                if (!all(Code %in% missingCode)) {
                    # df_Xdata = rbind(df_Xdata_read, df_Xdata)
                    # df_Xmod = rbind(df_Xmod_read, df_Xmod)
                    df_Xdata = 'analyse read'
                    df_Xmod = 'analyse read'
                    df_XEx = rbind(df_XEx_read, df_XEx)
                    df_Xtrend = rbind(df_Xtrend_read, df_Xtrend)
                    res_Xanalyse = list(extract=df_XEx, estimate=df_Xtrend)
                }
                
            } else {
                # df_Xdata = df_Xdata_read
                # df_Xmod = df_Xmod_read
                df_Xdata = 'analyse read'
                df_Xmod = 'analyse read'
                res_Xanalyse = res_Xanalyse_read
                df_XEx = df_XEx_read
                df_Xtrend = df_Xtrend_read
            }

            if ('modified_data' %in% to_assign_out) {
                assign(paste0('df_', var, 'data'), df_Xdata)
                assign(paste0('df_', var, 'mod'), df_Xmod)
            }
            
            if ('analyse' %in% to_assign_out) {
                assign(paste0('res_', var, 'analyse'), res_Xanalyse)
                assign(paste0('df_', var, 'Ex'), df_XEx)
                assign(paste0('df_', var, 'trend'), df_Xtrend)
            }

            if ('station_trend_plot' %in% to_do | is.null(saving)) {
                df_data_analyse = append(df_data_analyse, list(df_XEx))
                df_trend_analyse = append(df_trend_analyse, list(df_Xtrend))
            }

### 1.3. Saving ______________________________________________________
            if ('modified_data' %in% saving & !read_results) {
                # Writes modified data
                write_data(df_Xdata, df_Xmod, resdir,
                           filedir=file.path(modified_data_dir,
                                             var, monthSamplePeriod))
                
                if (fast_format) {
                    write_dataFST(df_Xdata, resdir,
                                  filedir='fst',
                                  filename=paste0('data_', var,
                                                  '_', monthSamplePeriod,
                                                  '.fst'))
                }
            }

            if ('analyse' %in% saving) {                
                # Writes trend analysis results
                write_analyse(res_Xanalyse, resdir,
                              filedir=file.path(trend_dir,
                                                var, monthSamplePeriod))
                
                if (fast_format) {
                    write_dataFST(df_XEx,
                                  resdir,
                                  filedir='fst',
                                  filename=paste0(var, 'Ex_',
                                                  monthSamplePeriod,
                                                  '.fst'))
                }
            }
        }
    }
}

if ('meta' %in% saving) {
    if (fast_format) {
        write_metaFST(df_meta, resdir,
                      filedir=file.path('fst'))
    }
}


## 2. STATION BREAK ANALYSIS _________________________________________
if ('station_break_analyse' %in% to_do) {
    DF_BREAK = list()
    # For all the variable
    for (v in var) {
        # Gets the trend results for the variable
        res_trend = get(paste('res_', v, 'trend', sep=''))
        # Performs the break analyses for some hydrological variables
        df_break = get_break(res_trend$data, df_meta, alpha=0.1)
        DF_BREAK = append(DF_BREAK, list(df_break))
    }
    names(DF_BREAK) = var
}


## 3. CLIMATE TREND ANALYSIS _________________________________________
if ('climate_trend_analyse' %in% to_do) {
### 3.1. Info about analysis _________________________________________
    var_all_climate = list(
        'PA',
        'TA',
        'ETPA'
    )
    type_all_climate = list(
        'pluviométrie',
        'température',
        'évapotranspiration'
    )
    glose_all_climate = list(
        '',
        '',
        ''
    )

### 3.2. Selection of variables ______________________________________
    var_climate = c()
    type_climate = c()
    glose_climate = c()
    for (OkVar in to_analyse_climate) {
        Ok = var_all_climate == OkVar
        var_climate = c(var_climate, var_all_climate[Ok])
        type_climate = c(type_climate, type_all_climate[Ok])
        glose_climate = c(glose_climate, glose_all_climate[Ok])
    } 
    
### 3.3. Formatting of climate dataframe _____________________________
    # For precipitation
    df_data_P = bind_cols(Date=df_climate_data$Date,
                          Value=df_climate_data$PRCP_mm,
                          code=df_climate_data$Code)
    # For temperature
    df_data_T = bind_cols(Date=df_climate_data$Date,
                          Value=df_climate_data$T_degC,
                          code=df_climate_data$Code)
    # For evapotranspiration
    df_data_ETP = bind_cols(Date=df_climate_data$Date,
                            Value=df_climate_data$PET_mm,
                            code=df_climate_data$Code)
### 3.4. Trend analyses ______________________________________________
    # TA trend
    res = get_Xtrend(df_data_P, df_climate_meta,
                      period=trend_period,
                      hydroYear='09-01',
                      alpha=alpha,
                      dayLac_lim=dayLac_lim,
                      yearNA_lim=yearNA_lim,
                      df_flag=df_flag,
                      funct=sum)
    df_PAdata = res$data
    df_PAmod = res$mod
    res_PAtrend = res$analyse
    
    # PA trend
    res = get_Xtrend(df_data_T, df_climate_meta,
                      period=trend_period,
                      hydroYear='09-01',
                      alpha=alpha,
                      dayLac_lim=dayLac_lim,
                      yearNA_lim=yearNA_lim,
                      df_flag=df_flag,
                      funct=mean,
                      na.rm=TRUE)
    df_TAdata = res$data
    df_TAmod = res$mod
    res_TAtrend = res$analyse

    # ETPA trend
    res = get_Xtrend(df_data_ETP, df_climate_meta,
                      period=trend_period,
                      hydroYear='09-01',
                      alpha=alpha,
                      dayLac_lim=dayLac_lim,
                      yearNA_lim=yearNA_lim,
                      df_flag=df_flag,
                      funct=sum)
    df_ETPAdata = res$data
    df_ETPAmod = res$mod
    res_ETPAtrend = res$analyse
}
