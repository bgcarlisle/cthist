test_that("ClinicalTrials.gov primary completion date type downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$pcdatetype,
        "Anticipated"
    )
})
