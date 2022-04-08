test_that("ClinicalTrials.gov sex downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$sex,
        "All"
    )
})
