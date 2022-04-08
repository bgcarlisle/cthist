test_that("DRKS secondary outcomes download correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$secondaryoutcomes),
            "Performance in neuropsychological testing (BOMAT, ZVT, digit span task, dual n-back, PVT) 2-5h after drug intake and the number of self-reported side effects until 5 h after drug intake\n"
        )
    }
})
