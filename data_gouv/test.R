
if (!require("httr")) install.packages("httr")
if (!require("jsonlite")) install.packages("jsonlite")

library(httr)
library(jsonlite)
library(dotenv)
library(dplyr)

# devtools::load_all(".")

source("R/api.R")
source("R/RDGf.R")

dotenv::load_dot_env()
API_TOKEN = Sys.getenv("API_TOKEN")
BASE_URL = Sys.getenv("BASE_URL")


to_do = c(
    # "create_incertitude_fiche"
    "modify_incertitude_fiche"
    # "search"
    # "delete"
    # "add diagnostic"
    # "add projection"
    # "publish"
)


# format_full_metadata()


stop()



if ("create_incertitude_fiche" %in% to_do) {

    figure_path = "/home/lheraut/Documents/INRAE/projects/Explore2_project/Explore2_toolbox/figures/incertitude"
    fiche_dir = "fiche"
    notice_file = "Explore2_Notice_fiche_incertitude_VF.pdf"

    query = "Fiches de résultats des modèles hydrologiques"
    # query = "Fiches incertitudes des modèles hydrologiques"
    
    publication_status =
        "RELEASED"
        # "DRAFT"
    type = "dataset"
    collection = "Explore2"
    n_search = 40

    datasets = search(BASE_URL, API_TOKEN,
                      query=query,
                      publication_status=publication_status,
                      type=type,
                      collection=collection,
                      n_search=n_search)
    
    Titles = unlist(lapply(datasets$items, "[[", "name"))
    OK = grepl("[:]", Titles)
    datasets$items = datasets$items[OK]
    Titles = Titles[OK]
    Letters_Regions = gsub(".*[:] ", "", Titles)
    Letters = lapply(strsplit(substring(Letters_Regions, 1, 6),
                              " et "),
                     gsub, pattern=" .*", replacement="")
    Letters_compact = unlist(lapply(Letters, paste0, collapse="/"))
    Regions = sub("[[:alpha:]][ ]", "", Letters_Regions)
    Regions = sub("^et[ ][[:alpha:]][ ]", "", Regions)
    URLs = unlist(lapply(datasets$items, "[[", "url"))
    DOIs = unlist(lapply(datasets$items, "[[", "global_id"))
    Citations = gsub("[\"]", "",
                     unlist(lapply(datasets$items, "[[", "citation")))

    # resultats
    Info_resultats =
        dplyr::tibble(letter=Letters_compact, region=Regions,
                      title=Titles, citation=Citations,
                      doi=DOIs, url=URLs)
    ASHE::write_tibble(Info_resultats,
                       "datasets_resultats.csv")
    
    content_resultats = c("<h2>Ensemble des fiches de résultats des modèles hydrologiques de surface du projet Explore2</h2>",
                          "<p>citation :</p>",
                          "<blockquote>
Héraut, Louis; Vidal, Jean-Philippe; Évin, Guillaume; Sauquet, Éric, 2024, Ensemble des fiches de résultats des modèles hydrologiques de surface du projet Explore2, <a href='https://doi.org/10.57745/DMFUXW' target='_blank'>https://doi.org/10.57745/DMFUXW</a>, Recherche Data Gouv, V2, UNF:6:MqIZKPdt8Wfvw1CICxvI0g== [fileUNF]</blockquote>",
"<p>datasets :</p>", "<ul>")
    content_resultats = c(content_resultats,
                          paste0("<li><a href='", URLs,
                                 "' target='_blank'>",
                                 Letters_Regions, "</a></li>"),
                          "</ul>")
    writeLines(content_resultats, "README_resultats.html")

    # incertitudes
    Info_incertitudes =
        dplyr::tibble(letter=Letters_compact, region=Regions,
                      title=Titles, citation=Citations,
                      doi=DOIs, url=URLs)
    ASHE::write_tibble(Info_incertitudes,
                       "datasets_incertitudes.csv")
    
    content_incertitudes = c("<h2>Ensemble des fiches de résultats des modèles hydrologiques de surface du projet Explore2</h2>",
                          "<p>citation :</p>",
                          "<blockquote>Évin, Guillaume, 2024, Ensemble des fiches incertitudes des modèles hydrologiques de surface du projet Explore2, <a href='https://doi.org/10.57745/3LP5EN' target='_blank'>https://doi.org/10.57745/3LP5EN</a>, V2, UNF:6:g1WT+TGr7so2K4gvs+IvyA== [fileUNF]</blockquote>",
"<p>datasets :</p>", "<ul>")
    content_incertitudes = c(content_incertitudes,
                          paste0("<li><a href='", URLs,
                                 "' target='_blank'>",
                                 Letters_Regions, "</a></li>"),
                          "</ul>")
    writeLines(content_incertitudes, "README_incertitudes.html")


    for (i in 1:length(Letters_Regions)) {
        letter_region = Letters_Regions[i]
        initialise_RDGf()
        source("template_fiche_incertitude.R")
        RDGf$title = gsub("XXX", letter_region, RDGf$title)
        RDGf$dsDescriptionValue = gsub("XXX", letter_region,
                                       RDGf$dsDescriptionValue)
        res = generate_RDGf(dev=TRUE)
        dataset_DOI = create_dataset_in_dataverse(BASE_URL,
                                                  API_TOKEN,
                                                  "Explore2",
                                                  res$path)

        letters = Letters[[i]]
        pattern = paste0("(", paste0("^", letters, collapse=")|("), ")")
        
        Paths = list.files(file.path(figure_path, fiche_dir),
                           pattern=pattern, full.names=TRUE)
        Paths = c(file.path(figure_path, notice_file), Paths)
        add_dataset_files(BASE_URL, API_TOKEN, dataset_DOI,
                          paths=Paths)
    }
}

if ("modify_incertitude_fiche" %in% to_do) {

    figure_path = "/home/lheraut/Documents/INRAE/projects/Explore2_project/Explore2_toolbox/figures/incertitude"
    fiche_dir = "fiche"
    notice_file = "Explore2_Notice_fiche_incertitude_VF.pdf"

    query = "Fiches incertitudes des modèles hydrologiques"

    publication_status =
        # "RELEASED"
        "DRAFT"
    type = "dataset"
    collection = "Explore2"
    n_search = 40

    # datasets = search(BASE_URL, API_TOKEN,
                      # query=query,
                      # publication_status=publication_status,
                      # type=type,
                      # collection=collection,
                      # n_search=n_search)
    # datasets_DOI = get_doi_from_datasets(datasets)

    for (i in 1:length(datasets_DOI)) {
        initialise_RDGf()
        source("template_fiche_incertitude.R")

        title = names(datasets_DOI)[i]
        region = gsub(".*[:] ", "", title)
        RDGf$title = title
        RDGf$dsDescriptionValue = gsub("XXX", region,
                                       RDGf$dsDescriptionValue)
        res = generate_RDGf(dev=TRUE)
        
        modify_dataset_metadata(BASE_URL,
                                API_TOKEN,
                                datasets_DOI[i],
                                res$path) 
    }
}


if ("search" %in% to_do) {
    query = '"Fiches de diagnostic régional des modèles hydrologiques de surface du projet Explore2"'

    query = gsub("[ ]", "+", query)
    publication_status =
        # "RELEASED"
        "DRAFT"
    type = "dataset"
    collection = "Explore2"
    n_search = 40

    datasets = search(BASE_URL, API_TOKEN,
                      query=query,
                      publication_status=publication_status,
                      type=type,
                      collection=collection,
                      n_search=n_search)

    datasets_DOI = get_doi_from_datasets(datasets)

    # not_keep = c("A", "U", "V", "Q", "O", "L", "J")
    # not_keep = paste0(" ", not_keep, " ")
    # not_keep = gsub("[ ]", "[ ]", not_keep)
    # not_keep = paste0("(", paste0(not_keep, collapse=")|("), ")")
    # dataset_DOI =
    # dataset_DOI[!grepl(not_keep, names(dataset_DOI))]
}


if ("delete" %in% to_do) {
    for (k in 1:length(datasets_DOI)) {
        dataset_name = names(datasets_DOI)[k]
        dataset_doi = datasets_DOI[k]
        print(dataset_name)
        
        delete_dataset_files(BASE_URL, API_TOKEN, dataset_doi)
        if ("publish" %in% to_do) {
            publish_dataset(BASE_URL, API_TOKEN,
                            dataset_doi, type="major")
        }
    }
}


if ("add diagnostic" %in% to_do) {

    figure_dir = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/figures/diagnostic/Fiche_diagnostic_région"
    paths = list.files(figure_dir, recursive=TRUE, full.names=TRUE)
    paths = paths[!grepl("sommaire", paths)]

    name_paths = gsub("[/].*", "", gsub("^[/]", "", gsub(figure_dir, "", paths)))
    # name_paths = gsub("([(])|([)])", "", name_paths)
    # name_paths = gsub("é|è|ê", "e", name_paths)
    # name_paths = gsub("à", "a", name_paths)
    # name_paths = gsub("[']", "_", name_paths)
    # name_paths = gsub("ô", "o", name_paths)
    names(paths) = name_paths
    
    for (k in 1:length(datasets_DOI)) {
        dataset_name = names(datasets_DOI)[k]
        dataset_doi = datasets_DOI[k]

        add_dataset_files(BASE_URL, API_TOKEN, dataset_doi, paths=paths)
        if ("publish" %in% to_do) {
            publish_dataset(BASE_URL, API_TOKEN,
                            dataset_doi, type="major")
        }
    }
}


if ("add projection" %in% to_do) {

    figure_dir = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/figures/diagnostic/Fiche_diagnostic_région"
    figure_dirs = list.dirs(figure_dir, recursive=FALSE)
    figure_letters = substr(basename(figure_dirs), 1, 1)
    names(figure_dirs) = figure_letters
    
    for (k in 1:length(datasets_DOI)) {
        dataset_name = names(datasets_DOI)[k]
        dataset_doi = datasets_DOI[k]
        letter = gsub(".*[:][ ]", "", dataset_name)
        letter = substr(letter, 1, 1)
        dir = figure_dirs[names(figure_dirs) == letter]
        paths = list.files(dir, full.names=TRUE)
        print(letter)
        add_dataset_files(BASE_URL, API_TOKEN, dataset_doi,
                          paths=paths)
        if ("publish" %in% to_do) {
            publish_dataset(BASE_URL, API_TOKEN,
                            dataset_doi, type="major")
        }
    }
}
