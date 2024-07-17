test_that("Overall status lengths parse correctly", {
    versions <- clinicaltrials_gov_download("NCT04338971")
    oslengths <- overall_status_lengths(
        versions,
        start_date = "2020-01-01",
        end_date = "2021-10-31"
    )
    completed <- oslengths %>%
        dplyr::filter(overall_status == "COMPLETED") %>%
        dplyr::pull(days) %>%
        sum() %>%
        as.numeric()

    expect_equal(
        completed,
        62
    )

})
