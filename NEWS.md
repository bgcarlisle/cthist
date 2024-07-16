# cthist 2.1.11

* Added `overall_status_lengths`, a function that interprets a
  downloaded data frame of historical versions and tallies up the days
  that each clinical trial registry entry spent in each overall status
  within the time frame specified.
* Modified `clinicaltrials_gov_dates`, the function for downloading
  overall status changes and the dates on which they occur to allow
  for downloading many trials' worth at a time.

---

# cthist 2.1.10

* Added `earliest` argument to `clinicaltrials_gov_download` to allow
  a user to specify that they would like to download only the earliest
  version of a trial record

---

# cthist 2.1.9

* Added `locations` data download

---

# cthist 2.1.8

* Added proper citation information linking to the PLOS ONE paper

---

# cthist 2.1.7

* Added new function `extract_publications` to extract publications by
  type from a data frame of downloaded versions into a new data frame.

---

# cthist 2.1.6

* Fixed bug where download will throw an error in cases where a record
  has secondary outcome measures specified, but not primary outcome
  measures

---

# cthist 2.1.5

* Added argument `latest` to function `clinicaltrials_gov_download` to
  allow downloading only the latest version for many clinical trial
  registry entries

---

# cthist 2.1.4

* Fix bug in which start date would erroneously return NA in some
  cases

---

# cthist 2.1.3

* Add support for downloading the latest version of a clinical trial
  only

---

# cthist 2.1.2

* Fix bug where missing start dates in trial record would produce an
  error

---

# cthist 2.1.1

* Fix minor errors in documentation
* Fix bug where missing primary completion dates in trial record would
  produce an error

---

# cthist 2.1.0

* Added download for organization study ID and secondary ID's
* Added unit tests for all functions added since v 1.4.2

--

# cthist 2.0.1

* Minor changes to documentation to better reflect downloaded data

---

# cthist 2.0.0

* Upgrade to allow compatibility with 2023 ClinicalTrials.gov website
  re-write

---

# cthist 1.4.2

* Temporary fix of bugs introduced by ClinicalTrials.gov moving to
  their new website design (changed URL links to
  classic.clinicaltrials.gov)

---

# cthist 1.4.1

* Fixed bug where `cthist` sometimes can't connect to
  ClinicalTrials.gov by replacing the statement that included
  `RCurl::url.exists()` with one that uses `httr::http_error()`
  instead
* Removed `polite` dependency and functionality

---

# cthist 1.4.0

* Removed drks.de-related functions
* Added `polite` variable to allow disabling of "polite" downloading
  for debugging purposes
* Removed deprecated `.data$n` syntax

---

# cthist 1.3.0

* Added "results posted" (indicates whether study results have been
  posted)
* Added "references" to `clinicaltrials_gov_version()` (citations,
  links and available IPD/Information) and `drks_de_version()` (Trial
  Publications, Results and other Documents)
  
---

# cthist 1.2.1

* Implemented checks in `clinicaltrials_gov_download()` and
  `drks_de_download()` that the Internet resources are available and
  fails gracefully in the case that they're not

---

# cthist 1.2.0

* Added `status_change_only` option to `clinicaltrials_gov_dates()`
  function to allow for downloading only the dates on which a trial's
  Recruitment Status changed

---

# cthist 1.1.0

* Added "why stopped" field
* Remove superfluous white space from overall status field
* Fixed bug that occurs in rare cases (version has no overall status)

---

# cthist 1.0.1

* Fix bug where `cthist` does not capture outcome measures in versions
  posted after results are posted.

---

# cthist 1.0.0

* Re-implemented functions that access ClinicalTrials.gov or DRKS.de
  with the `polite` R package to ensure that the sites' rules
  regarding scraping are observed, and to limit the number of requests
* Fix bug where non-English locale prevents correct parsing of month
  names
* Improvements to error-catching during download
* New columns indicating the precision of dates in the original data
  source
* All functions now check that input is well-formed before executing
  and provide informative errors otherwise
* `clinicaltrials_gov_download()` and `drks_de_download()` now return
  a data frame of results if `output_filename` is not specified
* `clinicaltrials_gov_version()` and `drks_de_version()` now return
  named lists rather than vectors
* Added default version numbers to `clinicaltrials_gov_version()` and
  `drks_de_version()`
* More extensive unit testing
* Fix bug in retrieving "gender based" in `clinicaltrials_gov_version()`
* Add "quiet" downloading option
* Improved documentation

---

# cthist 0.1.4

* Fix DRKS bug where post-completion records sometimes contain more
  than one `li.deadline` node, causing formatting errors

---

# cthist 0.1.3

* Fix DRKS bug where multiple contact affiliation nodes caused
  download to produce an error

---

# cthist 0.1.2

* Updated DRKS error message to be more informative on failure
* Updated unit tests to expect graceful error on failure

---

# cthist 0.1.1

* Renamed function `clinicaltrials_gov_version_dates` to
  `clinicaltrials_gov_dates` for brevity
* Renamed function `clinicaltrials_gov_version_data` to
  `clinicaltrials_gov_version` for brevity
* Renamed function `drks_de_version_dates` to
  `drks_de_dates` for brevity
* Renamed function `drks_de_version_data` to
  `drks_de_version` for brevity

---

# cthist 0.1.0

* Added a `NEWS.md` file to track changes to the package.
* Added function `clinicaltrials_gov_version_dates` to download dates
  on which a ClinicalTrials.gov registry entry is updated
* Added function `clinicaltrials_gov_version_data` to download
  registry data for a specific historical version of a clinical trial
  registry entry from ClinicalTrials.gov
* Added function `clinicaltrials_gov_download` to mass-download all
  historical versions of a set of ClinicalTrials.gov registry entry
* Added function `drks_de_version_dates` to download dates
  on which a DRKS.de registry entry is updated
* Added function `drks_de_version_data` to download
  registry data for a specific historical version of a clinical trial
  registry entry from DRKS.de
* Added function `drks_de_download` to mass-download all
  historical versions of a set of DRKS.de registry entry
