test_that("Publications extracted correctly", {
    pmid <- clinicaltrials_gov_download("NCT02586649", latest=TRUE) %>%
        extract_publications(types="RESULT")
    expect_equal(
        pmid$pmid[1],
        "10569435"
    )
})
