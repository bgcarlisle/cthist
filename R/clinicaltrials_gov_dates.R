#' Download a vector of dates on which a ClinicalTrials.gov registry
#' entry was updated
#'
#' @param nctid A character string including a well-formed
#'     ClinicalTrials.gov NCT Number, e.g. "NCT00942747". (A
#'     capitalized "NCT" followed by eight numerals with no spaces or
#'     hyphens.)
#'
#' @param status_change_only If TRUE, returns only the dates marked
#'     with a Recruitment Status change, default FALSE.
#'
#' @return A character vector of ISO-8601 formatted dates
#'     corresponding to the dates on which there were clinical trial
#'     history version updates.
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
                                     nctid,
                                     status_change_only=FALSE
                                     ) {
    out <- tryCatch({

        ## Check that TRN is well-formed
        assertthat::assert_that(
                        is.character(nctid),
                        grepl(
                            "^NCT\\d{8}$",
                            nctid
                        )
                    )

        ## Check that `status_change_only` is logical
        assertthat::assert_that(is.logical(status_change_only))
   
        ## Check that the site is reachable
        if (httr::http_error("https://clinicaltrials.gov/")) {
            message("Unable to connect to clinicaltrials.gov")
            return ("Error")
        }

        url <- paste0(
            "https://clinicaltrials.gov/api/int/studies/",
            nctid,
            "?history=true"
        )

        index <- jsonlite::read_json(url, simplifyVector=TRUE)

        dates <- index$history$changes %>%
            tibble::tibble() %>%
            dplyr::select(! "moduleLabels")

        if (status_change_only) {
            ## Download only the dates that are marked with a
            ## Recruitment Status change
            status_runs <- rle(dates$status)

            dates <- dates %>%
                dplyr::mutate(
                    status_run = rep(
                        seq_along(status_runs$lengths),
                        status_runs$lengths
                    )
                ) %>%
                dplyr::group_by("status_run") %>%
                dplyr::slice_head() %>%
                dplyr::ungroup() %>%
                dplyr::select(! "status_run")
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
