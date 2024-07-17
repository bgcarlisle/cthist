#' Download a registry entry version from ClinicalTrials.gov
#'
#' @param nctid A character string including a well-formed
#'     ClinicalTrials.gov NCT Number, e.g. "NCT00942747". (A
#'     capitalized "NCT" followed by eight numerals with no spaces or
#'     hyphens.)
#'
#' @param versionno An integer version number, e.g. 3, where 0 is the
#'     earliest version of the trial in question, 1 is the next most
#'     recent, etc. (Please note that this differs from the convention
#'     used in cthist v. <= 1.4.2, in which 1 is the earliest version
#'     of the trial in question.) If no version number is specified,
#'     the first version will be downloaded. If -1 (negative one) is
#'     specified, the latest version will be downloaded.
#'
#' @return A list containing the overall status, enrolment, start
#'     date, start date precision (month or day) primary completion
#'     date, primary completion date precision (month or day), primary
#'     completion date type, minimum age, maximum age, sex, accepts
#'     healthy volunteers, inclusion/exclusion criteria, outcome
#'     measures, overall contacts, central contacts, responsible
#'     party, lead sponsor, collaborators, locations, reason why the
#'     trial stopped (if provided), whether results are posted,
#'     references data, organization identifiers and other secondary
#'     trial identifiers.
#'
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#'
#' \donttest{
#' version <- clinicaltrials_gov_version("NCT00942747", 1)
#' }

clinicaltrials_gov_version <- function(
                                       nctid,
                                       versionno=0
                                       ) {

    out <- tryCatch({

        ## Check that TRN is well-formed
        if (! grepl("^NCT\\d{8}$", nctid)) {
            stop(paste0("'", nctid, "' is not a well-formed TRN"))
        }

        ## Check that version number is numeric
        if (! is.numeric(versionno)) {
            stop(paste0("'", versionno, "' is not a number"))
        }

        ## Check that version number is a whole number
        if (versionno %% 1 != 0) {
            stop(paste0("'", versionno, "' is not a whole number"))
        }
   
        ## Check that the site is reachable
        if (httr::http_error("https://clinicaltrials.gov")) {
            message("Unable to connect to clinicaltrials.gov")
            return ("Error")
        }

        ## Get the version number if versionno is -1 (latest)
        if (versionno == -1) {
            dates <- clinicaltrials_gov_dates(nctid)
            versionno <- max(dates$version_number)
        }
        
        url <- paste0(
            "https://clinicaltrials.gov/api/int/studies/",
            nctid,
            "/history/",
            versionno
        )

        ## Read the study version in to memory from the server
        version <- jsonlite::read_json(url, simplifyVector=TRUE)
        ## Make shorter variable names
        prot <- version$study$protocolSection

        
        ## Read the overall status
        ostatus <- NA
        ostatus <- prot$statusModule$overallStatus

        ## Read the "why stopped"
        whystopped <- NA
        if (! is.null(prot$statusModule$whyStopped)) {
            whystopped <- prot$statusModule$whyStopped
        }
        
        ## Read the enrolment and type
        enrol <- NA
        enrol <- prot$designModule$enrollmentInfo$count
        enroltype <- NA
        enroltype <- prot$designModule$enrollmentInfo$type
        
        ## Read the study start date
        startdate <- NA
        startdate_precision <- NA

        startdate_raw <- prot$statusModule$startDateStruct$date

        if (! is.null(startdate_raw)) {
            if (stringr::str_length(startdate_raw) == 10) {
                startdate_precision <- "day"
                startdate <- startdate_raw
            } else {
                startdate_precision <- "month"
                startdate <- paste0(startdate_raw, "-01")
            }
        }

        ## Read the primary completion date

        pcdate_raw <- prot$statusModule$primaryCompletionDateStruct
        
        pcdate <- NA
        pcdate_precision <- NA
        pcdate_type <- NA

        if (! is.null(pcdate_raw$date)) {
            pcdate <- pcdate_raw$date
            if (stringr::str_length(pcdate) == 10) {
                pcdate_precision <- "day"
            } else {
                pcdate_precision <- "month"
                pcdate <- paste0(pcdate, "-01")
            }
            pcdate_type <- pcdate_raw$type
        }
        
        ## Read the eligibility criteria

        elig <- prot$eligibilityModule

        min_age <- NA
        if (! is.null(elig$minimumAge)) {
            min_age <- elig$minimumAge
        }
        
        max_age <- NA
        if (! is.null(elig$maximumAge)){
            max_age <- elig$maximumAge
        }
        
        sex <- NA
        if (! is.null(elig$sex)){
            sex <- elig$sex
        }
        
        accepts_healthy_volunteers <- NA
        accepts_healthy_volunteers <- elig$healthyVolunteers

        criteria <- NA
        criteria <- elig$eligibilityCriteria
        
        ## Read the outcome measures

        om <- version$study$protocolSection$outcomesModule

        primary_om <- om$primaryOutcomes %>%
            tibble::tibble() %>%
            dplyr::mutate(ordinal = "Primary")

        cols <- c("measure", "timeFrame", "description")
        add <- cols[! cols %in% names(primary_om)]

        if (length(add) != 0) {
            primary_om[add] <- as.character(NA)
        }
        
        primary_om <- primary_om %>%
            dplyr::select(
                       "ordinal",
                       "measure",
                       "timeFrame",
                       "description"
                   )

        if (! is.null(om$secondaryOutcomes)) {
            secondary_om <- om$secondaryOutcomes %>%
                tibble::tibble() %>%
                dplyr::mutate(ordinal = "Secondary")

            cols <- c("measure", "timeFrame", "description")
            add <- cols[! cols %in% names(secondary_om)]

            if (length(add) != 0) {
                secondary_om[add] <- as.character(NA)
            }

            secondary_om <- secondary_om %>%
                dplyr::select(
                           "ordinal",
                           "measure",
                           "timeFrame",
                           "description"
                       )
            
            outcomes <- primary_om %>%
                dplyr::bind_rows(secondary_om)
        } else {
            outcomes <- primary_om
        }


        om_data <- outcomes %>%
            jsonlite::toJSON()

        ## Read the Contacts

        conlm <- version$study$protocolSection$contactsLocationsModule
        
        overall_contacts <- conlm$overallOfficials %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        central_contacts <- conlm$centralContacts %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        ## Read the sponsor/collaborators

        spocm <- prot$sponsorCollaboratorsModule

        responsible_party <- spocm$responsibleParty %>%
            jsonlite::toJSON()

        lead_sponsor <- spocm$leadSponsor %>%
            jsonlite::toJSON()
        
        collaborators <- spocm$collaborators %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        ## Read the study locations

        locs <- prot$contactsLocationsModule$locations %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        ## Check for the presence of study results

        results_posted <- NA
        results_posted <- version$study$hasResults
        
        ## Read References

        references_data <- prot$referencesModule$references %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        ## Read secondary identifiers

        orgstudyid <- NA
        orgstudyid <- prot$identificationModule$orgStudyIdInfo$id

        secondaryids <- NA
        secondaryids <- prot$identificationModule$secondaryIdInfos %>%
            tibble::tibble() %>%
            jsonlite::toJSON()
        
        ## Now, put all these data points together

        data <- list(
            ostatus = ostatus,
            enrol = enrol,
            enroltype = enroltype,
            startdate = startdate,
            startdate_precision = startdate_precision,
            pcdate = pcdate,
            pcdate_precision = pcdate_precision,
            pcdate_type = pcdate_type,
            min_age = min_age,
            max_age = max_age,
            sex = sex,
            accepts_healthy_volunteers = accepts_healthy_volunteers,
            criteria = criteria,
            outcomes = om_data,
            overall_contacts = overall_contacts,
            central_contacts = central_contacts,
            responsible_party = responsible_party,
            lead_sponsor = lead_sponsor,
            collaborators = collaborators,
            locations = locs,
            whystopped = whystopped,
            results_posted = results_posted,
            references = references_data,
            orgstudyid = orgstudyid,
            secondaryids = secondaryids
        )

        return(data)

    },
    error = function(cond) {
        message(
            paste(
                "Error downloading version:",
                nctid,
                "version",
                versionno
            )
        )
        message("Here's the original error message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of error
        return("Error")
    },
    warning = function(cond) {
        message(
            paste(
                "Version caused a warning:",
                nctid,
                "version",
                versionno
            )
        )
        message("Here's the original warning message:")
        message(paste(cond, "\n"))
        ## Choose a return value in case of warning
        return("Warning")
    },
    finally = {
        ## To execute regardless of success or failure
    })

    return(out)

}
