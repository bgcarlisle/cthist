test_that("DRKS contacts download correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$contacts)$label[1],
            "Primary Sponsor"
        )
    }
})
