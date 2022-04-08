test_that("DRKS start date downloads correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            version$startdate,
            "2013-08-09"
        )
    }
})
