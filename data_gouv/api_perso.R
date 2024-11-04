if (!require("httr")) install.packages("httr")
if (!require("jsonlite")) install.packages("jsonlite")

library(httr)
library(jsonlite)
library(dotenv)
library(dplyr)

source("tools.R")

dotenv::load_dot_env()
API_TOKEN = Sys.getenv("API_TOKEN")
BASE_URL = Sys.getenv("BASE_URL")


to_do = c(
    # "search"
    # "delete"
    # "add diagnostic"
    # "add projection"
    # "publish"
)






metadata_path = file.path("tests",
                          "RDG_metadata_template.json")

metadata_path = file.path("inst", "extdata",
                          "rechercheDataGouv-minimum-metadata.json")


create_dataset_in_dataverse(BASE_URL, API_TOKEN,
                            "explore2",
                            metadata_path)




stop()









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

    dataset_DOI_list = get_doi_from_datasets(datasets)

    # not_keep = c("A", "U", "V", "Q", "O", "L", "J")
    # not_keep = paste0(" ", not_keep, " ")
    # not_keep = gsub("[ ]", "[ ]", not_keep)
    # not_keep = paste0("(", paste0(not_keep, collapse=")|("), ")")
    # dataset_DOI_list =
    # dataset_DOI_list[!grepl(not_keep, names(dataset_DOI_list))]
}


if ("delete" %in% to_do) {
    for (k in 1:length(dataset_DOI_list)) {
        dataset_name = names(dataset_DOI_list)[k]
        dataset_DOI = dataset_DOI_list[k]
        print(dataset_name)
        
        delete_dataset_files(BASE_URL, API_TOKEN, dataset_DOI)
        if ("publish" %in% to_do) {
            publish_dataset(BASE_URL, API_TOKEN,
                            dataset_DOI, type="major")
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
    
    for (k in 1:length(dataset_DOI_list)) {
        dataset_name = names(dataset_DOI_list)[k]
        dataset_DOI = dataset_DOI_list[k]

        add_dataset_files(BASE_URL, API_TOKEN, dataset_DOI, paths=paths)
        if ("publish" %in% to_do) {
            publish_dataset(BASE_URL, API_TOKEN,
                            dataset_DOI, type="major")
        }
    }
}


if ("add projection" %in% to_do) {

    figure_dir = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/figures/diagnostic/Fiche_diagnostic_région"
    figure_dirs = list.dirs(figure_dir, recursive=FALSE)
    figure_letters = substr(basename(figure_dirs), 1, 1)
    names(figure_dirs) = figure_letters
    
    for (k in 1:length(dataset_DOI_list)) {
        dataset_name = names(dataset_DOI_list)[k]
        dataset_DOI = dataset_DOI_list[k]
        letter = gsub(".*[:][ ]", "", dataset_name)
        letter = substr(letter, 1, 1)
        dir = figure_dirs[names(figure_dirs) == letter]
        paths = list.files(dir, full.names=TRUE)
        print(letter)
        add_dataset_files(BASE_URL, API_TOKEN, dataset_DOI,
                          paths=paths)
        if ("publish" %in% to_do) {
            publish_dataset(BASE_URL, API_TOKEN,
                            dataset_DOI, type="major")
        }
    }
}
