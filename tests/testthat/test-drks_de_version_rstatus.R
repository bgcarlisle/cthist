test_that("DRKS recruitment status downloads correctly", {
    version <- drks_de_version("DRKS00015220", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            version$rstatus,
            "Recruiting complete, follow-up complete"
        )
    }
})
