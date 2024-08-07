% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clinicaltrials_gov_download.R
\name{clinicaltrials_gov_download}
\alias{clinicaltrials_gov_download}
\title{Mass-download registry entry historical versions from
ClinicalTrials.gov}
\usage{
clinicaltrials_gov_download(
  nctids,
  output_filename = NA,
  quiet = FALSE,
  earliest = FALSE,
  latest = FALSE
)
}
\arguments{
\item{nctids}{A list of well-formed NCT numbers,
e.g. c("NCT00942747", "NCT03281616").}

\item{output_filename}{A character string for a filename into which
the data frame will be written as a CSV,
e.g. "historical_versions.csv". If no output filename is
provided, the data frame of downloaded historical versions will
be returned by the function as a data frame.}

\item{quiet}{A boolean TRUE or FALSE. If TRUE, no messages will be
printed during download. FALSE by default, messages printed for
every version downloaded showing progress.}

\item{earliest}{A boolean TRUE or FALSE. If TRUE, only the earliest
version of the registry entry will be downloaded, if FALSE, all
versions will be downloaded. FALSE by default. Can be combined
with latest.}

\item{latest}{A boolean TRUE or FALSE. If TRUE, only the latest
version of the registry entry will be downloaded, if FALSE, all
versions will be downloaded. FALSE by default. Can be combined
with earliest.}
}
\value{
If an output filename is specified, on successful
completion, this function returns TRUE and otherwise returns
FALSE. If an output filename is not specified, on successful
completion, this function returns a data frame containing the
historical versions of the clinical trial that have been
retrieved, and in case of error returns FALSE. After
unsuccessful completion with an output filename specified, if
the function is called again with the same NCT numbers and
output filename, the function will check the output file for
errors or incompletely downloaded registry entries, remove them
and try to download the historical versions that are still
needed, while preserving the ones that have already been
downloaded correctly.
}
\description{
This function will download all ClinicalTrials.gov registry records
for the NCT numbers specified. Rather than transcribing NCT numbers
by hand, it is recommended that you conduct a search for trials of
interest using the ClinicalTrials.gov web front-end and download
the result as a comma-separated value (CSV) file. The CSV can be
read in to memory as a data frame and the \verb{NCT Number} column can
be passed directly to the function as the \code{nctids} argument.
}
\examples{

\donttest{
filename <- tempfile()
clinicaltrials_gov_download(c("NCT00942747",
    "NCT03281616"), filename)
}

\donttest{
hv <- clinicaltrials_gov_download("NCT00942747")
}
}
