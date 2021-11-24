test_that("DRKS version dates download correctly", {
  expect_equal("2014-04-17" %in% drks_de_version_dates("DRKS00005219"), TRUE)
})
