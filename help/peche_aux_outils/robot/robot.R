# Load necessary library
if(!require(rvest)) install.packages("rvest", dependencies=TRUE)
if(!require(dplyr)) install.packages("dplyr", dependencies=TRUE)
if(!require(tidyr)) install.packages("tidyr", dependencies=TRUE)


# Base URL for the root directory
DRIAS_base_url = "https://climatedata.umr-cnrm.fr/public/dcsc/projects/DRIAS/EXPLORE2-Hydro/"


crawl_url = function (base_url) {
    webpage = read_html(base_url)
    urls = webpage %>%
        rvest::html_nodes("a") %>%
        rvest::html_attr("href")
    urls = urls[-1]
    urls = paste0(base_url, urls)
    names(urls) = gsub("[/]$", "",
                       gsub(base_url, "", urls))
    return (urls)
}


## INDICATEURS _______________________________________________________
crawl_DRIAS_indicateurs = function(base_url, sleep=0.5) {

    urls = crawl_url(base_url)
    urls = urls[!grepl("(AQUI-FR)|(MONA)|(Recharge)", urls)]
    HM = gsub("EXPLORE2-2024_", "", names(urls))
    URL = dplyr::tibble(HM=HM, url=urls)
    Sys.sleep(sleep)

    URL$tmp = NA
    for (i in 1:nrow(URL)) {
        url = paste0(URL$url[i], "Indicateurs_Debit/")
        hm = URL$HM[i]
        urls_tmp = crawl_url(url)
        URL_tmp = dplyr::tibble(EXP=names(urls_tmp),
                                url=urls_tmp)
        URL$tmp[URL$HM == hm] = list(URL_tmp)
        Sys.sleep(sleep)
    }
    URL = tidyr::unnest(dplyr::select(URL, -url), tmp)

    URL$tmp = NA
    for (i in 1:nrow(URL)) {
        url = URL$url[i]
        hm = URL$HM[i]
        exp = URL$EXP[i]
        urls_tmp = crawl_url(url)
        files = names(urls_tmp)
        files_info = strsplit(files, "_")
        Indicateurs = paste0(sapply(files_info, "[", 2),
                             "_",
                             sapply(files_info, "[", 3))
        BC = sapply(files_info, "[", 5)
        URL_tmp = dplyr::tibble(indicateur=Indicateurs,
                                BC=BC,
                                url=urls_tmp)
        URL$tmp[URL$HM == hm &
                URL$EXP == exp] = list(URL_tmp)
        Sys.sleep(sleep)
    }
    URL = tidyr::unnest(dplyr::select(URL, -url), tmp)
    
    URL = dplyr::relocate(URL, EXP, .before=HM)
    URL = dplyr::relocate(URL, BC, .before=HM)

    return (URL)
}

URL_DRIAS_indicateurs = crawl_DRIAS_indicateurs(DRIAS_base_url)
write.table(URL_DRIAS_indicateurs,
            file=file.path("robot", "URL_DRIAS_indicateurs.csv"),
            quote=TRUE, sep=",",
            row.names=FALSE)


## PROJECTIONS _______________________________________________________
crawl_DRIAS_projections = function(base_url, sleep=0.5) {

    urls = crawl_url(base_url)
    urls = urls[!grepl("(AQUI-FR)|(MONA)|(Recharge)", urls)]
    HM = gsub("EXPLORE2-2024_", "", names(urls))
    URL = dplyr::tibble(HM=HM, url=urls)
    Sys.sleep(sleep)
    
    URL$tmp = NA
    for (i in 1:nrow(URL)) {
        url = URL$url[i]
        hm = URL$HM[i]
        urls_tmp = crawl_url(url)
        urls_tmp = urls_tmp[!grepl("Indicateurs",
                                   urls_tmp) &
                            !grepl("SAFRAN",
                                   urls_tmp)]
        URL_tmp = dplyr::tibble(GCM=names(urls_tmp),
                                url=urls_tmp)
        URL$tmp[URL$HM == hm] = list(URL_tmp)
        Sys.sleep(sleep)
    }
    URL = tidyr::unnest(dplyr::select(URL, -url), tmp)

    URL$tmp = NA
    for (i in 1:nrow(URL)) {
        url = URL$url[i]
        hm = URL$HM[i]
        gcm = URL$GCM[i]
        urls_tmp = crawl_url(url)
        URL_tmp = dplyr::tibble(RCM=names(urls_tmp),
                                url=urls_tmp)
        URL$tmp[URL$HM == hm &
                URL$GCM == gcm] = list(URL_tmp)
        Sys.sleep(sleep)
    }
    URL = tidyr::unnest(dplyr::select(URL, -url), tmp)

    URL$tmp = NA
    for (i in 1:nrow(URL)) {
        url = URL$url[i]
        hm = URL$HM[i]
        gcm = URL$GCM[i]
        rcm = URL$RCM[i]
        urls_tmp = crawl_url(url)
        URL_tmp = dplyr::tibble(EXP=names(urls_tmp),
                                url=urls_tmp)
        URL$tmp[URL$HM == hm &
                URL$GCM == gcm &
                URL$RCM == rcm] = list(URL_tmp)
        Sys.sleep(sleep)
    }
    URL = tidyr::unnest(dplyr::select(URL, -url), tmp)
    
    URL$tmp = NA
    for (i in 1:nrow(URL)) {
        url = URL$url[i]
        hm = URL$HM[i]
        gcm = URL$GCM[i]
        rcm = URL$RCM[i]
        exp = URL$EXP[i]
        urls_tmp = crawl_url(url)
        files = names(urls_tmp)
        files_info = strsplit(files, "_")
        Variables = sapply(files_info, "[", 1)
        BC = sapply(files_info, "[", 8)
        Ok = Variables == "debit"
        urls_tmp = urls_tmp[Ok]
        Variables = Variables[Ok]
        BC = BC[Ok]
        BC = gsub("France-", "", BC)
        URL_tmp = dplyr::tibble(variable=Variables,
                                BC=BC,
                                url=urls_tmp)
        URL$tmp[URL$HM == hm &
                URL$GCM == gcm &
                URL$RCM == rcm &
                URL$EXP == exp] = list(URL_tmp)
        Sys.sleep(sleep)
    }
    URL = tidyr::unnest(dplyr::select(URL, -url), tmp)
    
    URL = dplyr::relocate(URL, EXP, .before=HM)
    URL = dplyr::relocate(URL, BC, .after=RCM)
    URL = dplyr::relocate(URL, HM, .after=BC)

    return (URL)
}

URL_DRIAS_projections = crawl_DRIAS_projections(DRIAS_base_url)
write.table(URL_DRIAS_projections,
            file=file.path("robot", "URL_DRIAS_projections.csv"),
            quote=TRUE, sep=",",
            row.names=FALSE)
