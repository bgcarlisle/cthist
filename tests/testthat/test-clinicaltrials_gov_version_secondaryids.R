test_that("ClinicalTrials.gov org study ID downloads correctly", {
    version <- clinicaltrials_gov_version("NCT00942747", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            tibble::tibble(
                        jsonlite::fromJSON(
                                      version$secondaryids
                                  )
                    )$id[1],
            "EudraCT 2009-011277-33"
        )
    }
})
