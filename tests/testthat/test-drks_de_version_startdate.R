test_that("DRKS start date downloads correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    expect_equal(
        version$startdate,
        "2013-08-09"
    )
})
