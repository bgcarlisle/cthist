test_that("ClinicalTrials.gov org study ID downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            version$orgstudyid,
            "LOCATO-MCI-tDCS"
        )
    }
})
