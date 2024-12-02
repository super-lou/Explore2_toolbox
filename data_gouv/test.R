
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
    Titles = Titles[grepl("Explore2", Titles)]
    Region = gsub(".*[:] ", "", Titles)

    for (region in Region) {
        initialise_RDGf()
        source("template_fiche_incertitude.R")
        RDGf$title = gsub("XXX", region, RDGf$title)
        RDGf$dsDescriptionValue = gsub("XXX", region, RDGf$dsDescriptionValue)
        res = generate_RDGf(dev=TRUE)

        letter = gsub(" .*", "",
                      unlist(strsplit(substring(region, 1, 6),
                                      " et ")))

        dataset_DOI = create_dataset_in_dataverse(BASE_URL,
                                                  API_TOKEN,
                                                  "Explore2",
                                                  res$path)

        pattern = paste0("(", paste0("^", letter, collapse=")|("), ")")
        
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
