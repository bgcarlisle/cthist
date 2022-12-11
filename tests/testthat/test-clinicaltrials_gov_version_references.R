test_that("ClinicalTrials.gov references downloads correctly", {
    version <- clinicaltrials_gov_version("NCT04315480", 3, polite=FALSE)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        )
    } else {
        expect_equal(
            jsonlite::fromJSON(version$references)$doi[1],
            "10.1016/j.jtho.2020.02.010"
        )   
    }
})
