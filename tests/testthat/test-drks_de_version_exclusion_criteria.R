test_that("DRKS inclusion criteria download correctly", {
    version <- drks_de_version("DRKS00005219", 1)
    if (version[1] == "Error") {
        expect_equal(
            version[1],
            "Error"
        ) 
    } else {
        expect_equal(
            jsonlite::fromJSON(version$exclusion_criteria)[2],
            "- Known hypersensitivity to the study medication\n- All contraindications to the study medication: arrhythmia, hyperthyroidism , glaucoma , pheochromocytoma , congestive heart failure , diabetes mellitus, known liver and kidney dysfunction, vascular disease , angina, haemodynamically significant congenital heart disease , cardiomyopathy , myocardial infarction, channelopathies, arterial hypertension , cerebrovascular diseases , such as cerebral aneurysm , vascular abnormalities , including vasculitis and stroke.\n- Participation in other clinical trials during or within one month prior to this clinical trial\n- Medical or psychological circumstances that may endanger the proper conduct of the trial\n- Existing serious somatic diseases, even if they are not covered by the contraindications according to product information\n- Existing psychiatric disorders and psychiatric disorders in prehistory\n- Smoker or ex-smoker for less than 5 years\n- Regular caffeine consumption > 4 cups per day\n- Subjects with irregular day -night rhythm (eg shift workers )\n- Unwillingness to the storage and disclosure of pseudonymous data as part of the clinical trial\n- Accommodation in an institution by court or administrative order (according to AMG § 40 (1) 4 )\n- MR contraindications ( eg pacemakers , metallic or electronic implants , metallic splinters , tinnitus, surgical clips )\n"
        )
    }
})
