#' @details This package provides 4 functions for mass-downloading and
#'     interpreting historical clinical trial registry entry data from
#'     ClinicalTrials.gov
#'
#'     The functions for downloading clinical trial registry data from
#'     DRKS that were provided in versions 1.0.0 to 1.3.0 have been
#'     deprecated due to the re-writing of drks.de in a manner that
#'     broke the previous implementation of web-scraping
#'
#' @details clinicaltrials_gov_dates() downloads the dates on which
#'     clinical trial registry entries were updated from
#'     ClinicalTrials.gov
#'
#' @details clinicaltrials_gov_version() downloads a specified
#'     historical version of a clinical trial registry entry from
#'     ClinicalTrials.gov
#'
#' @details clinicaltrials_gov_download() mass-downloads clinical
#'     trial registry entry versions for one or many trials on
#'     ClinicalTrials.gov
#'
#' @details extract_publications() interprets a data frame provided by
#'     clinicaltrials_gov_download() and provides a new data frame
#'     with one row per publication of the type specified indexed by
#'     ClinicalTrials.gov per clinical trial registry history version.
#'
#' @details overall_status_lengths() interprets a data frame provided
#'     by clinicaltrials_gov_download() or clinicaltrials_gov_dates()
#'     and provides a new data frame that indicates how many days were
#'     spent in each overall status.
#'
#' @references Carlisle, BG. Analysis of clinical trial registry entry
#'     histories using the novel R package cthist. medRxiv, 2022. doi:
#'     10.1101/2022.01.20.22269538
#' 
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
