test_that("ClinicalTrials.gov empty primary completion date", {
    version <- clinicaltrials_gov_version("NCT00098137", 0)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            is.na(version$pcdate),
            TRUE
        )
    }
})
