test_that("DRKS recruitment status downloads correctly", {
    version <- drks_de_version("DRKS00015220", 1)
    expect_equal(
        version$rstatus,
        "Recruiting complete, follow-up complete"
    )
})
