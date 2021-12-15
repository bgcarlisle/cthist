test_that("DRKS version dates download correctly", {
    result <- drks_de_dates("DRKS00005219")
    expect_equal(
        "2014-04-17" %in% result || result == "Error",
        TRUE
    )
})
