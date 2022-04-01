test_that("ClinicalTrials.gov overall status downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$ostatus,
        "Recruiting"
    )
})
