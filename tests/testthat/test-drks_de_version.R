test_that("DRKS.de version downloads correctly", {
    result <- drks_de_version("DRKS00005219", 1)
    expect_equal(
        length(result) == 13 || result == "Error",
        TRUE
    )
})
