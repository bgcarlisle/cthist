test_that("DRKS gender downloads correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    expect_equal(
        version$gender,
        "Male"
    )
})
