test_that("ClinicalTrials.gov 'accepts healthy volunteers' downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    expect_equal(
        version$accepts_healthy_volunteers,
        "No"
    )
})
