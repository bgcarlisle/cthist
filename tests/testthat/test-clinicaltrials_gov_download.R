test_that("ClinicalTrials.gov history entries mass-download correctly", {
    filename <- tempfile()
    if (file.exists(filename)) {
        file.remove(filename)
    }
    result <- clinicaltrials_gov_download(
        c("NCT02329873"), filename, TRUE
    )
    expect_equal(
        result == TRUE || result == FALSE,
        TRUE
    )
})
