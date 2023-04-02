

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
