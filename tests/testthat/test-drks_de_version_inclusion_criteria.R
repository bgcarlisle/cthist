test_that("DRKS inclusion criteria download correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$inclusion_criteria)[2],
            "- Men\n- 18 - 35 years\n- Written consent (according to AMG § 40 (1) 3b)\n- Good knowledge of German\n- right-handedness\n"
        )
    }
})
