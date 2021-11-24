test_that("DRKS.de history entries mass-download correctly", {
    if (file.exists("/tmp/history.csv")) {
        file.remove("/tmp/history.csv")
    }
    expect_equal(drks_de_download(c("DRKS00005219", "DRKS00003170"), "/tmp/drks-history.csv"), TRUE)
})
