test_that("DRKS.de history entries mass-download correctly", {
    filename <- tempfile()
    if (file.exists(filename)) {
        file.remove(filename)
    }
    expect_equal(
        drks_de_download(
            c("DRKS00005219", "DRKS00015220"), filename
        ),
        TRUE
    )
})
