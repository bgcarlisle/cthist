test_that("ClinicalTrials.gov 'gender based' downloads correctly", {
    version <- clinicaltrials_gov_version("NCT05306145", 1)
    expect_equal(
        version$gender_based,
        "Yes"
    )
})
