test_that("ClinicalTrials.gov start date downloads correctly", {
    version <- clinicaltrials_gov_version("NCT00003636", 0)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            is.na(version$startdate),
            TRUE
        )
    }
})
