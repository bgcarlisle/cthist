test_that("DRKS enrolment type downloads correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    expect_equal(
        version$enroltype,
        "Actual"
    )
})
