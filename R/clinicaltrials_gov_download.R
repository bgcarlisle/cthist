#' Mass-download registry entry historical versions from
#' ClinicalTrials.gov
#'
#' @param nctids A list of well-formed NCT numbers,
#'     e.g. c("NCT00942747", "NCT03281616").
#'
#' @param output_filename A character string for a filename into which
#'     the dataframe will be written as a CSV,
#'     e.g. "historical_versions.csv".
#'
#' @return On successful completion, returns TRUE, otherwise returns
#'     FALSE. If the function is called again with the same NCT
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
#' clinicaltrials_gov_download(c("NCT00942747",
#'     "NCT03281616"), filename)
#' }
#' 
clinicaltrials_gov_download <- function(nctids, output_filename) {

    output_cols <- "ciiccDDciccccccccc"

    if (!file.exists(output_filename)) {

        tibble::tribble(
            ~nctid,
            ~version_number,
            ~total_versions,
            ~version_date,
            ~overall_status,
            ~study_start_date,
            ~primary_completion_date,
            ~primary_completion_date_type,
            ~enrolment,
            ~enrolment_type,
            ~min_age,
            ~max_age,
            ~sex,
            ~gender_based,
            ~accepts_healthy_volunteers,
            ~criteria,
            ~outcome_measures,
            ~contacts,
            ~sponsor_collaborators
        ) %>%
            readr::write_csv(
                       file = output_filename,
                       append = TRUE,
                       col_names = TRUE
                   )

    } else {
        ## Find errors from previous attempts, if any (Need to specify
        ## column types because if you have a big CSV, read_csv() will
        ## only read the first few rows before assuming it knows how
        ## to read them and because the version_date column gets an
        ## "Error" value if the script screws up, this will cause
        ## problems)
        check <- readr::read_csv(
                            output_filename,
                            col_types = output_cols
                        )

        error_ncts <- check %>%
            dplyr::filter(
                       as.character(.data$version_date) == "Error" |
                       as.character(.data$overall_status) == "Error"
                   ) %>%
            dplyr::group_by(nctid) %>%
            dplyr::slice_head() %>%
            dplyr::select(nctid)

        check$remove <- check$nctid %in% error_ncts$nctid

        ## Find incompletely downloaded NCT's
        dl_counts <- check %>%
            dplyr::count(nctid) %>%
            dplyr::rename(dl_versions = .data$n)

        check <- check %>%
            dplyr::left_join(dl_counts, by = "nctid")

        check %>%
            dplyr::filter(!remove) %>% ## Remove errors
            dplyr::mutate(remove = NULL) %>%
            dplyr::filter(## Remove incomplete dl's
                       .data$total_versions == .data$dl_versions
                   ) %>%
            dplyr::mutate(dl_versions = NULL) %>%
            readr::write_csv(output_filename) ## Write to disc
    }

    ## Remove duplicate NCT's
    nctids <- nctids %>%
        unique()

    input <- tibble::as_tibble_col(nctids, column_name = "nctid")

    input$notdone <- ! input$nctid %in% readr::read_csv(
                           output_filename, col_types = output_cols
                        )$nctid

    while (sum(input$notdone) > 0) {

        to_dl <- input %>%
            dplyr::filter(.data$notdone)

        nctid <- to_dl$nctid[1]

        versions <- clinicaltrials_gov_dates(nctid)

        versionno <- 1
        for (version in versions) {

            versiondata <- clinicaltrials_gov_version(nctid, versionno)

            enrol <- versiondata[2]
            enrolno <- enrol %>%
                stringr::str_extract("^[0-9]+")
            enroltype <- enrol %>%
                stringr::str_extract("[A-Za-z]+")

            tibble::tribble(
                ~nctid,
                ~version_number,
                ~total_versions,
                ~version_date,
                ~overall_status,
                ~study_start_date,
                ~primary_completion_date,
                ~primary_completion_date_type,
                ~enrolment,
                ~enrolment_type,
                ~min_age,
                ~max_age,
                ~sex,
                ~gender_based,
                ~accepts_healthy_volunteers,
                ~criteria,
                ~outcome_measures,
                ~contacts,
                ~sponsor_collaborators,
                nctid,
                versionno,
                length(versions),
                version,
                versiondata[1], ## overall_status
                versiondata[3], ## startdate
                versiondata[4], ## pcdate
                versiondata[5], ## pcdatetype
                enrolno,
                enroltype,
                versiondata[6], ## min_age
                versiondata[7], ## max_age
                versiondata[8], ## sex
                versiondata[9], ## gender_based
                versiondata[10], ## accepts_healthy_volunteers
                versiondata[11], ## criteria
                versiondata[12], ## om_data
                versiondata[13], ## contacts_data
                versiondata[14] ## sponsor_data
            ) %>%
                readr::write_csv(file = output_filename, append = TRUE)


            if (length(versions) > 10) {
                message(
                    paste0(
                        nctid, " - ", versionno, " of ", length(versions)
                    )
                )
            }

            versionno <- versionno + 1

        }

        input$notdone[input$nctid == nctid] <- FALSE

        denom <- input$nctid %>%
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
                nctid,
                " processed (",
                length(versions),
                " versions, ",
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

    error_ncts <- check %>%
        dplyr::filter(
                   as.character(.data$version_date) == "Error"
                   | as.character(.data$overall_status) == "Error"
               ) %>%
        dplyr::group_by(nctid) %>%
        dplyr::slice_head() %>%
        dplyr::select(nctid)

    errors_n <- nrow(error_ncts)
    no_errors <- errors_n == 0

    dl_counts <- check %>%
        dplyr::count(nctid) %>%
        dplyr::rename(dl_versions = .data$n)

    check <- check %>%
        dplyr::left_join(dl_counts, by = "nctid")

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
                    "it will remove any data that",
                    "has not been downloaded completely",
                    "and try to download again."
                )
            )
            return(FALSE)
        }
    }

}
