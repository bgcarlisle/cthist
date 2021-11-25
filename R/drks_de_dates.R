#' Download a vector of dates on which a drks.de registry entry was
#' updated
#'
#' @param drksid A character string including a well-formed DRKS id,
#'     e.g. "DRKS00005219". (A capitalized "DRKS" followed by eight
#'     numerals with no spaces or hyphens.)
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
#' versions <- drks_de_dates("DRKS00005219")
#'
drks_de_dates <- function(drksid) {

    out <- tryCatch({

        url <- paste0(
            "https://drks.de/drks_web/navigate.do?",
            "navigationId=trial.history&TRIAL_ID=",
            drksid
        )

        index <- rvest::read_html(url)

        index %>%
            rvest::html_nodes("tr:not(.bgHighlight) > td:nth-child(1)") %>%
            rvest::html_text() %>%
            as.Date(format = "%m-%d-%Y") %>%
            sort() %>%
            format("%Y-%m-%d") %>%
            return()

    },
    error = function(cond) {
        message(paste("DRKS ID does not seem to exist:", drksid))
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
