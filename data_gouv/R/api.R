

search_metadata_blocks = function() {
    search_url = "https://entrepot.recherche.data.gouv.fr/api/metadatablocks/citation"
    # search_url = modify_url(base_url, query=query_params)
    response = GET(search_url)
    
    if (status_code(response) == 200) {
        metadata_blocks = content(response, "parsed")
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
        response = DELETE(delete_url,
                          add_headers("X-Dataverse-key"=API_TOKEN))
        
        if (status_code(response) == 200) {
            print(paste0(i, ": ", file_info$id, " -> ok"))
        } else {
            print(paste0(i, ": ", file_info$id, " -> error ",
                         status_code(response), " ",
                         content(response, "text")))
        }
    }
}


publish_dataset = function(BASE_URL, API_TOKEN, dataset_DOI, type="major") {
    publish_url = paste0(BASE_URL, "/api/datasets/:persistentId/actions/:publish?persistentId=",
                         dataset_DOI, "&type=", type)
    
    response = POST(publish_url,
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



# status “RELEASED” or “DRAFT”
search = function(BASE_URL, API_TOKEN,
                  query="*", publication_status="*",
                  type="*", collection="",
                  n_search="10") {

    query = gsub("[ ]", "+", query)
    q = paste0(paste0("q=\"", query, "\""), collapse="&")
    
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
    
    search_url = paste0(BASE_URL, "/api/search?",
                        q, "&",
                        fq, "&",
                        type, "&",
                        subtree, "&",
                        "per_page=", n_search)

    response = GET(search_url,
                   add_headers("X-Dataverse-key" = API_TOKEN))
    
    if (status_code(response) == 200) {
        datasets = content(response, "parsed")$data
        return(datasets)
        
    } else {
        cat("Failed to retrieve datasets from sub-dataverse.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during API request.")
    }
}


# dataverse = search(BASE_URL, API_TOKEN, query="Explore2", type="dataverse")


get_doi_from_datasets = function (datasets) {
    name = sapply(datasets$items, function (x) x$name)
    DOI = sapply(datasets$items, function (x) x$global_id)
    names(DOI) = name
    return (DOI)
}


add_dataset_files = function(BASE_URL, API_TOKEN, dataset_DOI, paths) {
    url = paste0(BASE_URL,
                 '/api/datasets/:persistentId/add?persistentId=',
                 dataset_DOI)
    not_added = c()
    
    for (i in 1:length(paths)) {
        path = paths[i]
        directory_label = names(paths)[i]
        if (is.null(directory_label)) {
            directory_label = ""
        }
        json_data = list(
            description = "",
            directoryLabel = directory_label,
            restrict = "false",
            tabIngest = "true"
        )
        response = POST(url,
                        add_headers("X-Dataverse-key" = API_TOKEN),
                        body = list(
                            file = upload_file(path),
                            jsonData = I(jsonlite::toJSON(json_data, auto_unbox=TRUE))
                        ),
                        encode = "multipart")

        if (status_code(response) == 200) {
            print(paste0(i, ": ", path, " -> ok"))
        } else {
            not_added = c(not_added, path)
            names(not_added)[length(not_added)] = i 
            print(paste0(i, ": ", path, " -> error ",
                         status_code(response), " ",
                         content(response, "text")))
        }
    }
    
    return (not_added)
}





get_dataset_metadata = function(BASE_URL, API_TOKEN, dataset_DOI) {
    # Construct the API URL using the provided DOI
    api_url = paste0(BASE_URL, "/api/datasets/:persistentId/?persistentId=", dataset_DOI)
    
    # Send GET request to the API
    response = GET(api_url, add_headers("X-Dataverse-key" = API_TOKEN))
    
    # Check if the request was successful
    if (status_code(response) == 200) {
        # Parse the content of the response
        response_content = content(response, as = "text", encoding = "UTF-8")
        dataset_info = fromJSON(response_content)
        # Return the dataset metadata
        return(dataset_info$data)
    } else {
        # Handle errors
        cat("Failed to retrieve dataset metadata.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during metadata retrieval.")
    }
}




create_dataset_in_dataverse <- function(BASE_URL, API_TOKEN,
                                        dataverse_name = "root",
                                        metadata_path) {
    # Read the metadata JSON file
    metadata_json = fromJSON(metadata_path,
                             simplifyDataFrame=FALSE,
                             simplifyVector=FALSE)

    # Construct the URL for dataset creation
    create_url = paste0(BASE_URL, "/api/dataverses/",
                        dataverse_name, "/datasets")

    # Make the POST request to create the dataset
    response = POST(create_url,
                    add_headers("X-Dataverse-key" = API_TOKEN),
                    body = metadata_json,
                    encode = "json") 

    # Check the response status
    if (status_code(response) == 201) {
        cat("Dataset created successfully.\n")
        dataset_info <- content(response, "parsed")
        DOI <- content(response, "parsed")$data$persistentId
        cat("Dataset DOI: ", DOI, "\n")
        return (DOI)

    } else {
        cat("Failed to create dataset.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during dataset creation.")
    }
}


get_dataset_metadata <- function(BASE_URL, API_TOKEN, dataset_DOI) {
    # Construct the URL
    get_url <- paste0(BASE_URL, "/api/datasets/:persistentId/versions/:latest?persistentId=", dataset_DOI)
    
    # Make the GET request
    response <- GET(get_url, add_headers("X-Dataverse-key" = API_TOKEN))
    
    if (status_code(response) == 200) {
        cat("Metadata retrieved successfully.\n")
        metadata <- content(response, "parsed")
        return(metadata$data) # Return only the data object
    } else {
        cat("Failed to retrieve metadata.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during metadata retrieval.")
    }
}



modify_dataset_metadata = function(BASE_URL, API_TOKEN, dataset_DOI,
                                    metadata_path) {

    # Read the metadata JSON file
    metadata_json = fromJSON(metadata_path,
                             simplifyDataFrame = FALSE,
                             simplifyVector = FALSE)

    # Construct the URL for adding/updating dataset metadata
    modify_url <- paste0(BASE_URL,
                         "/api/datasets/:persistentId/versions/:draft?persistentId=",
                         dataset_DOI)

    # Make the PUT request to add metadata
    response = PUT(modify_url,
                   add_headers("X-Dataverse-key" = API_TOKEN),
                   body = metadata_json$datasetVersion,
                   encode = "json")

    # Check the response status
    if (status_code(response) == 200) {
        cat("Metadata added/updated successfully.\n")
        updated_metadata <- content(response, "parsed")
        return (updated_metadata)
    } else {
        cat("Failed to add/update metadata.\n")
        cat("Status code: ", status_code(response), "\n")
        cat("Response content: ", content(response, as = "text", encoding = "UTF-8"), "\n")
        stop("Error during metadata addition.")
    }
}





# create_dataset_in_dataverse <- function(BASE_URL, API_TOKEN,
#                                         dataverse_name,
#                                         metadata_path) {
    
#     # Read the JSON file containing the dataset metadata
#     dataset_metadata <- fromJSON(metadata_path,
#                                  simplifyDataFrame=FALSE,
#                                  simplifyVector=FALSE)
    
#     # Set up the API endpoint URL
#     url <- paste0(BASE_URL, "/api/dataverses/", dataverse_name, "/datasets")
    
#     # Make the POST request to Dataverse API
#     response <- POST(
#         url = url,
#         add_headers(`X-Dataverse-key`=API_TOKEN,
#                     `Content-type`="application/json"),
#         body = toJSON(dataset_metadata, auto_unbox = TRUE),
#         encode = "json"
#     )
    
#     # Check response status and print results
#     if (status_code(response) == 200) {
#         # Successful response
#         response_content <- content(response, as = "parsed", type = "application/json")
#         print("Dataset created successfully!")
#         print(response_content)
#     } else {
#         # Error handling
#         print(paste("Failed to create dataset. HTTP Status:", status_code(response)))
#         print(content(response, as = "text"))
#     }
# }
