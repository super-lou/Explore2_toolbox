if (!require("httr")) install.packages("httr")
if (!require("jsonlite")) install.packages("jsonlite")

library(httr)
library(jsonlite)
library(dotenv)
library(dplyr)

source("tools.R")

load_dot_env()
API_TOKEN = Sys.getenv("API_TOKEN")
BASE_URL = Sys.getenv("BASE_URL")


to_do = c(
    # "search"
    # "delete"
    # "add diagnostic"
    # "add projection"
    # "publish"
)



# dataset_DOI = "doi:10.57745/ZTO7RB"
# metadata = get_dataset_metadata(BASE_URL, API_TOKEN, dataset_DOI)






# metadata = jsonlite::fromJSON("template.json",
#                               simplifyDataFrame=FALSE)

# metadata_dataverse = convert_metadata_for_dataverse(metadata)

# metadata_dataverse_json = toJSON(metadata_dataverse,
#                                  auto_unbox=TRUE,
#                                  pretty=TRUE)



stop()








library(jsonlite)

# Load your JSON data
metadata = jsonlite::fromJSON(
                         file.path("rechercheDataGouv_json_template",
                                   "rechercheDataGouv-full-metadata.json"),
                         simplifyDataFrame=FALSE)

format_full_metadata <- function (json_data) {
    if (is.list(json_data)) {
        return(lapply(json_data, function(x) {
            
            if ("multiple" %in% names(x) && x$multiple) {
                x$value <- x$value[[1]]
            }
            if ("value" %in% names(x) && is.character(x$value)) {
                x$value = ""
            }
            x[] <- clean_json(x)
            return (x)
        }))
    }
    return (json_data)
}

cleaned_metadata <- format_full_metadata(metadata)
cleaned_json_output <- toJSON(cleaned_metadata,
                              pretty=TRUE,
                              auto_unbox=TRUE)
write(cleaned_json_output, "RDG_template.json")






metadata = jsonlite::fromJSON(
                         file.path("RDG_template.json"),
                         simplifyVector=FALSE,
                         simplifyDataFrame=FALSE)



initialise_RDGf = function (environment_name="RDGf") {
    assign(environment_name, new.env(), envir=as.environment(1))
}

initialise_RDGf()
source("template.R")


TypeNames = ls(envir=RDGf)
TypeNames_Num = TypeNames[grepl("[[:digit:]]+$", TypeNames)]

TypeNames_Num_noNum = unique(gsub("[[:digit:]]+$", "", TypeNames_Num))

get_Num = function (x, All) {
    pattern = paste0("^", x, "[[:digit:]]+$")
    max(as.numeric(stringr::str_extract(All[grepl(pattern, All)], "[[:digit:]]+$")))
}

TypeNames_Num_noNum_n = sapply(TypeNames_Num_noNum,
                               get_Num,
                               All=TypeNames_Num)


replicate_typeName = function (metadata, typeName, n) {
    if (is.list(metadata)) {
        return (lapply(metadata, function(x) {

            if ("value" %in% names(x) && is.list(x$value)) {
                if (typeName %in% names(x$value)) {
                    tmp = x$value
                    tmp_all = list()
                    for (i in 1:n) {
                        for (tp in names(x$value)) {
                            tmp[[tp]]$typeName = paste0(x$value[[tp]]$typeName, i)
                        }
                        tmp_all = append(tmp_all, list(tmp))
                    }
                    x$value = tmp_all
                }
            }
            x[] = replicate_typeName(x, typeName, n)
            return (x)
        }))
    }
    return (metadata)
}

add_typeName = function (metadata, typeName, value) {
    if (is.list(metadata)) {
        return (lapply(metadata, function(x) {

            if ("typeName" %in% names(x)) {
                if (x$typeName == typeName) {
                    x$value = value
                    if (grepl("[[:digit:]]+$", x$typeName)) {
                        x$typeName = gsub("[[:digit:]]+$", "", x$typeName)
                    }
                }
            }
            x[] = add_typeName(x, typeName, value)
            return (x)
        }))
    }
    return (metadata)
}


clean_metadata_hide = function (metadata) {
    tmpAll = c("value", "fields")

    if (is.list(metadata)) {
        return (lapply(metadata, function(x) {

            for (name in names(x)) {
                if (is.list(x[[name]])) {
                    get_n = function (xx) {
                        ok = tmpAll %in% names(xx)
                        if (any(ok)) {
                            tmp = tmpAll[ok]
                            if (is.character(xx[[tmp]])) {
                                n = nchar(xx[[tmp]])
                            } else {
                                n = 888
                            }
                        } else {
                            n = 999
                        }
                        return (n)
                    }

                    ok = names(x[[name]]) %in% tmpAll
                    if (sum(ok) == 1) {
                        tmp = names(x[[name]])[ok]
                        if (!is.list(x[[name]][[tmp]])) {
                            if (nchar(x[[name]][[tmp]]) == 0) {
                                x = x[names(x) != name]
                            }
                        }
                        
                    } else {
                        n = sapply(x[[name]], get_n)
                        if (all(n == 0)) {
                            x[[name]] = ""
                        } else {
                            x[[name]] = x[[name]][n > 0]
                        }
                    }
                }
            }
            if (length(x) == 0) {
                x = c(value="")
            }
            x[] = clean_metadata_hide(x)
            return (x)
        }))
    }
    return (metadata)
}



clean_metadata = function (metadata) {
    get_condition = function (x) {
        if (is.list(x$fields)) {
            ok = any(nchar(unlist(x$fields)) == 0)
        } else {
            ok = x$fields != ""
        }
    }
    ok = any(sapply(metadata$datasetVersion$metadataBlocks,
                    get_condition))
    while (ok) {
        metadata = clean_metadata_hide(metadata)
        ok = any(sapply(metadata$datasetVersion$metadataBlocks,
                        get_condition))
    }
    return (metadata)
}


for (i in 1:length(TypeNames_Num_noNum_n)) {
    n = TypeNames_Num_noNum_n[i]
    typeName = names(TypeNames_Num_noNum_n)[i]
    if (!(paste0(typeName, n) %in% unlist(metadata))) {
        metadata = replicate_typeName(metadata, typeName, n)
    }
}

for (typeName in TypeNames) {
    value = get(typeName, envir=RDGf)
    metadata = add_typeName(metadata, typeName, value)
}



metadata_tmp = clean_metadata(metadata)

write(toJSON(metadata_tmp, pretty=TRUE, auto_unbox=TRUE),
      "RDG_template_tmp.json")

rm (list=ls(envir=RDGf), envir=RDGf)






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
