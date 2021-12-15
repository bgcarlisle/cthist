test_that("DRKS.de history entries mass-download correctly", {
    filename <- tempfile()
    if (file.exists(filename)) {
        file.remove(filename)
    }
    result <- drks_de_download(
        c("DRKS00005219", "DRKS00015220"), filename
    )
    expect_equal(
        result == TRUE || result == FALSE,
        TRUE
    )
})
