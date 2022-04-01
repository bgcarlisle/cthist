test_that("ClinicalTrials.gov enrolment downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$enrol,
        "22 [Anticipated]"
    )
})
