#' Interpret downloaded version histories to determine how long in
#' days a trial had any given overall status
#'
#' This function takes a data frame of the type produced by
#' `clinicaltrials_gov_download()` or `clinicaltrials_gov_dates()` and
#' interprets it to determine, for each clinical trial registry entry,
#' how many days were spent in each overall status (e.g. "RECRUITING",
#' "ACTIVE, NOT RECRUITING", etc.); upper and lower date bounds can
#' also be applied, to allow for returning only those dates that fall
#' within a time range of interest.
#'
#' @param historical_versions A data frame of the type produced by
#'     `clinicaltrials_gov_download()` or
#'     `clinicaltrials_gov_dates()`. Must include a row for every
#'     historical version, with the `nctid` column specifying the
#'     clinical trial registry entry, the `overall_status` column
#'     indicating the status of the trial, and the `version_date`
#'     column indicating the date on which the registry entry was
#'     updated. Other columns optional.
#'
#' @param start_date A date or character string in YYYY-MM-DD format
#'     specifying a date. If specified, only the length of time that
#'     is after the given start date will be counted.
#'
#' @param end_date A date or character string in YYYY-MM-DD format
#'     specifying a date. If specified, only the length of time that
#'     is before the given end date will be counted.
#'
#' @param carry_forward_last_status Boolean TRUE or FALSE.
#'
#' @return A data frame with two columns: `nctid`, which contains all
#'     the distinct NCT numbers from the historical_versions data
#'     frame provided, and `days`, which contains the number of
#'
#' @export
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data

overall_status_lengths <- function (
                                    historical_versions,
                                    start_date=NA,
                                    end_date=NA,
                                    carry_forward_last_status=TRUE
                                    ) {

    historical_versions <- historical_versions %>%
        dplyr::mutate("version_date" = lubridate::as_date(.data$version_date)) %>%
        dplyr::group_by(.data$nctid) %>%
        dplyr::mutate(version_enddate = dplyr::lead(.data$version_date))

    if (carry_forward_last_status) {
        historical_versions <- historical_versions %>%
            dplyr::mutate(
                version_enddate = dplyr::if_else(
                    is.na(.data$version_enddate),
                    Sys.Date(),
                    .data$version_enddate
                )
            )
    } else {
        historical_versions <- historical_versions %>%
            dplyr::filter(! is.na(.data$version_enddate))
    }
    
    ## Remove ones that came before the start date
    if (! is.na (start_date)) {
        historical_versions <- historical_versions %>%
            dplyr::mutate(
                "version_date" = dplyr::if_else (
                    lubridate::as_date(.data$version_enddate) > lubridate::as_date(start_date) &
                    lubridate::as_date(.data$version_date) < lubridate::as_date(start_date),
                    lubridate::as_date(start_date),
                    .data$version_date
                )
            ) %>%
            dplyr::filter(
                .data$version_date >= start_date
            )
    }

    ## Remove ones that came after the end date
    if (! is.na (end_date)) {
        historical_versions <- historical_versions %>%
            dplyr::mutate(
                version_enddate = dplyr::if_else (
                    lubridate::as_date(.data$version_date) < lubridate::as_date(end_date) &
                    lubridate::as_date(.data$version_enddate) >= lubridate::as_date(end_date),
                    lubridate::as_date(end_date),
                    .data$version_enddate
                )
            ) %>%
            dplyr::filter(
                .data$version_enddate <= end_date
            )                
    }

    ## Calculate days
    historical_versions <- historical_versions %>%
        dplyr::mutate("days" = .data$version_enddate - .data$version_date) %>%
        dplyr::filter(.data$days > 0)

    historical_versions %>%
        dplyr::group_by(.data$nctid, .data$overall_status) %>%
        dplyr::summarize(sum(.data$days)) %>%
        dplyr::rename(days = "sum(.data$days)") %>%
        return()
    
}
