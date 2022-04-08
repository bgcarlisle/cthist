test_that("ClinicalTrials.gov start date precision downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$startdate_precision,
        "month"
    )
})
