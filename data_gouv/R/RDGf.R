



format_full_metadata_hide = function(metadata) {
    if (is.list(metadata)) {
        return(lapply(metadata, function(x) {
            if ("multiple" %in% names(x) && x$multiple) {
                x$value = x$value[1]
                # x$multiple = FALSE
            }
            if ("value" %in% names(x) && is.character(x$value)) {
                if (x$multiple) {
                    x$value = list()
                } else {
                    x$value = ""
                }
            }
            x[] = format_full_metadata_hide(x)
            return(x)
        }))
    }
    return(metadata)
}


format_full_metadata = function (file="rechercheDataGouv-full-metadata.json",
                                 dev=FALSE) {

    if (dev) {
        path = file.path("inst", "extdata", file)
    } else {
        path = system.file("extdata", file, package="RDGf")
    }
    metadata = jsonlite::fromJSON(path, simplifyDataFrame=FALSE)
    
    metadata = format_full_metadata_hide(metadata)

    if (dev) {
        full_template_path = file.path("inst", "extdata",
                                       "RDG_full_metadata_template.json")
    } else {
        full_template_path = system.file("extdata",
                                         "RDG_full_metadata_template.json",
                                         package="RDGf")
    }
    write(jsonlite::toJSON(metadata,
                           pretty=TRUE,
                           auto_unbox=TRUE),
          full_template_path)
}

    

initialise_RDGf = function (environment_name="RDGf") {
    assign(environment_name, new.env(), envir=as.environment(1))
}


replicate_typeName = function (metadata, typeName, n) {
    if (is.list(metadata)) {
        return (lapply(metadata, function(x) {

            if ("value" %in% names(x) && is.list(x$value)) {
                # if (typeName %in% names(x$value)) {
                #     tmp = x$value
                #     tmp_all = list()
                #     for (i in 1:n) {
                #         for (tp in names(x$value)) {
                #             tmp[[tp]]$typeName =
                #                 paste0(x$value[[tp]]$typeName, i)
                #         }
                #         tmp_all = append(tmp_all, list(tmp))
                #     }
                #     x$value = tmp_all
                # }
                ok = FALSE
                if (typeName %in% names(x$value)) {
                    ok = TRUE
                    tmp_save = x$value
                } else if (length(x$value) > 0 &&
                           typeName %in% names(x$value[[1]])) {
                    ok = TRUE
                    tmp_save = x$value[[1]]
                }
                if (ok) {
                    tmp = tmp_save
                    tmp_all = list()
                    for (i in 1:n) {
                        for (tp in names(tmp_save)) {
                            tmp[[tp]]$typeName =
                                paste0(tmp_save[[tp]]$typeName, i)
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
                    if (x$multiple) {
                        x$value = list(value)
                    } else {
                        x$value = value
                    }
                    if (grepl("[[:digit:]]+$", x$typeName)) {
                        x$typeName = gsub("[[:digit:]]+$", "",
                                          x$typeName)
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
            ok = x$fields == ""
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


generate_RDGf = function (out_dir=".",
                          out_file="RDG_metadata_template.json",
                          environment_name="RDGf",
                          overwrite=TRUE,
                          dev=FALSE,
                          verbose=FALSE) {

    if (dev) {
        full_template_path = file.path("inst", "extdata",
                                       "RDG_full_metadata_template.json")
    } else {
        full_template_path = system.file("extdata",
                                         "RDG_full_metadata_template.json",
                                         package="RDGf")
    }
    
    metadata = jsonlite::fromJSON(full_template_path,
                                  simplifyVector=FALSE,
                                  simplifyDataFrame=FALSE)
    
    RDGf = get(environment_name, envir=.GlobalEnv)

    TypeNames = ls(envir=RDGf)
    TypeNames_Num = TypeNames[grepl("[[:digit:]]+$", TypeNames)]

    TypeNames_Num_noNum = unique(gsub("[[:digit:]]+$", "",
                                      TypeNames_Num))

    get_Num = function (x, All) {
        pattern = paste0("^", x, "[[:digit:]]+$")
        max(as.numeric(stringr::str_extract(All[grepl(pattern, All)],
                                            "[[:digit:]]+$")))
    }

    TypeNames_Num_noNum_n = sapply(TypeNames_Num_noNum,
                                   get_Num,
                                   All=TypeNames_Num)

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

    metadata = clean_metadata(metadata)    

    out_path = file.path(out_dir, out_file)
    
    if (overwrite) {        
        if (file.exists(out_path)) {
            file.remove(out_path)
        }
    }

    rm (list=ls(envir=RDGf), envir=RDGf)

    json = jsonlite::toJSON(metadata,
                            pretty=TRUE,
                            auto_unbox=TRUE)
    write(json, out_path)

    res = list(path=out_path, json=json)
    return (res)
}
