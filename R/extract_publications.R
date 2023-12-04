#' Converts a data frame of the type provided by
#' `clinicaltrials_gov_download()` and converts it to a new data frame
#' containing the
#'
#' @param df A data frame containing the following columns: `nctid`,
#'     `version_number`, `total_versions`, `version_date`,
#'     `references`, of the type provided by
#'     `clinicaltrials_gov_download()`.
#'
#' @param types A list of types to be returned or a character string
#'     if only one type specified, e.g. "RESULT" or c("RESULT",
#'     "BACKGROUND"). Allowed types: "RESULT", "BACKGROUND",
#'     "DERIVED".
#'
#' @return A data frame with all the original columns, as well as an
#'     additional three columns: `pmid`, `type` and `citation`. The
#'     new data frame will have one row per publication.
#'
#' @export
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data

extract_publications <- function(
                                 df,
                                 types=c(
                                     "RESULT",
                                     "BACKGROUND",
                                     "DERIVED"
                                 )
                                 ) {
    out <- tryCatch({

        df %>%
            dplyr::filter(.data$references != "[]") %>%
            dplyr::filter(! is.na(.data$references)) %>%
            dplyr::select(
                "nctid",
                "version_number",
                "total_versions",
                "version_date",
                "references"
            ) %>%
            dplyr::mutate(
                rtable = purrr::map(
                                    .data$references,
                                    jsonlite::fromJSON
                                )
            ) %>%
            dplyr::mutate(
                rtable = purrr::map(
                                    .data$rtable,
                                    tibble::as_tibble
                                )
            ) %>%
            dplyr::select(! "references") %>%
            tidyr::unnest("rtable") %>%
            dplyr::filter(
                .data$type %in% types
            ) %>%
            return()
        
        
    },
    error = function(cond) {
        message("Here's the original error message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of error
        return("Error")
    },
    warning = function(cond) {
        message("Here's the original warning message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of warning
        return("Warning")
    },
    finally = {
        ## To execute regardless of success or failure
    })

    return (out)
}
