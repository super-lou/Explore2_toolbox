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
            dplyr::select(-description) %>%
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

get_doi_from_datasets = function (datasets) {
    name = sapply(datasets$items, function (x) x$name)
    DOI = sapply(datasets$items, function (x) x$global_id)
    names(DOI) = name
    return (DOI)
}


# add_dataset_files <- function(BASE_URL, API_TOKEN, dataset_DOI, paths) {
#     url <- paste0(BASE_URL, '/api/datasets/:persistentId/add?persistentId=', dataset_DOI)
    
#     for (path in paths) {
#         response <- POST(url,
#                          add_headers("X-Dataverse-key" = API_TOKEN),
#                          body=list(file = upload_file(path)),
#                          encode="multipart")
        
#         print(paste(status_code(response), content(response, "text")))
#     }
# }

add_dataset_files <- function(BASE_URL, API_TOKEN, dataset_DOI, paths) {
    url <- paste0(BASE_URL, '/api/datasets/:persistentId/add?persistentId=', dataset_DOI)
    
    for (i in 1:length(paths)) {
        path = paths[i]
        directory_label = names(paths)[i]
        # Prepare the relative path if base_path is provided
        # if (!is.null(names(paths))) {
            # directory_label <- names(path)
        # } else {
            # directory_label <- NULL
        # }
        
        # Prepare the JSON data for metadata
        json_data <- list(
            description = "",
            directoryLabel = directory_label,
            restrict = "false",
            tabIngest = "true"
        )
        
        # Send the POST request
        response <- POST(url,
                         add_headers("X-Dataverse-key" = API_TOKEN),
                         body = list(
                             file = upload_file(path),
                             jsonData = I(jsonlite::toJSON(json_data, auto_unbox=TRUE))
                         ),
                         encode = "multipart")
        
        # Print the status code and response
        print(paste(status_code(response), content(response, "text")))
    }
}



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


# stop()

to_do = c(
    # "delete"
    "add diagnostic"
    # "add projection"
    # "publish"
)

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

if ("add diagnostic" %in% to_do) {
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


figure_dir = "/home/louis/Documents/bouleau/INRAE/project/Explore2_project/Explore2_toolbox/figures/diagnostic/Fiche_diagnostic_région"
figure_dirs = list.dirs(figure_dir, recursive=FALSE)
figure_letters = substr(basename(figure_dirs), 1, 1)
names(figure_dirs) = figure_letters

if ("add projection" %in% to_do) {
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
