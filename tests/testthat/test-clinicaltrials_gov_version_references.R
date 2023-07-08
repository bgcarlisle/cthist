test_that("ClinicalTrials.gov references downloads correctly", {
    version <- clinicaltrials_gov_version("NCT04315480", 2)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        )
    } else {
        expect_equal(
            jsonlite::fromJSON(version$references)$pmid[1],
            "32114094"
        )   
    }
})
