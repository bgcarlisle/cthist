test_that("ClinicalTrials.gov minimum age downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$min_age,
        "50"
    )
})
