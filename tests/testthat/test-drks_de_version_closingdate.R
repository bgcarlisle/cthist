test_that("DRKS closing date downloads correctly", {
    version <- drks_de_version("DRKS00004013", 7)
    expect_equal(
        version$closingdate,
        "2014-09-01"
    )
})
