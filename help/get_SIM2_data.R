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
# along with ash R toolbox.
# If not, see <https://www.gnu.org/licenses/>.


data_dir = "/home/louis/Documents/bouleau/INRAE/data/Explore2/projection/SIM2"
URL = "https://climatedata.umr-cnrm.fr/public/dcsc/projects/DRIAS/EXPLORE2-2021_SIM2/"
overwrite = FALSE


library(rvest)

get_links = function (url) {
    links = head(html_attr(html_nodes(read_html(url), "a"), "href"))
    return (links)
}

L1 = get_links(URL)

for (l1 in L1[-1]) {
    url = file.path(URL, l1)
    L2 = get_links(url)

    for (l2 in L2[-1]) {
        url = file.path(URL, l1, l2)
        L3 = get_links(url)
        
        for (l3 in L3[-1]) {
            url = file.path(URL, l1, l2, l3, "day", "Debits")
            L4 = get_links(url)
            url = file.path(URL, l1, l2, l3, "day", "Debits", L4[-1])

            path = file.path(data_dir, basename(url))
            
            if (!file.exists(path) | overwrite) {
                download.file(url, path)
            }
        }
    }
}
