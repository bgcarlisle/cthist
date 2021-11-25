test_that("ClinicalTrials.gov version dates download correctly", {
    expect_equal(
        "2013-04-15" %in%
        clinicaltrials_gov_dates("NCT00942747"),
        TRUE
    )
})
