#' Download a registry entry version from ClinicalTrials.gov
#'
#' @param nctid A character string including a well-formed
#'     ClinicalTrials.gov NCT Number, e.g. "NCT00942747". (A
#'     capitalized "NCT" followed by eight numerals with no spaces or
#'     hyphens.)
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
#' version <- clinicaltrials_gov_version("NCT00942747", 1)
#'
clinicaltrials_gov_version <- function(nctid, versionno) {

    out <- tryCatch({

        url <- paste0(
            "https://clinicaltrials.gov/ct2/history/",
            nctid,
            "?V_",
            versionno
        )

        version <- rvest::read_html(url)

        ## Read the overall status

        ostatus_rows <- version %>%
            rvest::html_nodes("#StudyStatusBody tr") %>%
            rvest::html_text() %>%
            stringr::str_replace_all("\n", " ") %>%
            stringr::str_replace_all("[  ]+", " ") %>%
            trimws()

        ostatus <- NA
        for (ostatus_row in ostatus_rows) {

            ostatus_row <- ostatus_row %>%
                stringr::str_extract("Overall Status: ([A-Za-z, ]+)")

            if (! is.na(ostatus_row)) {
                ostatus <- sub(
                    "Overall Status: ([A-Za-z, ]+)",
                    "\\1",
                    ostatus_row
                )
            }
        }

        ## Read the enrolment and type

        enrol_rows <- version %>%
            rvest::html_nodes("#StudyDesignBody tr") %>%
            rvest::html_text() %>%
            stringr::str_replace_all("\n", " ") %>%
            stringr::str_replace_all("[  ]+", " ") %>%
            trimws()

        enrol <- NA
        for (enrol_row in enrol_rows) {

            enrol_row <- enrol_row %>%
                 stringr::str_extract("Enrollment: ([A-Za-z0-9 \\[\\]]+)")

            if (! is.na(enrol_row)) {
                enrol <- sub("Enrollment: ([A-Za-z0-9]+)", "\\1", enrol_row)
            }
        }

        ## Read the study start date

        startdate_rows <- version %>%
            rvest::html_nodes("#StudyStatusBody tr") %>%
            rvest::html_text() %>%
            stringr::str_replace_all("\n", " ") %>%
            stringr::str_replace_all("[  ]+", " ") %>%
            trimws()

        startdate_raw <- NA

        for (startdate_row in startdate_rows) {
            startdate_row <- startdate_row %>%
                stringr::str_extract(
                             "Study Start: ([A-Za-z0-9, ]+)"
                         )

            if (! is.na(startdate_row)) {
                startdate_raw <- sub(
                    "Study Start: ([A-Za-z0-9, ]+)",
                    "\\1",
                    startdate_row
                )
            }
        }

        startdate_full <- startdate_raw %>%
            as.Date(format = "%B %d, %Y") %>%
            format("%Y-%m-%d")

        startdate_month <- startdate_raw %>%
            paste(1) %>%
            as.Date(format = "%B %Y %d") %>%
            format("%Y-%m-%d")

        if (! is.na(startdate_full)) {
            startdate <- startdate_full
        } else {
            startdate <- startdate_month
        }

        ## Read the primary completion date

        pcdate_rows <- version %>%
            rvest::html_nodes("#StudyStatusBody tr") %>%
            rvest::html_text() %>%
            stringr::str_replace_all("\n", " ") %>%
            stringr::str_replace_all("[  ]+", " ") %>%
            trimws()

        pcdate_raw <- NA

        for (pcdate_row in pcdate_rows) {
            pcdate_row <- pcdate_row %>%
                stringr::str_extract(
                             "Primary Completion: ([A-Za-z0-9, \\[\\]]+)"
                         )

            if (! is.na(pcdate_row)) {
                pcdate_raw <- sub(
                    "Primary Completion: ([A-Za-z0-9, ]+)",
                    "\\1",
                    pcdate_row
                )
            }
        }

        pcdate_full <- pcdate_raw %>%
            stringr::str_extract("[A-Za-z0-9 ,]+") %>%
            trimws() %>%
            as.Date(format = "%B %d, %Y") %>%
            format("%Y-%m-%d")

        pcdate_month <- pcdate_raw %>%
            stringr::str_extract("[A-Za-z0-9 ,]+") %>%
            trimws() %>%
            paste(1) %>%
            as.Date(format = "%B %Y %d") %>%
            format("%Y-%m-%d")

        if (! is.na(pcdate_full)) {
            pcdate <- pcdate_full
        } else {
            pcdate <- pcdate_month
        }

        pcdatetype <- pcdate_raw %>%
            stringr::str_extract("\\[[A-Za-z]+\\]") %>%
            stringr::str_extract("[A-Za-z]+")

        ## Read the eligibility criteria

        eligibility_rows <- version %>%
            rvest::html_nodes("#EligibilityBody tr") %>%
            rvest::html_text() %>%
            stringr::str_replace_all("\n", " ") %>%
            stringr::str_replace_all("[  ]+", " ") %>%
            trimws()

        min_age <- NA
        for (elig_row in eligibility_rows) {
            elig_row <- elig_row %>%
                stringr::str_extract("Minimum Age: [0-9]+ Years")

            if (! is.na(elig_row))  {
                min_age <- sub(
                    "Minimum Age: ([0-9]+) Years",
                    "\\1",
                    elig_row
                )
            }
        }

        max_age <- NA
        for (elig_row in eligibility_rows) {
            elig_row <- elig_row %>%
                stringr::str_extract("Maximum Age: [0-9]+ Years")

            if (! is.na(elig_row))  {
                max_age <- sub(
                    "Maximum Age: ([0-9]+) Years",
                    "\\1",
                    elig_row
                )
            }
        }

        sex <- NA
        for (elig_row in eligibility_rows) {
            elig_row <- elig_row %>%
                stringr::str_extract("Sex: [A-Za-z]+")

            if (! is.na(elig_row))  {
                sex <- sub("Sex: ([A-Za-z]+)", "\\1", elig_row)
            }
        }

        gender_based <- NA
        for (elig_row in eligibility_rows) {
            elig_row <- elig_row %>%
                stringr::str_extract("Gender based: [A-Za-z]+")

            if (! is.na(elig_row))  {
                gender_based <- sub(
                    "Gender based: ([A-Za-z]+)",
                    "\\1",
                    elig_row
                )
            }
        }

        accepts_healthy_volunteers <- NA
        for (elig_row in eligibility_rows) {
            elig_row <- elig_row %>%
                stringr::str_extract(
                             "Accepts Healthy Volunteers: [A-Za-z]+"
                         )

            if (! is.na(elig_row))  {
                accepts_healthy_volunteers <- sub(
                    "Accepts Healthy Volunteers: ([A-Za-z]+)",
                    "\\1",
                    elig_row
                )
            }
        }

        eligibility_rows <- version %>%
            rvest::html_nodes("#EligibilityBody tr")

        criteria <- NA
        for (elig_row in eligibility_rows) {

            elig_row_cells <- elig_row %>% rvest::html_nodes("td")

            if (length(elig_row_cells) > 0) {

                if (
                    elig_row_cells[1] %>% rvest::html_text() ==
                    "Criteria:"
                ) {
                    criteria <- elig_row_cells[2] %>%
                        rvest::html_text2() %>%
                        paste(collapse = " ")
                }

            }

        }

        criteria <- criteria %>%
            jsonlite::toJSON()

        ## Read the outcome measures

        outcomes_link <- NA
        outcomes_link <-  version %>%
            rvest::html_node("#ProtocolOutcomeMeasuresBody a") %>%
            rvest::html_text()

        if (is.na(outcomes_link)) {

            om_rows <- version %>%
                rvest::html_nodes("#OutcomeMeasuresBody tr")

            om_data <- tibble::tribble(
                ~section, ~label, ~content
            )
            omsection <- NA
            omlabel <- NA
            omcontent <- NA
            for (om_row in om_rows) {

                om_row_cells <- om_row %>% rvest::html_nodes("td")

                if (length(om_row_cells) > 0) {

                    if (length(om_row_cells) == 2) {

                        if (om_row_cells[2] %>% rvest::html_text() == "") {
                            omsection <- om_row_cells[1] %>%
                                rvest::html_text() %>%
                                trimws()

                        } else {
                            omlabel <- om_row_cells[1] %>%
                                rvest::html_text() %>%
                                trimws()

                            omcontent <- om_row_cells[2] %>%
                                rvest::html_text2() %>%
                                trimws()

                            new_om_data <- tibble::tribble(
                                ~section, ~label, ~content,
                                omsection, omlabel, omcontent
                            )

                            om_data <- dplyr::bind_rows(om_data, new_om_data)
                        }

                    } else {

                        omlabel <- om_row_cells[1] %>%
                            rvest::html_node("p.mcp-comment-title") %>%
                            rvest::html_text()

                        omcontent <- om_row_cells[1] %>%
                            rvest::html_nodes("li") %>%
                            rvest::html_text2() %>%
                            paste(collapse = " ")

                        new_om_data <- tibble::tribble(
                            ~section, ~label, ~content,
                            omsection, omlabel, omcontent
                        )

                        om_data <- dplyr::bind_rows(om_data, new_om_data)
                    }

                }

            }

            om_data <- om_data %>%
                jsonlite::toJSON()

        } else {
            om_data <- outcomes_link
        }

        ## Read the Contacts

        cl_rows <- version %>%
            rvest::html_nodes("#ContactsLocationsBody tr")

        contacts_data <- tibble::tribble(
            ~label, ~content
        )

        cl_label <- NA
        cl_content <- NA
        contact_section <- TRUE
        for (cl_row in cl_rows) {

            cl_row_cells <- cl_row %>%
                rvest::html_nodes("td")

            if (length(cl_row_cells) > 0) {

                ## Contacts and locations are in the same table, so this
                ## switches off processing once we hit the locations rows
                if (cl_row_cells[1] %>% rvest::html_text() == "Locations:") {
                    contact_section <- FALSE
                }

                if (contact_section) {
                    ## If we're still in the contact section ...

                    if (cl_row_cells[1] %>% rvest::html_text() != "") {
                        ## First cell isn't empty

                        cl_label <- cl_row_cells[1] %>%
                            rvest::html_text2() %>%
                            trimws()

                    }

                    cl_content <- cl_row_cells[2] %>%
                        rvest::html_text2() %>%
                        trimws()

                    contacts_data <- contacts_data %>%
                        dplyr::bind_rows(
                            tibble::tribble(
                                ~label, ~content,
                                cl_label, cl_content
                            )
                        )

                }

            }

        }

        contacts_data <- contacts_data %>%
            jsonlite::toJSON()

        ## Read the sponsor/collaborators

        sc_rows <- version %>%
            rvest::html_nodes("#SponsorCollaboratorsBody tr")

        sponsor_data <- tibble::tribble(
            ~label, ~content
        )

        sc_label <- NA
        sc_content <- NA

        for (sc_row in sc_rows) {

            sc_row_cells <- sc_row %>%
                rvest::html_nodes("td")

            if (length(sc_row_cells) > 0) {

                if (sc_row_cells[1] %>% rvest::html_text() != "") {
                    ## First cell isn't empty

                    sc_label <- sc_row_cells[1] %>%
                        rvest::html_text2() %>%
                        trimws()
                }

                sc_content <- sc_row_cells[2] %>%
                    rvest::html_text2() %>%
                    trimws()

                sponsor_data <- sponsor_data %>%
                    dplyr::bind_rows(
                        tibble::tribble(
                            ~label, ~content,
                            sc_label, sc_content
                        )
                    )

            }

        }

        sponsor_data <- sponsor_data %>%
            jsonlite::toJSON()

        ## Now, put all these data points together

        data <- c(
            ostatus,
            enrol,
            startdate,
            pcdate,
            pcdatetype,
            min_age,
            max_age,
            sex,
            gender_based,
            accepts_healthy_volunteers,
            criteria,
            om_data,
            contacts_data,
            sponsor_data
        )

        return(data)

    },
    error = function(cond) {
        message(
            paste(
                "Error downloading version:",
                nctid,
                "version",
                versionno
            )
        )
        message("Here's the original error message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of error
        return("Error")
    },
    warning = function(cond) {
        message(
            paste(
                "Version caused a warning:",
                nctid,
                "version",
                versionno
            )
        )
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
