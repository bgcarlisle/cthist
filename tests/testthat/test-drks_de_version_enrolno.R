test_that("DRKS enrolment number downloads correctly", {
    version <- drks_de_version("DRKS00004013", 7)
    expect_equal(
        version$enrolno,
        "300"
    )
})
