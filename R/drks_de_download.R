#' Mass-download registry entry historical versions from DRKS.de
#'
#' This function will download all DRKS.de registry records for the
#' TRNs specified. Rather than transcribing TRNs by hand, it is
#' recommended that you conduct a search for trials of interest using
#' the DRKS.de web front-end and download the result as a
#' comma-separated value (CSV) file. The download option labeled "CSV"
#' on DRKS.de currently produces a zipped semicolon-delimited file,
#' which must be unzipped before reading. The file can be read in to
#' memory as a data frame and the `drksId` column can be passed
#' directly to the function as the `drksids` argument.
#'
#' @param drksids A list of well-formed DRKS numbers,
#'     e.g. c("DRKS00005219", "DRKS00003170").
#'
#' @param output_filename A character string for a filename into which
#'     the dataframe will be written as a CSV,
#'     e.g. "historical_versions.csv". If no output filename is
#'     provided, the data frame of downloaded historical versions will
#'     be returned by the function as a data frame.
#'
#' @param quiet A boolean TRUE or FALSE. If TRUE, no messages will be
#'     printed during download. FALSE by default, messages printed for
#'     every version downloaded showing progress.
#'
#' @return If an output filename is specified, on successful
#'     completion, this function returns TRUE and otherwise returns
#'     FALSE. If an output filename is not specified, on successful
#'     completion, this function returns a data frame containing the
#'     historical versions of the clinical trial that have been
#'     retrieved, and in case of error returns FALSE. After
#'     unsuccessful completion, if the function is called again with
#'     the same NCT numbers and output filename, it will check the
#'     output file for errors in the download, remove them and try to
#'     download the historical versions again.
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
#' \dontrun{
#' hv <- drks_de_download("DRKS00005219")
#' }
drks_de_download <- function(drksids, output_filename=NA, quiet=FALSE) {

    ## If output_filename is not specified, write to tempfile() and
    ## return this invisibly rather than TRUE
    if (is.na (output_filename)) {
        output_filename <- tempfile()
        return_dataframe <- TRUE
    } else {
        return_dataframe <- FALSE
    }

    ## Check that all TRNs are well-formed
    if (sum(grepl("^DRKS\\d{8}$", drksids)) != length(drksids)) {
        stop("Input contains TRNs that are not well-formed")
    }

    output_cols <- "ciiDcDDiccccccccc"

    if (!file.exists(output_filename)) {

        tibble::tibble(
                    drksid = character(),
                    version_number = numeric(),
                    total_versions = numeric(),
                    version_date = date(),
                    recruitment_status = character(),
                    start_date = date(),
                    closing_date = date(),
                    enrolment = numeric(),
                    enrolment_type = character(),
                    min_age = character(),
                    max_age = character(),
                    gender = character(),
                    inclusion_criteria = character(),
                    exclusion_criteria = character(),
                    primary_outcomes = character(),
                    secondary_outcomes = character(),
                    contacts = character()
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
                   as.character(.data$recruitment_status) == "Error" |
                     is.na(.data$recruitment_status)
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

            ## Repeat attempts to download a version up to 10 times in
            ## case of error
            versiondata <- NA
            version_retry <- 0

            while (
                (is.na(versiondata[1]) |
                versiondata[1] == "Error") &
                version_retry < 10
            ) {

                if (version_retry > 0 & ! quiet) {
                    message("Trying again ...")
                }

                if (versionno == length(versions)) {
                    versiondata <- drks_de_version(drksid, 0)
                } else {
                    versiondata <- drks_de_version(drksid, versionno)
                }

                version_retry <- version_retry + 1
                
            }

            if (version_retry > 1 & ! quiet) {
                message("Recovered from error successfully")
            }

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
                       versiondata$rstatus,
                       versiondata$startdate,
                       versiondata$closingdate,
                       versiondata$enrolno,
                       versiondata$enroltype,
                       versiondata$min_age,
                       versiondata$max_age,
                       versiondata$gender,
                       versiondata$inclusion_criteria,
                       versiondata$exclusion_criteria,
                       versiondata$primaryoutcomes,
                       versiondata$secondaryoutcomes,
                       versiondata$contacts
                   ) %>%
                readr::write_csv(
                           file = output_filename, append = TRUE
                       )

            if (length(versions) > 2 & ! quiet) {
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

        if (! quiet) {
            
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

    }

    ## Check for errors and incompletely downloaded sets of versions
    check <- readr::read_csv(
        output_filename,
        col_types = output_cols
    )

    error_trns <- check %>%
        dplyr::filter(
                   as.character(.data$version_date) == "Error" |
                   as.character(.data$recruitment_status) == "Error" |
                   is.na(.data$recruitment_status)
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

        if (return_dataframe) {
            readr::read_csv(output_filename) %>%
                return()
        } else {
            return(TRUE)
        }
        
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
