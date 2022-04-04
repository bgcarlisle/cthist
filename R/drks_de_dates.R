#' Download a vector of dates on which a drks.de registry entry was
#' updated
#'
#' @param drksid A character string including a well-formed DRKS id,
#'     e.g. "DRKS00005219". (A capitalized "DRKS" followed by eight
#'     numerals with no spaces or hyphens.)
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
#' versions <- drks_de_dates("DRKS00005219")
#' }
#'
drks_de_dates <- function(drksid) {

    out <- tryCatch({

        ## Check that TRN is well-formed
        if (! grepl("^DRKS\\d{8}$", drksid)) {
            stop(paste0("'", drksid, "' is not a well-formed TRN"))
        }

        url <- paste0(
            "https://drks.de/drks_web/navigate.do?",
            "navigationId=trial.history&TRIAL_ID=",
            drksid
        )

        session <- polite::bow(url)

        index <- polite::scrape(session)

        ## Back up locale info
        lct <- Sys.getlocale("LC_TIME")
        ## Set locale so that months are parsed correctly on
        ## non-English computers
        Sys.setlocale("LC_TIME", "C")

        dates <- index %>%
            rvest::html_nodes("tr:not(.bgHighlight) > td:nth-child(1)") %>%
            rvest::html_text() %>%
            as.Date(format = "%m-%d-%Y") %>%
            sort() %>%
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
        message(paste("Error downloading DRKS ID:", drksid))
        message("Here's the original error message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of error
        return("Error")
    },
    warning = function(cond) {
        message(paste("DRKS ID caused a warning:", drksid))
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
