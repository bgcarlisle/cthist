# cthist 0.1.4

* Fix DRKS bug where post-completion records sometimes contain more
  than one `li.deadline` node, causing formatting errors

# cthist 0.1.3

* Fix DRKS bug where multiple contact affiliation nodes caused
  download to produce an error

# cthist 0.1.2

* Updated DRKS error message to be more informative on failure
* Updated unit tests to expect graceful error on failure

# cthist 0.1.1

* Renamed function `clinicaltrials_gov_version_dates` to
  `clinicaltrials_gov_dates` for brevity
* Renamed function `clinicaltrials_gov_version_data` to
  `clinicaltrials_gov_version` for brevity
* Renamed function `drks_de_version_dates` to
  `drks_de_dates` for brevity
* Renamed function `drks_de_version_data` to
  `drks_de_version` for brevity

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
