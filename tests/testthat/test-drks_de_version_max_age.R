test_that("DRKS maximum age downloads correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    expect_equal(
        version$max_age,
        "35 Years"
    )
})
