test_that("ClinicalTrials.gov version downloads correctly", {
  expect_equal(length(clinicaltrials_gov_version_data("NCT00942747", 1)), 14)
})
