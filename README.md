# cthist

This package provides functions for mass-downloading and interpreting
historical clinical trial registry entry data.

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

## Functions provided by `cthist`

This package provides 5 functions for downloading and interpreting
historical clinical trial data from ClinicalTrials.gov

### Download clinical trial version dates:

```{r}
## Get all the dates and status updates when the registry entry for
## NCT02110043 changed

clinicaltrials_gov_dates(c("NCT02110043", "NCT03281616"))
## A tibble: 10 × 5
##    nctid       version_number total_versions version_date overall_status       
##    <chr>                <int>          <int> <chr>        <chr>                
##  1 NCT02110043              0              8 2014-04-08   RECRUITING           
##  2 NCT02110043              1              8 2014-09-22   RECRUITING           
##  3 NCT02110043              2              8 2014-10-13   RECRUITING           
##  4 NCT02110043              3              8 2016-03-15   RECRUITING           
##  5 NCT02110043              4              8 2016-12-20   RECRUITING           
##  6 NCT02110043              5              8 2017-07-04   RECRUITING           
##  7 NCT02110043              6              8 2017-07-26   ACTIVE_NOT_RECRUITING
##  8 NCT02110043              7              8 2021-05-20   COMPLETED            
##  9 NCT03281616              0              2 2017-09-11   COMPLETED            
## 10 NCT03281616              1              2 2017-09-18   COMPLETED            

## Get all the dates when NCT02110043 had a change in overall status

clinicaltrials_gov_dates("NCT02110043", status_change_only=TRUE)
## A tibble: 3 × 5
##   nctid       version_number total_versions version_date overall_status       
##   <chr>                <int>          <int> <chr>        <chr>                
## 1 NCT02110043              0              8 2014-04-08   RECRUITING           
## 2 NCT02110043              6              8 2017-07-26   ACTIVE_NOT_RECRUITING
## 3 NCT02110043              7              8 2021-05-20   COMPLETED            
```

### Download clinical trial registry entry version data:

```{r}
## Get the 4th version of NCT02110043

version_data <- clinicaltrials_gov_version("NCT02110043", 4)

## Get the 2nd item (enrolment) for that version
version_data$enrol
## [1] 22

## Get the 3rd item (enrolment type) for that version
version_data$enroltype
## [1] "ESTIMATED"
```

### Mass-download clinical trial registry entry versions:

```{r}
## Download all data for all versions of NCT02110043 and store in
## variable `versions`

versions <- clinicaltrials_gov_download("NCT02110043")
```

Mass-download clinical trial registry entry versions for many trials
and save to disk:

```{r}
## Download all data for all versions of NCT02110043 and NCT03281616
## and save to versions.csv

clinicaltrials_gov_download(c("NCT02110043", "NCT03281616"), "versions.csv")
```

### Extract publications indexed on downloaded trial versions

The function `clinicaltrials_gov_download` downloads a data frame of
versions of a trial's history, with the `references` column containing
a nested JSON-encoded data frame of the publications that were indexed
by ClinicalTrials.gov.

The function `extract_publications` interprets a data frame of the
type returned by `clinicaltrials_gov_download` and returns a new data
frame that contains only publications of the type specified ("RESULT",
"BACKGROUND", or "DERIVED").

This function will provide one row for every publication of the type
specified that was indexed on ClinicalTrials.gov for every version of
the trial registry record contained on the data frame provided.

```{r}
## Download only the latest clinical trial registry entries for the 
## specified NCT numbers and extract PMID's for indexed RESULT 
## publications

clinicaltrials_gov_download(
  c("NCT05784103", "NCT05780281"), 
  latest=TRUE
) %>%
  extract_publications(type="RESULT") %>%
  select(nctid, pmid)

# A tibble: 2 × 2
  nctid       pmid    
  <chr>       <chr>   
1 NCT05784103 28183823
2 NCT05780281 34928698
```

### Calculate overall status lengths

The function `clinicaltrials_gov_download` downloads a data frame of
versions of a trial's history, with the `overall_status` column
indicating the status of the trial on the date the entry is updated,
which is specified in the `version_date` column.

The function `overall_status_lengths` interprets a data frame of the
type returned by `clinicaltrials_gov_download` and returns a new data
frame that contains a list of the NCT numbers and all the overall
statuses that the trial in question passed through, and for how many
days, optionally, within a specified timeframe.

```{r}
## Download the clinical trial registry entries for the specified NCT
## number(s) and calculate the number of days that each registry entry
## spends in a reported overall status within a prescribed time
## interval of interest (in this case, the years 2020-2022, inclusive)

clinicaltrials_gov_download(
    c("NCT04338971", "NCT03461211")
) %>%
    overall_status_lengths(
        start_date = "2020-01-01",
        end_date = "2022-12-31"
    )

# A tibble: 5 × 3
# Groups:   nctid [2]
  nctid       overall_status          days    
  <chr>       <chr>                   <drtn>  
1 NCT03461211 ACTIVE_NOT_RECRUITING   406 days
2 NCT03461211 COMPLETED               668 days
3 NCT03461211 ENROLLING_BY_INVITATION  21 days
4 NCT04338971 COMPLETED               488 days
5 NCT04338971 WITHHELD                511 days
```

## What data is extracted?

| Variable                          |          Data type |
|:----------------------------------|-------------------:|
| Version number (0, 1, 2, etc.)    |             Double |
| Version date (ISO-8601)           |               Date |
| Overall status                    |          Character |
| Start date                        |               Date |
| Start date precision              |          Character |
| Primary completion date           |               Date |
| Primary completion date precision |               Date |
| Primary completion date type      |          Character |
| Enrolment                         |             Double |
| Enrolment type                    |          Character |
| Inclusion and exclusion criteria  |   Character (HTML) |
| Outcome measures                  | JSON-encoded table |
| Overall contacts                  | JSON-encoded table |
| Central contacts                  | JSON-encoded table |
| Responsible party                 | JSON-encoded table |
| Lead sponsor                      | JSON-encoded table |
| Collaborators                     | JSON-encoded table |
| Locations                         | JSON-encoded table |
| "Why stopped?"                    |          Character |
| Results posted                    |            Logical |
| References                        | JSON-encoded table |
| Organization study ID             |          Character |
| Secondary IDs                     | JSON-encoded table |

## Note regarding ClinicalTrials.gov July 2023 website re-write

For `cthist` v >= 2.0.0, the method for downloading has been updated
to reflect the new version of ClinicalTrials.gov. Because the data on
the updated website are presented differently from the way they were
scraped from the old version, there will be some changes. E.g. the
overall status field is now in all-caps.

## DRKS.de functions deprecated

**Update as of 2022-12-11**

DRKS.de has recently been updated in a manner that makes scraping data
more difficult and so the functions related to DRKS.de have been
deprecated, at least temporarily while I assess the changes.

## Note on use

Please note that this script is provided under AGPL v 3, and so you
may use it for any purpose, however if you modify it, you must provide
access to your modified version or you are in violation of the terms
of the license.

## Citing `cthist`

```
@Manual{bgcarlisle-cthist,
  title          = {Analysis of Clinical Trial Registry Entry Histories Using the Novel {{R}} Package cthist},
  author         = {Carlisle, Benjamin Gregory},
  date           = {2022-07-01},
  journaltitle   = {PLOS ONE},
  shortjournal   = {PLOS ONE},
  volume         = {17},
  number         = {7},
  pages          = {e0270909},
  publisher      = {{Public Library of Science}},
  issn           = {1932-6203},
  doi            = {10.1371/journal.pone.0270909},
  url            = {https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0270909}
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
