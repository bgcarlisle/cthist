# Clinical Trial Registry History

## How to install

To install through `git`, you will need to install `devtools` first:

```{r}
install.packages("devtools")
library(devtools)
install_github("bgcarlisle/cthist")
```

Download clinical trial version dates:

```{r}
## Get all the dates when the registry entry for NCT02110043 changed
clinicaltrials_gov_version_dates("NCT02110043")
## [1] "2014-04-08" "2014-09-22" "2014-10-13" "2016-03-15" "2016-12-20"
## [6] "2017-07-04" "2017-07-26" "2021-05-20"
```
Download clinical trial version data:

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
