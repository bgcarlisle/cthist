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
            jsonlite::toJSON("Inclusion Criteria (MCI patients):\n\nright handedness\namnestic and amnestic plus MCI with:\nsubjective memory impairment;\nobjective memory difficulties, at least 1 SD below gender, age and education adjusted standard values;\nrelatively normal performance in other cognitive domains;\nno constraints in activities of daily livings\nage: 50-80 years\n\nExclusion Criteria:\n\nsevere internal or psychiatric disease\nepilepsy\nother severe neurological diseases, e.g. previous major stroke or brain tumor\nDMS-IV manifest dementia\ncontraindication for MRT (claustrophobia, metallic implants, tattoos)")
        )   
    }
})
