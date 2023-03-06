test_that("ClinicalTrials.gov outcome measures downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$om_data)$content[1],
            "Performance in LOCATO task (Visual-spatial learning and memory) after a combination of intensive visual-spatial training and tDCS\n[ Time Frame: immediately after end of a 3-day period of training in tDCS condition vs sham condition ]\n\nInvestigation whether the combination of intensive visual-spatial training (LOCATO task) and tDCS leads to improvement of visual-spatial learning and memory measured by performance in LOCATO task after end of a 3 day period of training compared to sham stimulation."
        )
    }
})
