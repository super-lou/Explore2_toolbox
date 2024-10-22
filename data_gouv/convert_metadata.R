# Convert to the Dataverse metadata format

convert_metadata_for_dataverse = function (metadata_json) {
    metadata_json_dataverse <- list(
        "datasetVersion" = list(
            "metadataBlocks" = list(
                "citation" = list(
                    "fields" = list(
                        # Title
                        list(
                            "typeName" = "title",
                            "multiple" = FALSE,
                            "typeClass" = "primitive",
                            "value" = metadata_json$title
                        ),
                        # Dataset Contact
                        list(
                            "typeName" = "datasetContact",
                            "multiple" = TRUE,
                            "typeClass" = "compound",
                            "value" = list(
                                list(
                                    "datasetContactName" = list(
                                        "typeName" = "datasetContactName",
                                        "typeClass" = "primitive",
                                        "value" = metadata_json$datasetContact$datasetContactName
                                    ),
                                    "datasetContactAffiliation" = list(
                                        "typeName" = "datasetContactAffiliation",
                                        "typeClass" = "primitive",
                                        "value" = metadata_json$datasetContact$datasetContactAffiliation
                                    ),
                                    "datasetContactEmail" = list(
                                        "typeName" = "datasetContactEmail",
                                        "typeClass" = "primitive",
                                        "value" = metadata_json$datasetContact$datasetContactEmail
                                    )
                                )
                            )
                        ),
                        # Author
                        list(
                            "typeName" = "author",
                            "multiple" = TRUE,
                            "typeClass" = "compound",
                            "value" = lapply(metadata_json$author, function(author) {
                                list(
                                    "authorName" = list(
                                        "typeName" = "authorName",
                                        "typeClass" = "primitive",
                                        "value" = author$authorName
                                    ),
                                    "authorAffiliation" = list(
                                        "typeName" = "authorAffiliation",
                                        "typeClass" = "primitive",
                                        "value" = author$authorAffiliation
                                    ),
                                    "authorIdentifierScheme" = list(
                                        "typeName" = "authorIdentifierScheme",
                                        "typeClass" = "primitive",
                                        "value" = author$authorIdentifierScheme
                                    ),
                                    "authorIdentifier" = list(
                                        "typeName" = "authorIdentifier",
                                        "typeClass" = "primitive",
                                        "value" = author$authorIdentifier
                                    )
                                )
                            })
                        ),
                        # dsDescription
                        list(
                            "typeName" = "dsDescription",
                            "multiple" = TRUE,
                            "typeClass" = "compound",
                            "value" = list(
                                list(
                                    "dsDescriptionValue" = list(
                                        "typeName" = "dsDescriptionValue",
                                        "typeClass" = "primitive",
                                        "value" = metadata_json$dsDescription$dsDescriptionValue
                                    ),
                                    "dsDescriptionDate" = list(
                                        "typeName" = "dsDescriptionDate",
                                        "typeClass" = "primitive",
                                        "value" = metadata_json$dsDescription$dsDescriptionDate
                                    )
                                )
                            )
                        ),
                        # Subject
                        list(
                            "typeName" = "subject",
                            "multiple" = TRUE,
                            "typeClass" = "controlledVocabulary",
                            "value" = list(metadata_json$subject)
                        ),
                        # Keywords
                        list(
                            "typeName" = "keyword",
                            "multiple" = TRUE,
                            "typeClass" = "compound",
                            "value" = lapply(metadata_json$keyword, function(kw) {
                                keywordList <- list(
                                    "keywordValue" = list(
                                        "typeName" = "keywordValue",
                                        "typeClass" = "primitive",
                                        "value" = kw$keywordValue
                                    )
                                )
                                if (!is.null(kw$keywordVocabulary)) {
                                    keywordList$keywordVocabulary <- list(
                                        "typeName" = "keywordVocabulary",
                                        "typeClass" = "primitive",
                                        "value" = kw$keywordVocabulary
                                    )
                                    keywordList$keywordVocabularyURI <- list(
                                        "typeName" = "keywordVocabularyURI",
                                        "typeClass" = "primitive",
                                        "value" = kw$keywordVocabularyURI
                                    )
                                    keywordList$keywordTermURL <- list(
                                        "typeName" = "keywordTermURL",
                                        "typeClass" = "primitive",
                                        "value" = kw$keywordTermURL
                                    )
                                }
                                return(keywordList)
                            })
                        ),
                        # Kind of Data
                        list(
                            "typeName" = "kindOfData",
                            "multiple" = TRUE,
                            "typeClass" = "primitive",
                            "value" = list(metadata_json$kindOfData, metadata_json$kindOfDataOther)
                        )
                    )
                )
            )
        )
    )
}

