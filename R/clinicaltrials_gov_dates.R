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
#'
#' @examples
#'
#' \dontrun{
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
        if (! RCurl::url.exists("https://clinicaltrials.gov")) {
            message("Unable to connect to clinicaltrials.gov")
            return ("Error")
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

        if (! status_change_only) {
            ## Default setting: Download all version change dates
            dates <- index %>%
                rvest::html_nodes("fieldset.releases table a") %>%
                rvest::html_text() %>%
                as.Date(format = "%B %d, %Y") %>%
                format("%Y-%m-%d")
        } else {
            ## Download only the dates that are marked with a
            ## Recruitment Status change
            dates <- index %>%
                rvest::html_nodes("fieldset.releases table span.recruitmentStatus") %>%
                rvest::html_nodes(xpath="../..") %>%
                rvest::html_nodes("a") %>%
                rvest::html_text() %>%
                as.Date(format = "%B %d, %Y") %>%
                format("%Y-%m-%d")
        }

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
