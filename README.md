# Clinical Trial Registry History

## How to install

To install through `git`, you will need to install `devtools` first:

```{r}
install.packages("devtools")
library(devtools)
install_github("bgcarlisle/cthist")
library(cthist)
```

## ClinicalTrials.gov

Download clinical trial version dates:

```{r}
## Get all the dates when the registry entry for NCT02110043 changed
clinicaltrials_gov_version_dates("NCT02110043")
## [1] "2014-04-08" "2014-09-22" "2014-10-13" "2016-03-15" "2016-12-20"
## [6] "2017-07-04" "2017-07-26" "2021-05-20"
```
Download clinical trial registry entry version data:

```{r}
## Get the 4th version of NCT02110043
version_data <- clinicaltrials_gov_version_data("NCT02110043", 4)

## Get the 2nd item (enrolment) for that version
version_data[2]
## [1] "22 [Anticipated]"
```

Mass-download clinical trial registry entry versions for many trials:

```{r}
clinicaltrials_gov_download(c("NCT02110043", "NCT03281616"), "versions.csv")
```

## DRKS.de

Download clinical trial version dates:

```{r}
## Get all the dates when the registry entry for DRKS00005219 changed
drks_de_version_dates("DRKS00005219")
## [1] "2014-02-17" "2014-04-17"
```

Download clinical trial registry entry version data:

```{r}
## Get the 4th version of DRKS00003170
version_data <- drks_de_version_data("DRKS00003170", 4)

## Get the 4th item (enrolment) for that version
version_data[4]
## [1] "60"
```

Mass-download clinical trial registry entry versions for many trials:

```{r}
drks_de_download(c("DRKS00005219", "DRKS00003170"), "versions.csv")
```

## What data is extracted?

| Item                             | ClinicalTrials.gov | DRKS.de |
|----------------------------------|-------------------:|--------:|
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
@Manual{bgcarlisle-ClinicalTrialRegistryHistory,
  Title          = {cthist},
  Author         = {Carlisle, Benjamin Gregory},
  Organization   = {The Grey Literature},
  Address        = {Berlin, Germany},
  url            = {https://github.org/bgcarlisle/cthist},
  year           = 2020
}
```

If you used my package in your research and you found it useful, I
would take it as a kindness if you cited it.

Best,

Benjamin Gregory Carlisle PhD
