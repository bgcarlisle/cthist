#' Download a registry entry version from ClinicalTrials.gov
#'
#' @param nctid A character string including a well-formed
#'     ClinicalTrials.gov NCT Number, e.g. "NCT00942747". (A
#'     capitalized "NCT" followed by eight numerals with no spaces or
#'     hyphens.)
#'
#' @param versionno An integer version number, e.g. 3, where 0 is the
#'     earliest version of the trial in question, 1 is the next most
#'     recent, etc. If no version number is specified, the first
#'     version will be downloaded.
#'
#' @return A list containing the overall status, enrolment, start
#'     date, start date precision (month or day) primary completion
#'     date, primary completion date precision (month or day), primary
#'     completion date type, minimum age, maximum age, sex, accepts
#'     healthy volunteers, inclusion/exclusion criteria, outcome
#'     measures, contacts, sponsors, reason why the trial stopped (if
#'     provided), whether results are posted, and references data
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
#'
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
        if (httr::http_error("https://classic.clinicaltrials.gov")) {
            message("Unable to connect to clinicaltrials.gov")
            return ("Error")
        }
        
        url <- paste0(
            "https://clinicaltrials.gov/api/int/studies/",
            nctid,
            "/history/",
            versionno
        )

        version <- jsonlite::read_json(url, simplifyVector=TRUE)
        
        ## Read the overall status

        ostatus <- NA
        ostatus <- version$study$protocolSection$statusModule$overallStatus

        ## Read the "why stopped"

        whystopped <- NA
        whystopped <- version$study$protocolSection$statusModule$whyStopped
        
        ## Read the enrolment and type

        enrol <- NA
        enrol <- version$study$protocolSection$designModule$enrollmentInfo$count

        enroltype <- NA
        enroltype <- version$study$protocolSection$designModule$enrollmentInfo$type
        
        ## Read the study start date

        startdate <- NA
        startdate_precision <- NA

        startdate <- version$study$protocolSection$statusModule$startDateStruct$date

        if (str_length(startdate) == 10) {
            startdate_precision <- "day"
        } else {
            startdate_precision <- "month"
            startdate <- paste0(startdate, "-01")
        }

        ## Read the primary completion date

        pcdate <- NA
        pcdate_precision <- NA
        pcdate_type <- NA

        pcdate <- version$study$protocolSection$statusModule$primaryCompletionDateStruct$date

        if (str_length(pcdate) == 10) {
            pcdate_precision <- "day"
        } else {
            pcdate_precision <- "month"
            pcdate <- paste0(pcdate, "-01")
        }

        pcdate_type <- version$study$protocolSection$statusModule$primaryCompletionDateStruct$type
        
        ## Read the eligibility criteria

        min_age <- NA
        min_age <- version$study$protocolSection$eligibilityModule$minimumAge
        
        max_age <- NA
        max_age <- version$study$protocolSection$eligibilityModule$maximumAge
        
        sex <- NA
        sex <- version$study$protocolSection$eligibilityModule$sex
                
        accepts_healthy_volunteers <- NA
        accepts_healthy_volunteers <- version$study$protocolSection$eligibilityModule$healthyVolunteers

        criteria <- NA
        criteria <- version$study$protocolSection$eligibilityModule$eligibilityCriteria
        
        ## Read the outcome measures

        primary_om <- version$study$protocolSection$outcomesModule$primaryOutcomes %>%
            tibble::tibble() %>%
            mutate(ordinal = "Primary")

        cols <- c("measure", "timeFrame", "description")
        add <- cols[! cols %in% names(primary_om)]

        if (length(add) != 0) {
            primary_om[add] <- NA
        }
        
        primary_om <- primary_om %>%
            select(ordinal, measure, timeFrame, description)

        if (! is.null(version$study$protocolSection$outcomesModule$secondaryOutcomes)) {
            secondary_om <- version$study$protocolSection$outcomesModule$secondaryOutcomes %>%
                tibble::tibble() %>%
                mutate(ordinal = "Secondary")

            cols <- c("measure", "timeFrame", "description")
            add <- cols[! cols %in% names(secondary_om)]

            if (length(add) != 0) {
                secondary_om[add] <- NA
            }

            secondary_om <- secondary_om %>%
                select(ordinal, measure, timeFrame, description)
            
            outcomes <- primary_om %>%
                bind_rows(secondary_om)
        } else {
            outcomes <- primary_om
        }


        om_data <- outcomes %>%
            jsonlite::toJSON()

        ## Read the Contacts

        overall_contacts <- version$study$protocolSection$contactsLocationsModule$overallOfficials %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        central_contacts <- version$study$protocolSection$contactsLocationsModule$centralContacts %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        ## Read the sponsor/collaborators

        responsible_party <- version$study$protocolSection$sponsorCollaboratorsModule$responsibleParty %>%
            jsonlite::toJSON()

        lead_sponsor <- version$study$protocolSection$sponsorCollaboratorsModule$leadSponsor %>%
            jsonlite::toJSON()
        
        collaborators <- version$study$protocolSection$sponsorCollaboratorsModule$collaborators %>%
            tibble::tibble() %>%
            jsonlite::toJSON()

        ## Check for the presence of study results

        results_posted <- NA
        results_posted <- version$study$hasResults
        
        ## Read References

        references_data <- version$study$protocolSection$referencesModule$references %>%
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
            whystopped = whystopped,
            results_posted = results_posted,
            references = references_data
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
