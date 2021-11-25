test_that("DRKS.de version downloads correctly", {
  expect_equal(length(drks_de_version("DRKS00005219", 1)), 13)
})
