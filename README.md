# cthist

This package provides functions for mass-downloading historical
clinical trial registry entry data.

## How to install

To install the stable version of `cthist` through CRAN:

```{r}
install.packages("cthist")
library(cthist)
```

If you want the most recent development version of `cthist`, you will
need to install `devtools` first, and then install via `git`:

```{r}
install.packages("devtools")
library(devtools)
install_github("bgcarlisle/cthist")
library(cthist)
```

This package provides 6 functions, 3 for ClinicalTrials.gov and 3 for
DRKS.de.

## ClinicalTrials.gov functions

Download clinical trial version dates:

```{r}
## Get all the dates when the registry entry for NCT02110043 changed

clinicaltrials_gov_dates("NCT02110043")
## [1] "2014-04-08" "2014-09-22" "2014-10-13" "2016-03-15" "2016-12-20"
## [6] "2017-07-04" "2017-07-26" "2021-05-20"
```
Download clinical trial registry entry version data:

```{r}
## Get the 4th version of NCT02110043

version_data <- clinicaltrials_gov_version("NCT02110043", 4)

## Get the 2nd item (enrolment) for that version
version_data[2]
## [1] "22 [Anticipated]"
```

Mass-download clinical trial registry entry versions for many trials:

```{r}
## Download all data for all versions of NCT02110043 and NCT03281616
## and save to versions.csv

clinicaltrials_gov_download(c("NCT02110043", "NCT03281616"), "versions.csv")
```

## DRKS.de functions

Download clinical trial version dates:

```{r}
## Get all the dates when the registry entry for DRKS00005219 changed

drks_de_dates("DRKS00005219")
## [1] "2014-02-17" "2014-04-17"
```

Download clinical trial registry entry version data:

```{r}
## Get the 4th version of DRKS00003170

version_data <- drks_de_version("DRKS00003170", 4)

## Get the 4th item (enrolment) for that version
version_data[4]
## [1] "60"
```

Mass-download clinical trial registry entry versions for many trials:

```{r}
## Download all data for all versions of DRKS00005219 and DRKS00003170
## and save to versions.csv

drks_de_download(c("DRKS00005219", "DRKS00003170"), "versions.csv")
```

## What data is extracted?

| Item                             | ClinicalTrials.gov | DRKS.de |
|:---------------------------------|-------------------:|--------:|
| Version number (1, 2, 3, etc.)   |                  ✓ |       ✓ |
| Version date (ISO-8601)          |                  ✓ |       ✓ |
| Overall status                   |                  ✓ |       ✓ |
| Start date                       |                  ✓ |       ✓ |
| Primary completion date          |                  ✓ |       ✓ |
| Enrolment                        |                  ✓ |       ✓ |
| Enrolment type                   |                  ✓ |       ✓ |
| Outcome measures                 |                  ✓ |       ✓ |
| Inclusion and exclusion criteria |                  ✓ |       ✓ |
| Contacts                         |                  ✓ |       ✓ |
| Sponsors                         |                  ✓ |       - |

## Note on use

Please note that this script is provided under AGPL v 3, and so you
may use it for any purpose, however if you modify it, you must provide
access to your modified version or you are in violation of the terms
of the license.

## Citing `cthist`

```
@Manual{bgcarlisle-cthist,
  Title          = {cthist},
  Author         = {Carlisle, Benjamin Gregory},
  Organization   = {The Grey Literature},
  Address        = {Berlin, Germany},
  url            = {https://github.org/bgcarlisle/cthist},
  year           = 2020
}
```

Please open an issue in the issue tracker above if you find a bug,
need this package to download some historical trial data that it
currently does not capture, or if you would like to collaborate on a
project that uses this tool.

If you used my package in your research and you found it useful, I
would take it as a kindness if you cited it.

Best,

Benjamin Gregory Carlisle PhD
