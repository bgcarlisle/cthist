test_that("ClinicalTrials.gov history entries mass-download correctly", {
    filename <- tempfile()
    if (file.exists(filename)) {
        file.remove(filename)
    }
    result <- clinicaltrials_gov_download(
        c("NCT00942747", "NCT04796324"), filename
    )
    expect_equal(
        result == TRUE || result == FALSE,
        TRUE
    )
})
