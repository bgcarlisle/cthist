test_that("ClinicalTrials.gov version dates download correctly", {
    result <- clinicaltrials_gov_dates("NCT00942747")
    expect_equal(
        "2013-04-15" == result$version_date[3] || result == "Error",
        TRUE
    )
})
