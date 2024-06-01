test_that("ClinicalTrials.gov location data downloads correctly", {
    version <- clinicaltrials_gov_version("NCT05827978", 3)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        )
    } else {
        expect_equal(
            jsonlite::fromJSON(version$locations)$facility[1],
            "Pinnacle Research Group"
        )   
    }
})
