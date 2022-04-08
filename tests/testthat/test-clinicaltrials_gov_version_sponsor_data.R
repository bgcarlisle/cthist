test_that("ClinicalTrials.gov contacts downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$sponsor_data)$content[1],
            "Charite University, Berlin, Germany"
        )
    }
})
