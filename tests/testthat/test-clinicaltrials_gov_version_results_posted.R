test_that("ClinicalTrials.gov results posted downloads correctly", {
    version_false <- clinicaltrials_gov_version("NCT05168917", 1)
    version_true <- clinicaltrials_gov_version("NCT05168917", 3)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        )
    } else {
        expect_equal(
            version_false$results_posted == FALSE &
            version_true$results_posted == TRUE,
            TRUE
        )   
    }
})
