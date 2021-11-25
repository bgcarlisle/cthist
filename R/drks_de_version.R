#' Download a registry entry version from DRKS.de
#'
#' @param drksid A character string including a well-formed DRKS id,
#'     e.g. "DRKS00005219". (A capitalized "DRKS" followed by eight
#'     numerals with no spaces or hyphens.)
#'
#' @param versionno An integer version number, e.g. 1
#'
#' @return A list containing the overall status, enrolment, start
#'     date, primary completion date, primary completion date type,
#'     minimum age, maximum age, sex, gender-based, accepts healthy
#'     volunteers, inclusion/exclusion criteria, outcome measures,
#'     contacts and sponsors
#'
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' version <- drks_de_version("DRKS00005219", 1)
#'
drks_de_version <- function(drksid, versionno) {

    ## The DRKS site appears to internally assign version
    ## numbers that are integer multiples of 2, starting
    ## with the first version at 2. This function will
    ## multiply the supplied version number by 2.
    ##
    ## This function will return the most recent version
    ## in the case that the supplied versionno is 0.

    versionno <- versionno * 2

    out <- tryCatch({

        if (versionno != 0) {

            version_query <- list(
                TRIAL_ID = drksid,
                version1 = paste0(
                    drksid,
                    "_",
                    versionno,
                    "_en.html"
                ),
                version2 = paste0(
                    drksid,
                    "_",
                    versionno,
                    "_en.html"
                )
            )

        } else {

            version_query <- list(
                TRIAL_ID = drksid,
                version1 = paste0(
                    drksid,
                    "_en.html"
                ),
                version2 = paste0(
                    drksid,
                    "_en.html"
                )
            )

        }

        res <- httr::POST(
            "https://drks.de/drks_web/compareTrialVersions.do",
            body = version_query,
            encode = "form"

        )

        version <- rvest::read_html(res)

        closeAllConnections()

        ## Read the recruitment status

        rstatus <- NA
        rstatus <- version %>%
            rvest::html_nodes("li.state") %>%
            rvest::html_text()

        rstatus <- substr(rstatus, 23, nchar(rstatus))

        ## Read the enrolment

        enrolno <- NA
        enrolno <- version %>%
            rvest::html_nodes("li.targetSize") %>%
            rvest::html_text() %>%
            stringr::str_extract("[0-9]+")

        enroltype <- NA
        enroltype <- version %>%
            rvest::html_nodes("li.running") %>%
            rvest::html_text()

        enroltype <- substr(enroltype, 19, nchar(enroltype))

        ## Read the start date

        startdate <- NA
        startdate <- version %>%
            rvest::html_nodes("li.schedule") %>%
            rvest::html_text() %>%
            stringr::str_extract("[0-9]{4}/[0-9]{2}/[0-9]{2}") %>%
            as.Date(format = "%Y/%m/%d") %>%
            format("%Y-%m-%d")

        ## Read the closing date

        closingdate <- NA
        closingdate <- version %>%
            rvest::html_nodes("li.deadline") %>%
            rvest::html_text() %>%
            stringr::str_extract("[0-9]{4}/[0-9]{2}/[0-9]{2}") %>%
            as.Date(format = "%Y/%m/%d") %>%
            format("%Y-%m-%d")

        ## Read the outcome measures

        primaryoutcomes <- NA
        primaryoutcomes <- version %>%
            rvest::html_nodes("p.primaryEndpoint") %>%
            rvest::html_text2() %>%
            jsonlite::toJSON()

        secondaryoutcomes <- NA
        secondaryoutcomes <- version %>%
            rvest::html_nodes("p.secondaryEndpoints") %>%
            rvest::html_text2() %>%
            jsonlite::toJSON()

        ## Read the min and max ages

        min_age <- NA
        min_age <- version %>%
            rvest::html_node(".minAge") %>%
            rvest::html_text2() %>%
            gsub(pattern = "Minimum Age:", replacement = "", .data) %>%
            trimws()

        max_age <- NA
        max_age <- version %>%
            rvest::html_node(".maxAge") %>%
            rvest::html_text2() %>%
            gsub(pattern = "Maximum Age:", replacement = "", .data) %>%
            trimws()

        gender <- NA
        gender <- version %>%
            rvest::html_node(".gender") %>%
            rvest::html_text2() %>%
            gsub(pattern = "Gender:", replacement = "", .data) %>%
            trimws()

        inclusion_criteria <- NA
        inclusion_criteria <- version %>%
            rvest::html_nodes(".inclusionAdd") %>%
            rvest::html_text2() %>%
            jsonlite::toJSON()

        exclusion_criteria <- NA
        exclusion_criteria <- version %>%
            rvest::html_nodes(".exclusion") %>%
            rvest::html_text2() %>%
            jsonlite::toJSON()

        contacts <- tibble::tribble(
            ~label, ~affiliation, ~street, ~telephone, ~fax, ~email, ~url
        )

        addresses <- version %>%
            rvest::html_nodes("ul.addresses li.address")

        for (address in addresses) {

            label <- NA
            label <- address %>%
                rvest::html_nodes(xpath = "label") %>%
                rvest::html_text2()

            affiliation <- NA
            affiliation <- address %>%
                rvest::html_nodes("li.address-affiliation") %>%
                rvest::html_text2()

            address_name <- NA
            address_name <- address %>%
                rvest::html_nodes("li.address-name") %>%
                rvest::html_text2() %>%
                paste(collapse = " ") %>%
                trimws()

            telephone <- NA
            telephone <- address %>%
                rvest::html_nodes(
                           xpath = paste(
                               selectr::css_to_xpath(".address-telephone"),
                               "/node()[not(self::label)]"
                           )
                ) %>%
                rvest::html_text2() %>%
                paste(collapse = " ") %>%
                trimws()

            fax <- NA
            fax <- address %>%
                rvest::html_nodes(
                           xpath = paste(
                               selectr::css_to_xpath(".address-fax"),
                               "/node()[not(self::label)]"
                           )
                ) %>%
                rvest::html_text2() %>%
                paste(collapse = " ") %>%
                trimws()

            email <- NA
            email <- address %>%
                rvest::html_nodes(
                           xpath = paste(
                               selectr::css_to_xpath(".address-email"),
                               "/node()[not(self::label)]"
                           )
                ) %>%
                rvest::html_text2() %>%
                paste(collapse = " ") %>%
                trimws()

            url <- NA
            url <- address %>%
                rvest::html_nodes(
                           xpath = paste(
                               selectr::css_to_xpath(".address-url"),
                               "/node()[not(self::label)]"
                           )
                       ) %>%
                rvest::html_text2() %>%
                paste(collapse = " ") %>%
                trimws()

            contacts <- contacts %>%
                dplyr::bind_rows(
                           tibble::tribble(
                                       ~label,
                                       ~affiliation,
                                       ~name,
                                       ~telephone,
                                       ~fax,
                                       ~email,
                                       ~url,
                                       label,
                                       affiliation,
                                       address_name,
                                       telephone,
                                       fax,
                                       email,
                                       url

                                   )
                       )

        }

        contacts <- contacts %>%
            jsonlite::toJSON()

        ## Now, put all these data points together

        data <- c(
            rstatus,
            startdate,
            closingdate,
            enrolno,
            enroltype,
            min_age,
            max_age,
            gender,
            inclusion_criteria,
            exclusion_criteria,
            primaryoutcomes,
            secondaryoutcomes,
            contacts
        )

        return(data)

    },
    error = function(cond) {
        message(paste(
            "Version caused an error:",
            drksid, "version", versionno
        ))
        message("Here's the original error message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of error
        return("Error")
    },
    warning = function(cond) {
        message(paste(
            "Version caused a warning:",
            drksid, "version", versionno
        ))
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
