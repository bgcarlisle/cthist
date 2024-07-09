#' Mass-download registry entry historical versions from
#' ClinicalTrials.gov
#'
#' This function will download all ClinicalTrials.gov registry records
#' for the NCT numbers specified. Rather than transcribing NCT numbers
#' by hand, it is recommended that you conduct a search for trials of
#' interest using the ClinicalTrials.gov web front-end and download
#' the result as a comma-separated value (CSV) file. The CSV can be
#' read in to memory as a data frame and the `NCT Number` column can
#' be passed directly to the function as the `nctids` argument.
#'
#' @param nctids A list of well-formed NCT numbers,
#'     e.g. c("NCT00942747", "NCT03281616").
#'
#' @param output_filename A character string for a filename into which
#'     the data frame will be written as a CSV,
#'     e.g. "historical_versions.csv". If no output filename is
#'     provided, the data frame of downloaded historical versions will
#'     be returned by the function as a data frame.
#'
#' @param quiet A boolean TRUE or FALSE. If TRUE, no messages will be
#'     printed during download. FALSE by default, messages printed for
#'     every version downloaded showing progress.
#'
#' @param earliest A boolean TRUE or FALSE. If TRUE, only the earliest
#'     version of the registry entry will be downloaded, if FALSE, all
#'     versions will be downloaded. FALSE by default. Can be combined
#'     with latest.
#'
#' @param latest A boolean TRUE or FALSE. If TRUE, only the latest
#'     version of the registry entry will be downloaded, if FALSE, all
#'     versions will be downloaded. FALSE by default. Can be combined
#'     with earliest.
#'
#' @return If an output filename is specified, on successful
#'     completion, this function returns TRUE and otherwise returns
#'     FALSE. If an output filename is not specified, on successful
#'     completion, this function returns a data frame containing the
#'     historical versions of the clinical trial that have been
#'     retrieved, and in case of error returns FALSE. After
#'     unsuccessful completion with an output filename specified, if
#'     the function is called again with the same NCT numbers and
#'     output filename, the function will check the output file for
#'     errors or incompletely downloaded registry entries, remove them
#'     and try to download the historical versions that are still
#'     needed, while preserving the ones that have already been
#'     downloaded correctly.
#'
#' @export
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#'
#' @examples
#'
#' \donttest{
#' filename <- tempfile()
#' clinicaltrials_gov_download(c("NCT00942747",
#'     "NCT03281616"), filename)
#' }
#'
#' \donttest{
#' hv <- clinicaltrials_gov_download("NCT00942747")
#' }
clinicaltrials_gov_download <- function(
                                        nctids,
                                        output_filename=NA,
                                        quiet=FALSE,
                                        earliest=FALSE,
                                        latest=FALSE
                                        ) {
    
    ## If output_filename is not specified, write to tempfile() and
    ## return this invisibly rather than TRUE
    if (is.na (output_filename)) {
        output_filename <- tempfile()
        return_dataframe <- TRUE
    } else {
        return_dataframe <- FALSE
    }

    ## Check that all TRNs are well-formed
    if (sum(grepl("^NCT\\d{8}$", nctids)) != length(nctids)) {
        stop("Input contains TRNs that are not well-formed")
    }
        
    ## Check that the site is reachable
    if (httr::http_error("https://clinicaltrials.gov")) {
        message("Unable to connect to clinicaltrials.gov")
        return (FALSE)
    }
    
    output_cols <- "ciiDcDcDcciccccccccccccccccc"

    if (! file.exists(output_filename)) {

        tibble::tibble(
            nctid = character(),
            version_number = numeric(),
            total_versions = numeric(),
            version_date = date(),
            overall_status = character(),
            study_start_date = date(),
            study_start_date_precision = character(),
            primary_completion_date = date(),
            primary_completion_date_precision = character(),
            primary_completion_date_type = character(),
            enrolment = numeric(),
            enrolment_type = character(),
            min_age = character(),
            max_age = character(),
            sex = character(),
            accepts_healthy_volunteers = character(),
            criteria = character(),
            outcome_measures = character(),
            overall_contacts = character(),
            central_contacts = character(),
            responsible_party = character(),
            lead_sponsor = character(),
            collaborators = character(),
            locations = character(),
            whystopped = character(),
            results_posted = character(),
            references = character(),
            orgstudyid = character(),
            secondaryids = character(),
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
            dplyr::rename(dl_versions = "n")

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

        versions <- clinicaltrials_gov_dates(
            nctid,
            FALSE
        ) %>%
            dplyr::pull("date")

        versionno <- 0
        
        for (version in versions) {
            if (
                latest & version == max(versions) |
                earliest & version == versions[1] |
                ! latest & ! earliest
            ) {
                
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

                    versiondata <- clinicaltrials_gov_version(
                        nctid, versionno
                    )
                    
                    version_retry <- version_retry + 1
                    
                }

                if (version_retry > 1 & ! quiet) {
                    message("Recovered from error successfully")
                }

                tibble::tribble(
                            ~nctid,
                            ~version_number,
                            ~total_versions,
                            ~version_date,
                            ~overall_status,
                            ~study_start_date,
                            ~study_start_date_precision,
                            ~primary_completion_date,
                            ~primary_completion_date_precision,
                            ~primary_completion_date_type,
                            ~enrolment,
                            ~enrolment_type,
                            ~min_age,
                            ~max_age,
                            ~sex,
                            ~accepts_healthy_volunteers,
                            ~criteria,
                            ~outcome_measures,
                            ~overall_contacts,
                            ~central_contacts,
                            ~responsible_party,
                            ~lead_sponsor,
                            ~collaborator,
                            ~locations,
                            ~whystopped,
                            ~results_posted,
                            ~references,
                            ~orgstudyid,
                            ~secondaryids,
                            nctid,
                            versionno,
                            length(versions),
                            version,
                            versiondata$ostatus,
                            versiondata$startdate,
                            versiondata$startdate_precision,
                            versiondata$pcdate,
                            versiondata$pcdate_precision,
                            versiondata$pcdate_type,
                            versiondata$enrol,
                            versiondata$enroltype,
                            versiondata$min_age,
                            versiondata$max_age,
                            versiondata$sex,
                            versiondata$accepts_healthy_volunteers,
                            versiondata$criteria,
                            versiondata$outcomes,
                            versiondata$overall_contacts,
                            versiondata$central_contacts,
                            versiondata$responsible_party,
                            versiondata$lead_sponsor,
                            versiondata$collaborators,
                            versiondata$locations,
                            versiondata$whystopped,
                            versiondata$results_posted,
                            versiondata$references,
                            versiondata$orgstudyid,
                            versiondata$secondaryids
                        ) %>%
                    readr::write_csv(
                               file = output_filename, append = TRUE
                           )

                if (length(versions) > 2 & ! quiet) {
                    message(
                        paste0(
                            nctid, " - ", (versionno + 1), " of ",
                            length(versions)
                        )
                    )
                }

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

        if (! quiet) {
            
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
        dplyr::rename(dl_versions = "n")

    check <- check %>%
        dplyr::left_join(dl_counts, by = "nctid")

    if (! latest & ! earliest) {
        incomplete_dl_n <- sum(check$total_versions != check$dl_versions)
    } else {
        incomplete_dl_n <- sum(input$notdone)
    }
    
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
                    "it will remove any data that",
                    "has not been downloaded completely",
                    "and try to download again."
                )
            )
            return(FALSE)
        }
    }

}
