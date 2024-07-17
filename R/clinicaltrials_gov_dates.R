#' Download a table of dates on which a ClinicalTrials.gov registry
#' entry was updated
#'
#' @param nctids A list of well-formed NCT numbers,
#'     e.g. c("NCT00942747", "NCT03281616"). (A capitalized "NCT"
#'     followed by eight numerals with no spaces or hyphens.)
#'
#' @param status_change_only If TRUE, returns only the dates marked
#'     with a Recruitment Status change, default FALSE.
#'
#' @param quiet A boolean TRUE or FALSE. If TRUE, no messages will be
#'     printed during download. TRUE by default, messages printed for
#'     every registry entry downloaded showing progress.
#'
#' @return A table with three columns: the version number (starting
#'     from 0), the ISO-8601 formatted date on which there were
#'     clinical trial history version updates, and the trial's overall
#'     status on that date.
#'
#' @export
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' @examples
#'
#' \donttest{
#' versions <- clinicaltrials_gov_dates("NCT00942747")
#' }
#'
clinicaltrials_gov_dates <- function(
                                     nctids,
                                     status_change_only=FALSE,
                                     quiet=TRUE
                                     ) {
    out <- tryCatch({

        
        ## Check that all TRNs are well-formed
        if (sum(grepl("^NCT\\d{8}$", nctids)) != length(nctids)) {
            stop("Input contains TRNs that are not well-formed")
        }
        
        ## Check that `status_change_only` is logical
        assertthat::assert_that(is.logical(status_change_only))
   
        ## Check that the site is reachable
        if (httr::http_error("https://clinicaltrials.gov/")) {
            message("Unable to connect to clinicaltrials.gov")
            return ("Error")
        }

        dates <- tibble::tribble(
                             ~nctid,
                             ~version_number,
                             ~total_versions,
                             ~version_date,
                             ~overall_status
                         )

        nctno <- 0
        
        for (nctid in nctids) {

            nctno <- nctno + 1

            if (! quiet) {
                message(
                    paste0(
                        "Downloading ",
                        nctid,
                        " - ",
                        nctno,
                        " of ",
                        length(nctids),
                        " (",
                        floor(100 * nctno / length(nctids)),
                        "%)"
                    )
                )
            }

            url <- paste0(
                "https://clinicaltrials.gov/api/int/studies/",
                nctid,
                "?history=true"
            )

            index <- NA
            index <- jsonlite::read_json(url, simplifyVector=TRUE)

            newdates <- NA
            newdates <- index$history$changes %>%
                tibble::tibble() %>%
                dplyr::mutate("nctid" = nctid) %>%
                dplyr::mutate("total_versions" = dplyr::n()) %>%
                dplyr::rename("version_number" = "version") %>%
                dplyr::rename("version_date" = "date") %>%
                dplyr::rename("overall_status" = "status") %>%
                dplyr::select(
                           "nctid",
                           "version_number",
                           "total_versions",
                           "version_date",
                           "overall_status"
                       )

            if (status_change_only) {
                ## Download only the dates that are marked with a
                ## Recruitment Status change
                status_runs <- rle(newdates$overall_status)

                newdates <- newdates %>%
                    dplyr::mutate(
                               status_run = rep(
                                   seq_along(status_runs$lengths),
                                   status_runs$lengths
                               )
                           ) %>%
                    dplyr::group_by(.data$status_run) %>%
                    dplyr::slice_head() %>%
                    dplyr::ungroup() %>%
                    dplyr::select(! .data$status_run)
            }

            dates <- dates %>%
                dplyr::bind_rows(newdates)
        }

        
        return(dates)

    },
    error = function(cond) {
        message(paste("Error downloading NCT ID:", nctid))
        message("Here's the original error message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of error
        return("Error")
    },
    warning = function(cond) {
        message(paste("NCT ID caused a warning:", nctid))
        message("Here's the original warning message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of warning
        return("Warning")
    },
    finally = {
        ## To execute regardless of success or failure
    })

    return(out)

}
