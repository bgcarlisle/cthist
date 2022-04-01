test_that("DRKS recruitment status downloads correctly", {
    version <- drks_de_version("NCT02110043", 1)
    expect_equal(
        version$sponsor_data,
        "Charite University, Berlin, Germany"
    )
})
