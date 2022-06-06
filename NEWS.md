# cthist 1.2.1

* Implemented checks in `clinicaltrials_gov_download()` and
  `drks_de_download()` that the Internet resources are available and
  fails gracefully in the case that they're not

---

# cthist 1.2.0

---

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

---

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

---

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
