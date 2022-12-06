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
# if (!exists("shapefile_list")) {
#     shapefile_list = load_shapefile(resources_path, data,
#                                     fr_shpdir, fr_shpname,
#                                     bs_shpdir, bs_shpname,
#                                     sbs_shpdir, sbs_shpname,
#                                     cbs_shpdir, cbs_shpname, cbs_coord,
#                                     rv_shpdir, rv_shpname,
#                                     river_selection=river_selection,
#                                     toleranceRel=toleranceRel)
# }

logo_path = load_logo(resources_path, logo_dir, PRlogo_file,
                      AEAGlogo_file, INRAElogo_file, FRlogo_file,
                      logo_to_show)




if ('plot_correlation_matrix' %in% to_do) {
    plot_correlation_matrix(dataEx, today_figdir)
}


if ('plot_diagnostic_datasheet' %in% to_do) {
    plot_diagnostic_datasheet(dataEx,
                              meta=meta,
                              period=period,
                              var=var_analyse,
                              event=event_analyse,
                              unit=unit_analyse,
                              samplePeriod=samplePeriod_analyse,
                              glose=glose_analyse,
                              structure=structure,
                              colorForce=TRUE,
                              exXprob=exXprob,
                              foot_note=TRUE,
                              info_height=2.8,
                              time_height=3,
                              var_ratio=3,
                              foot_height=1.25,
                              shapefile_list=shapefile_list,
                              figdir=today_figdir,
                              logo_path=logo_path,
                              zone_to_show=zone_to_show,
                              pdf_chunk=pdf_chunk)
}



### 1.2. Analyses layout _____________________________________________
if ('station_trend_plot' %in% to_do) {    
    layout_panel(to_plot=to_plot_station,
                 meta=meta,
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
