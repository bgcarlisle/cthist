test_that("ClinicalTrials.gov history entries mass-download correctly", {
    filename <- tempfile()
    if (file.exists(filename)) {
        file.remove(filename)
    }
    expect_equal(
        clinicaltrials_gov_download(
            c("NCT00942747", "NCT04796324"), filename
        ),
        TRUE
    )
})
