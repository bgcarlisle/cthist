test_that("ClinicalTrials.gov maximum age downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$max_age,
        "80"
    )
})
