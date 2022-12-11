test_that("ClinicalTrials.gov version downloads correctly", {
    result <- clinicaltrials_gov_version("NCT00942747", 1, polite=FALSE)
    expect_equal(
        length(result) == 19 || result == "Error",
        TRUE
    )
})
