test_that("ClinicalTrials.gov history entries mass-download correctly", {
    if (file.exists("/tmp/history.csv")) {
        file.remove("/tmp/history.csv")
    }
    expect_equal(clinicaltrials_gov_download(c("NCT00942747", "NCT02110043"), "/tmp/history.csv"), TRUE)
})
