#' Mass-download registry entry historical versions from DRKS.de
#'
#' @param drksids A list of well-formed DRKS numbers,
#'     e.g. c("DRKS00005219", "DRKS00003170").
#'
#' @param output_filename A character string for a filename into which
#'     the dataframe will be written as a CSV,
#'     e.g. "historical_versions.csv".
#'
#' @return On successful completion, returns TRUE, otherwise returns
#'     FALSE. If the function is called again with the same DRKS
#'     numbers and output filename, it will check the output file for
#'     errors in the download, remove them and try to download the
#'     historical versions again.
#'
#' @export
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' @examples
#'
#' \dontrun{
#' filename <- tempfile()
#' drks_de_download(c("DRKS00005219", "DRKS00003170"), filename)
#' }
#' 
drks_de_download <- function(drksids, output_filename) {

    output_cols <- "ciiccDDiccccccccc"

    if (!file.exists(output_filename)) {

        tibble::tribble(
                    ~drksid,
                    ~version_number,
                    ~total_versions,
                    ~version_date,
                    ~recruitment_status,
                    ~start_date,
                    ~closing_date,
                    ~enrolment,
                    ~enrolment_type,
                    ~min_age,
                    ~max_age,
                    ~gender,
                    ~inclusion_criteria,
                    ~exclusion_criteria,
                    ~primary_outcomes,
                    ~secondary_outcomes,
                    ~contacts
                ) %>%
            readr::write_csv(
                       file = output_filename,
                       append = TRUE,
                       col_names = TRUE
                   )

    } else {

        ## Find errors from previous attempts, if any

        check <- readr::read_csv(
                            output_filename,
                            col_types = output_cols
                        )

        error_trns <- check %>%
            dplyr::filter(
                       as.character(.data$version_date) == "Error" |
                       as.character(.data$recruitment_status) == "Error"
                   ) %>%
            dplyr::group_by(drksid) %>%
            dplyr::slice_head() %>%
            dplyr::select(drksid)

        check$remove <- check$drksid %in% error_trns$drksid

        ## Find incompletely downloaded TRN's
        dl_counts <- check %>%
            dplyr::count(drksid) %>%
            dplyr::rename(dl_versions = .data$n)

        check <- check %>%
            dplyr::left_join(dl_counts, by = "drksid")

        check %>%
            dplyr::filter(!remove) %>% ## Remove errors
            dplyr::mutate(remove = NULL) %>%
            dplyr::filter(
                       .data$total_versions == .data$dl_versions
                   ) %>% ## Remove incomplete dl's
            dplyr::mutate(dl_versions = NULL) %>%
            readr::write_csv(output_filename) ## Write to disc

    }

    ## Remove duplicate TRN's from input
    drksids <- drksids %>%
        unique()

    input <- tibble::as_tibble_col(drksids, column_name = "drksid")

    input$notdone <- ! input$drksid %in% readr::read_csv(
                          output_filename, col_types = output_cols
                       )$drksid

    while (sum(input$notdone) > 0) {

        to_dl <- input %>%
            dplyr::filter(.data$notdone)

        drksid <- to_dl$drksid[1]

        versions <- drks_de_dates(drksid)

        versionno <- 1
        for (version in versions) {

            if (versionno == length(versions)) {
                versiondata <- drks_de_version(drksid, 0)
            } else {
                versiondata <- drks_de_version(drksid, versionno)
            }

            rstatus <- versiondata[1]
            startdate <- versiondata[2]
            closingdate <- versiondata[3]
            enrolno <- versiondata[4]
            enroltype <- versiondata[5]
            min_age <- versiondata[6]
            max_age <- versiondata[7]
            gender <- versiondata[8]
            inclusion_criteria <- versiondata[9]
            exclusion_criteria <- versiondata[10]
            primaryoutcomes <- versiondata[11]
            secondaryoutcomes <- versiondata[12]
            contacts <- versiondata[13]

            tibble::tribble(
                       ~drksid,
                       ~version_number,
                       ~total_versions,
                       ~version_date,
                       ~recruitment_status,
                       ~start_date,
                       ~closing_date,
                       ~enrolment,
                       ~enrolment_type,
                       ~min_age,
                       ~max_age,
                       ~gender,
                       ~inclusion_criteria,
                       ~exclusion_criteria,
                       ~primary_outcomes,
                       ~secondary_outcomes,
                       ~contacts,
                       drksid,
                       versionno,
                       length(versions),
                       version,
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
                   ) %>%
                readr::write_csv(file = output_filename, append = TRUE)

            if (length(versions) > 10) {
                message(paste0(
                    drksid,
                    " - ",
                    versionno,
                    " of ",
                    length(versions)
                ))
            }

            versionno <- versionno + 1

        }

        input$notdone[input$drksid == drksid] <- FALSE

        denom <- input$drksid %>%
            unique() %>%
            length()

        numer <- input %>%
            dplyr::filter(! .data$notdone) %>%
            nrow()

        progress <- format(100 * numer / denom, digits = 2)

        message(
            paste0(
                Sys.time(),
                " ",
                drksid,
                " processed (",
                length(versions),
                " versions ",
                progress,
                "%)"
            )
        )

    }

    ## Check for errors and incompletely downloaded sets of versions
    check <- readr::read_csv(
        output_filename,
        col_types = output_cols
    )

    error_trns <- check %>%
        dplyr::filter(
                   as.character(.data$version_date) == "Error" |
                   as.character(.data$recruitment_status) == "Error"
               ) %>%
        dplyr::group_by(drksid) %>%
        dplyr::slice_head() %>%
        dplyr::select(drksid)

    errors_n <- nrow(error_trns)
    no_errors <- errors_n == 0

    dl_counts <- check %>%
        dplyr::count(drksid) %>%
        dplyr::rename(dl_versions = .data$n)

    check <- check %>%
        dplyr::left_join(dl_counts, by = "drksid")

    incomplete_dl_n <- sum(check$total_versions != check$dl_versions)
    all_dl_complete <- incomplete_dl_n == 0

    if (no_errors & all_dl_complete) {
        return(TRUE)
    } else {
        if (errors_n > 0) {
            message(
                paste(
                    errors_n,
                    "error(s) detected among your downloaded data.",
                    "If you re-run this script,",
                    "it will remove any data tagged as an error",
                    "and try to download again."
                )
            )
            return(FALSE)
        }
        if (incomplete_dl_n) {
            message(
                paste(
                    incomplete_dl_n,
                    "incomplete download(s) detected",
                    "among your downloaded data.",
                    "If you re-run this script,",
                    "it will remove any data",
                    "that has not been downloaded completely",
                    "and try to download again."
                )
            )
            return(FALSE)
        }
    }

}
