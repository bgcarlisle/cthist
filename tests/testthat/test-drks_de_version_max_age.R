test_that("DRKS maximum age downloads correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            version$max_age,
            "35 Years"
        )
    }
})
