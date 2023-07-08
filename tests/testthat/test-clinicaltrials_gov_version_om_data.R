test_that("ClinicalTrials.gov outcome measures downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$outcomes)$measure[1],
            "Performance in LOCATO task (Visual-spatial learning and memory) after a combination of intensive visual-spatial training and tDCS"
        )
    }
})
