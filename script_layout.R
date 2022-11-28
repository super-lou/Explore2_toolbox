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
# R/script_layout.R
#
# Script that manages the call to the right process in order to
# realise plottings of data analyses.


## 0. SHAPEFILE LOADING ______________________________________________
# Shapefile importation in order to do it only once time
if (!exists("shapefile_list")) {
    shapefile_list = load_shapefile(resources_path, data,
                                    fr_shpdir, fr_shpname,
                                    bs_shpdir, bs_shpname,
                                    sbs_shpdir, sbs_shpname,
                                    cbs_shpdir, cbs_shpname, cbs_coord,
                                    rv_shpdir, rv_shpname,
                                    river_selection=river_selection,
                                    toleranceRel=toleranceRel)
}

logo_path = load_logo(resources_path, logo_dir, PRlogo_file,
                      AEAGlogo_file, INRAElogo_file, FRlogo_file,
                      logo_to_show)


## 1. HYDROMETRIC STATIONS LAYOUT ____________________________________
### 1.1. Flow time series for stations _______________________________
if ('station_serie_plot' %in% to_do) {
    # Square root computation
    df_sqrt = compute_sqrt(data)
    # Layout
    layout_panel(to_plot=c('datasheet'),
                 df_meta=df_meta,
                 data=list(data,
                              df_sqrt),
                 var=list('Q', 'sqrt(Q)'),
                 event=list('chronique', 'chronique'),
                 unit=list('m^{3}.s^{-1}', 'm^{3/2}.s^{-1/2}'),
                 axis_xlim=axis_xlim,
                 info_header=data,
                 shapefile_list=shapefile_list,
                 figdir=figdir,
                 logo_path=logo_path,
                 pdf_chunk=pdf_chunk)
}

### 1.2. Analyses layout _____________________________________________
if ('station_trend_plot' %in% to_do) {    
    layout_panel(to_plot=to_plot_station,
                 df_meta=df_meta,
                 data=data_analyse,
                 df_trend=df_trend_analyse,
                 var=var_analyse,
                 event=event_analyse,
                 unit=unit_analyse,
                 samplePeriod=samplePeriod_analyse,
                 glose=glose_analyse,
                 structure=structure,
                 trend_period=trend_period,
                 mean_period=mean_period,
                 colorForce=TRUE,
                 exXprob=exXprob,
                 info_header=data,
                 time_header=data,
                 foot_note=TRUE,
                 info_height=2.8,
                 time_height=3,
                 var_ratio=3,
                 foot_height=1.25,
                 shapefile_list=shapefile_list,
                 figdir=figdir,
                 filename_opt='',
                 resdir=resdir,
                 logo_path=logo_path,
                 zone_to_show=zone_to_show,
                 pdf_chunk=pdf_chunk,
                 show_colorEvent=show_colorEvent)
}


## 2. BREAK LAYOUT ___________________________________________________
if ('station_break_plot' %in% to_do) {
    # For all the variable
    for (v in var) {
        # Gets the break results for the variable
        df_break = DF_BREAK[[v]]
        
        histogram(df_break, df_meta, title=v, figdir=figdir)    
        cumulative(df_break, df_meta, title=v, dyear=8, figdir=figdir)
    }
}


## 3. CLIMATE LAYOUT _________________________________________________
if ('climate_trend_plot' %in% to_do) {
    layout_panel(
        to_plot=c('datasheet'),
        df_meta=df_climate_meta,
        data=list(
            res_PAtrend$data,
            res_TAtrend$data,
            res_ETPAtrend$data
        ),
        df_trend=list(
            res_PAtrend$a,
            res_TAtrend$a,
            res_ETPAtrend$a
        ),
        var=var_climate,
        event=event_climate,
        unit=unit_climate,
        glose=glose_climate,
        trend_period=trend_period,
        mean_period=mean_period,
        colorForce=TRUE,
        exXprob=exXprob,
        linetype_per=c('longdash', 'solid'),
        info_header='code',
        info_height=0.5,
        time_header=NULL,
        foot_note=FALSE,
        paper_size=c(21, 18),
        figdir=figdir,
        pdf_chunk=pdf_chunk)
}
