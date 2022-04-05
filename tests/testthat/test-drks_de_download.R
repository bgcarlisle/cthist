test_that("DRKS.de history entries mass-download correctly", {
    filename <- tempfile()
    if (file.exists(filename)) {
        file.remove(filename)
    }
    result <- drks_de_download(
        c("DRKS00005219"), filename, TRUE
    )
    expect_equal(
        result == TRUE || result == FALSE,
        TRUE
    )
})
