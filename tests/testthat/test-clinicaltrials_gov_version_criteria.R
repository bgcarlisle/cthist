test_that("ClinicalTrials.gov criteria downloads correctly", {
    version <- clinicaltrials_gov_version("NCT02110043", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        )
    } else {
        expect_equal(
            version$criteria,
            "<p>Inclusion Criteria (MCI patients):</p><ul><li>right handedness</li><li><p>amnestic and amnestic plus MCI with:</p><ol><li>subjective memory impairment;</li><li>objective memory difficulties, at least 1 SD below gender, age and education adjusted standard values;</li><li>relatively normal performance in other cognitive domains;</li><li>no constraints in activities of daily livings</li><li>age: 50-90 years</li></ol></li></ul><p>Exclusion Criteria:</p><ul><li>severe internal or psychiatric disease</li><li>epilepsy</li><li>other severe neurological diseases, e.g. previous major stroke or brain tumor</li><li>DMS-IV manifest dementia</li><li>contraindication for MRT (claustrophobia, metallic implants, tattoos)</li></ul>"
        )   
    }
})
