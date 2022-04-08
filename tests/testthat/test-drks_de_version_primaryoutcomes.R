test_that("DRKS primary outcomes download correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$primaryoutcomes),
            "Resting state Parameters from fMRI- ReHo (regional homogeneity) and ALFF (amplitude of low frequency fluctuation)- to be messured once, 1h after drug intake"
        )
    }
})
