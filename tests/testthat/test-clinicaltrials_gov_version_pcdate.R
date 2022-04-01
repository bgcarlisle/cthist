test_that("ClinicalTrials.gov primary completion date downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$pcdate,
        "2015-08-01"
    )
})
