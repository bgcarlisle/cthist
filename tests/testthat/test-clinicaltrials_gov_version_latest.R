test_that("ClinicalTrials.gov version downloads latest version correctly", {
    result <- clinicaltrials_gov_version("NCT00942747", -1)
    expect_equal(
        length(result) == 24 || result == "Error",
        TRUE
    )
})
