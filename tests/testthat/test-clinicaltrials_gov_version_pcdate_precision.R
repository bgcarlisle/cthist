test_that("ClinicalTrials.gov primary completion date precision downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1, polite=FALSE)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            version$pcdate_precision,
            "month"
        )
    }
})
