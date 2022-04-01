test_that("ClinicalTrials.gov start date downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$startdate,
        "2014-03-01"
    )
})
