#' Download a vector of dates on which a ClinicalTrials.gov registry
#' entry was updated
#'
#' @param nctid A character string including a well-formed
#'     ClinicalTrials.gov NCT Number, e.g. "NCT00942747". (A
#'     capitalized "NCT" followed by eight numerals with no spaces or
#'     hyphens.)
#'
#' @return A vector of ISO-8601 formatted dates corresponding to the
#'     dates on which there were clinical trial history version
#'     updates.
#'
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' versions <- clinicaltrials_gov_dates("NCT00942747")
#'
clinicaltrials_gov_dates <- function(nctid) {
    out <- tryCatch({

        url <- paste0(
            "https://clinicaltrials.gov/ct2/history/",
            nctid
        )

        index <- rvest::read_html(url)

        index %>%
            rvest::html_nodes("fieldset.releases table a") %>%
            rvest::html_text() %>%
            as.Date(format = "%B %d, %Y") %>%
            format("%Y-%m-%d") %>%
            return()

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
