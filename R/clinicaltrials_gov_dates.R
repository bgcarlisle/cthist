#' Download a vector of dates on which a ClinicalTrials.gov registry
#' entry was updated
#'
#' @param nctid A character string including a well-formed
#'     ClinicalTrials.gov NCT Number, e.g. "NCT00942747". (A
#'     capitalized "NCT" followed by eight numerals with no spaces or
#'     hyphens.)
#'
#' @return A character vector of ISO-8601 formatted dates
#'     corresponding to the dates on which there were clinical trial
#'     history version updates.
#'
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' \dontrun{
#' versions <- clinicaltrials_gov_dates("NCT00942747")
#' }
#'
clinicaltrials_gov_dates <- function(nctid) {
    out <- tryCatch({

        ## Check that TRN is well-formed
        if (! grepl("^NCT\\d{8}$", nctid)) {
            stop(paste0("'", nctid, "' is not a well-formed TRN"))
        }

        url <- paste0(
            "https://clinicaltrials.gov/ct2/history/",
            nctid
        )

        session <- polite::bow(url)

        index <- polite::scrape(session)

        ## Back up locale info
        lct <- Sys.getlocale("LC_TIME")
        ## Set locale so that months are parsed correctly on
        ## non-English computers
        Sys.setlocale("LC_TIME", "C")
        
        dates <- index %>%
            rvest::html_nodes("fieldset.releases table a") %>%
            rvest::html_text() %>%
            as.Date(format = "%B %d, %Y") %>%
            format("%Y-%m-%d")

        ## Restore original locale info
        Sys.setlocale("LC_TIME", lct)

        ## Check for NA values in dates
        if (sum(is.na(dates)) > 0) {
            warning("NA values returned for dates")
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
