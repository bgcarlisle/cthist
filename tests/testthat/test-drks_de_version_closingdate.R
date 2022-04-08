test_that("DRKS closing date downloads correctly", {
    version <- drks_de_version("DRKS00004013", 7)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            version$closingdate,
            "2014-09-01"
        )
    }
})
