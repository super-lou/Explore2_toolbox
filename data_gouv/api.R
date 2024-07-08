if (!require("httr")) install.packages("httr")
if (!require("jsonlite")) install.packages("jsonlite")

library(httr)
library(jsonlite)
library(dotenv)
library(dplyr)

load_dot_env()
API_TOKEN = Sys.getenv("API_TOKEN")
BASE_URL = Sys.getenv("BASE_URL")




search_metadata_blocks <- function() {
    search_url <- "https://entrepot.recherche.data.gouv.fr/api/metadatablocks/citation"
    # search_url <- modify_url(base_url, query=query_params)
    response <- GET(search_url)
    
    if (status_code(response) == 200) {
        metadata_blocks <- content(response, "parsed")
        return(metadata_blocks)
    } else {
        cat("Failed to retrieve metadata blocks.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during API request.")
    }
}



list_dataset_files = function(BASE_URL, API_TOKEN, dataset_DOI) {
    api_url = paste0(BASE_URL,
                     "/api/datasets/:persistentId/?persistentId=",
                     dataset_DOI)
    response = GET(api_url,
                   add_headers("X-Dataverse-key" = API_TOKEN))
    if (status_code(response) == 200) {
        response_content = content(response, as = "text", encoding = "UTF-8")
        dataset_info = fromJSON(response_content)
        files = dataset_info$data$latestVersion$files
        files = files %>%
            tidyr::unnest(cols=c(dataFile))
        return(files)
    } else {
        cat("Failed to retrieve dataset information.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during API request.")
    }
}


delete_dataset_files = function(BASE_URL, API_TOKEN, dataset_DOI) {
    files = list_dataset_files(BASE_URL, API_TOKEN, dataset_DOI)
    
    for (i in 1:nrow(files)) {
        file_info = files[i, ]
        file_id = file_info$id
        delete_url = paste0(BASE_URL, "/api/files/", file_id)
        response = DELETE(delete_url, add_headers("X-Dataverse-key" = API_TOKEN))
        
        if (status_code(response) == 204) {
            cat("File with ID ", file_id, " deleted successfully.\n")
        } else if (status_code(response) == 200) {
            cat("Failed to delete file with ID ", file_id, "\n")
            cat("Status code: ", status_code(response), "\n")
            cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
            cat("Deletion was not successful for file ID ", file_id, "\n")
        } else {
            cat("Failed to delete file with ID ", file_id, "\n")
            cat("Status code: ", status_code(response), "\n")
            cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
            stop("Error during file deletion.")
        }
    }
    
    cat("All files from dataset ", dataset_DOI, " have been processed.\n")
}


publish_dataset <- function(BASE_URL, API_TOKEN, dataset_DOI, type="major") {
    publish_url <- paste0(BASE_URL, "/api/datasets/:persistentId/actions/:publish?persistentId=",
                          dataset_DOI, "&type=", type)
    
    response <- POST(publish_url,
                     add_headers("X-Dataverse-key" = API_TOKEN))
    
    if (status_code(response) == 200) {
        cat("Dataset published successfully.\n")
    } else {
        cat("Failed to publish dataset.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during dataset publication.")
    }
}



# fq=publicationStatus:Published retrieves only “RELEASED” versions of datasets. The same could be done to retrieve “DRAFT” versions, fq=publicationStatus:Draft

# fq="publicationStatus:Draft"
# fq="publicationStatus:Published"
search <- function(BASE_URL, API_TOKEN,
                   query="*", publication_status="*",
                   type="*", collection="*",
                   n_search="10") {

    q = paste0(paste0("q=", query), collapse="&")
    
    if (publication_status == "DRAFT") {
        fq = "fq=publicationStatus:Draft"
    } else if (publication_status == "RELEASED") {
        fq = "fq=publicationStatus:Published"
    } else {
        fq = paste0("fq=", publication_status) 
    }
    
    type = paste0(paste0("type=", type), collapse="&")
    subtree = paste0(paste0("subtree=", collection), collapse="&")
     # &metadata_fields=citation:author
    
    search_url <- paste0(BASE_URL, "/api/search?",
                         q, "&",
                         fq, "&",
                         type, "&",
                         subtree, "&",
                         "per_page=", n_search)

    response <- GET(search_url,
                    add_headers("X-Dataverse-key" = API_TOKEN))
    
    if (status_code(response) == 200) {
        datasets <- content(response, "parsed")$data
        return(datasets)
        
    } else {
        cat("Failed to retrieve datasets from sub-dataverse.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during API request.")
    }
}

query = '"Fiches de résultats des modèles hydrologiques de surface du projet Explore2"'
query = gsub("[ ]", "+", query)
publication_status = "RELEASED"
type = "dataset"
collection = "Explore2"
n_search = 40

datasets = search(BASE_URL, API_TOKEN,
                  query=query,
                  publication_status=publication_status,
                  type=type,
                  collection=collection,
                  n_search=n_search)

get_doi_from_datasets = function (datasets) {
    name = sapply(datasets$items, function (x) x$name)
    DOI = sapply(datasets$items, function (x) x$global_id)
    names(DOI) = name
    return (DOI)
}


add_dataset_files <- function(BASE_URL, API_TOKEN, dataset_DOI, paths) {
    url <- paste0(BASE_URL, '/api/datasets/:persistentId/add?persistentId=', dataset_DOI)
    
    for (path in paths) {
        response <- POST(url,
                         add_headers("X-Dataverse-key" = API_TOKEN),
                         body=list(file = upload_file(path)),
                         encode="multipart")
        
        print(paste(status_code(response), content(response, "text")))
    }
}


dataset_DOI_list = get_doi_from_datasets(datasets)

# not_keep = c("A", "U", "V", "Q", "O", "L", "J")
# not_keep = paste0(" ", not_keep, " ")
# not_keep = gsub("[ ]", "[ ]", not_keep)
# not_keep = paste0("(", paste0(not_keep, collapse=")|("), ")")
# dataset_DOI_list =
    # dataset_DOI_list[!grepl(not_keep, names(dataset_DOI_list))]


to_do = c(
    # "delete",
    "add")

if ("delete" %in% to_do) {
    for (k in 1:length(dataset_DOI_list)) {
        dataset_name = names(dataset_DOI_list)[k]
        dataset_DOI = dataset_DOI_list[k]
        print(dataset_name)
        
        delete_dataset_files(BASE_URL, API_TOKEN, dataset_DOI)
        publish_dataset(BASE_URL, API_TOKEN, dataset_DOI, type="major")
    }
}



figure_dir = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/figures/projection/fiche"
figure_dirs = list.dirs(figure_dir, recursive=FALSE)
figure_letters = substr(basename(figure_dirs), 1, 1)
names(figure_dirs) = figure_letters


if ("add" %in% to_do) {
    for (k in 1:length(dataset_DOI_list)) {
        dataset_name = names(dataset_DOI_list)[k]
        dataset_DOI = dataset_DOI_list[k]
        letter = gsub(".*[:][ ]", "", dataset_name)
        letter = substr(letter, 1, 1)
        dir = figure_dirs[names(figure_dirs) == letter]
        paths = list.files(dir, full.names=TRUE)
        print(letter)
        
        add_dataset_files(BASE_URL, API_TOKEN, dataset_DOI, paths)
        publish_dataset(BASE_URL, API_TOKEN, dataset_DOI, type="major")
    }   
}
