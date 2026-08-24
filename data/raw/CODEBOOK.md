
# Codebook: The Domestic Homicide Review Dataset (DHRD) for England and Wales

## Overview

This codebook describes the variables included in the Domestic Homicide Review Dataset (DHRD) for England and Wales.

The dataset is organised into four linked CSV files:

* `documents.csv`
* `incidents.csv`
* `victims.csv`
* `perpetrators.csv`

The dataset is derived from publicly available Home Office metadata associated with Domestic Homicide Review reports, including tagging and filtering categories exposed through the Home Office website. It is not based on manual coding of the full report texts.

## General coding notes

### Missing values

Missing or unknown values indicate that the information was not available, not recorded, not applicable, or could not be extracted from the Home Office metadata.

Users should not assume that a missing value means that a characteristic was absent.

### Boolean variables

Boolean variables are coded as:

| Value     | Meaning                                                          |
| --------- | ---------------------------------------------------------------- |
| `TRUE`  | The characteristic was indicated in the Home Office metadata     |
| `FALSE` | The characteristic was not indicated in the Home Office metadata |
| missing   | Unknown, unavailable, not applicable, or not extracted           |

For variables derived from Home Office tags, `FALSE` should be interpreted cautiously. It means that the feature was not identified through the available metadata, not necessarily that the feature was absent from the case.

### One-hot encoded variables

Some characteristics are represented using multiple one-hot encoded columns. For example, mental health indicators and vulnerability indicators may each be represented across several binary columns.

Column prefixes are used to group related variables:

| Prefix                | Meaning                                     |
| --------------------- | ------------------------------------------- |
| `victim_mh_`        | Victim mental health-related indicator      |
| `victim_vuln_`      | Victim vulnerability-related indicator      |
| `perpetrator_mh_`   | Perpetrator mental health-related indicator |
| `perpetrator_vuln_` | Perpetrator vulnerability-related indicator |

## File: `documents.csv`

Each row represents one Domestic Homicide Review document identified during data collection.

| Variable        | Type   | Description                                                         | Values / coding notes                                          |
| --------------- | ------ | ------------------------------------------------------------------- | -------------------------------------------------------------- |
| `document_id` | string | Unique identifier for the DHR document.                             | Primary key for`documents.csv`.                              |
| `incident_id` | string | Unique identifier for a domestic homicide.                          | Foreign key connecting`documents.csv`with `incidents.csv` |
| `title`       | string | Title of the DHR report.                                            | As recorded in the Home Office metadata.                       |
| `download_id` | string | Unique identifier for a DHR download.                               | As recorded in the Home Office metadata.                       |
| `upload_date` | date   | Date the document was published or made available, where available. | Format:`MM-YYYY`, if available.                              |
| `report_url`  | string | URL of the document or Home Office record.                          | Public source URL.                                             |

## File: `incidents.csv`

Each row represents one domestic homicide incident or case.

| Variable                      | Type    | Description                                                                                                                              | Values / coding notes                                                                                                     |
| ----------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `incident_id`               | string  | Unique identifier for the incident.                                                                                                      | Primary key for`incidents.csv`.                                                                                         |
| `csp`                       | string  | Community Service Partnership.                                                                                                           | As recorded by Home Office metadata.                                                                                      |
| `region`                    | string  | Location associated with the incident, where available.                                                                                  | Refers to the local area where the CSP is based.                                                                          |
| `death_date`                | date    | Date of death.                                                                                                                           | Format:`MM-YYYY`, if available.                                                                                         |
| `multiple_victims`          | boolean | Indicates whether the incident involved one or two victims.                                                                              | `TRUE`if there were more than a single victim (max. 2 victims); otherwise `FALSE`                                    |
| `cause_of_death`            | string  | Cause or method of death, where available.                                                                                               | Derived from available metadata.                                                                                          |
| `location_of_death`         | string  | Location of death.                                                                                                                       | Derived from available metadata. Eligible values are`Public place`, `Residential location`, `Other`,`Not known` |
| `intimate_partner_violence` | boolean | Indicates whether the incident was a case of intimate partner violence (IPV), according to Home Office Metadata.                         | `TRUE`if `intimate_partner_violence`is present, `FALSE`otherwise.                                                 |
| `familial_homicide`         | boolean | Indicates whether the incident was a case of familial homicide, according to Home Office Metadata.                                       | `TRUE`if `familial_homicide`is present, `FALSE`otherwise.                                                         |
| `parricide`                 | boolean | Indicates whether the incident was a case of parricide, according to Home Office Metadata.                                              | `TRUE`if `parricide`is present, `FALSE`otherwise.                                                                 |
| `homicide_suicide`          | boolean | Indicates whether the incident was a homicide/suicide, according to Home Office Metadata.                                                | `TRUE`if `homicide_suicide`is present, `FALSE`otherwise.                                                          |
| `children_present`          | boolean | Indicates whether children were present at the time of death, according to Home Office Metadata.                                         | `TRUE`if `children_present`is present, `FALSE`otherwise.                                                          |
| `coercive_control`          | boolean | Indicates whether the incident was flagged for coercive or controling behaviour by the perpetrator, according to Home Office Metadata.  | `TRUE`if `coercive_control`is present, `FALSE`otherwise.                                                          |
| `economic_abuse`            | boolean | Indicates whether the incident was flagged for economic abuse by the perpetrator, according to Home Office Metadata.                    | `TRUE`if `economic_abuse`is present, `FALSE`otherwise.                                                            |
| `faith_based_marriage`      | boolean | Indicates whether the incident was flagged for faith-based marriage, according to Home Office Metadata.                                 | `TRUE`if `faith_based_marriage`is present, `FALSE`otherwise.                                                      |
| `forced_marriage`           | boolean | Indicates whether the incident was flagged for forced marriage, according to Home Office Metadata.                                      | `TRUE`if `force_marriage`is present, `FALSE`otherwise.                                                            |
| `physical_abuse`            | boolean | Indicates whether the incident was flagged for physical abuse by the perpetrator, according to Home Office Metadata.                   | `TRUE`if `physical_abuse`is present, `FALSE`otherwise.                                                            |
| `emotional_abuse`           | boolean | Indicates whether the incident was flagged for emotional or psychological abuse by the perpetrator, according to Home Office Metadata. | `TRUE`if `emotional_abuse`is present, `FALSE`otherwise.                                                           |
| `separation`                | boolean | Indicates whether the incident was flagged for separation, according to Home Office Metadata.                                           | `TRUE`if `separation`is present, `FALSE`otherwise.                                                                |
| `sexual_abuse`              | boolean | Indicates whether the incident was flagged for sexual abuse by the perpetrator, according to Home Office Metadata.                      | `TRUE`if `sexual_abuse`is present, `FALSE`otherwise.                                                              |
| `stalking`                  | boolean | Indicates whether the incident was flagged for stalking by the perpetrator, according to Home Office Metadata.                          | `TRUE`if `stalking`is present, `FALSE`otherwise.                                                                  |

## File: `victims.csv`

Each row represents one victim in a single-victim incident.

Victim-level records are restricted to single-victim incidents where victim characteristics can be assigned unambiguously. Multi-victim incidents are retained in `incidents.csv` but are not included in `victims.csv` unless individual victim characteristics could be reliably distinguished.

| Variable                          | Type        | Description                                                                     | Values / coding notes                                                                                                                          |
| --------------------------------- | ----------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `victim_id`                     | string      | Unique identifier for the victim.                                               | Primary key for`victims.csv`.                                                                                                                |
| `incident_id`                   | string      | Identifier linking the victim to an incident.                                   | Foreign key linking to`incidents.csv`.                                                                                                       |
| `age_at_death`                  | categorical | Victim age, where available.                                                    | Ages grouped into ranges, as per Home Office metadata. Categories:``16-19``,``20-24``,``25-34``,``35-44``,``45-54``,``55-64``, ``65+``.       |
| `sex_of_victim`                 | categorical | Victim sex, where available.                                                    | Values may include categories such as`female`, `male`, `other`, or ``unknown``.                                                          |
| ``sexual_orientation_of_victim``  | categorical | Victim sexual orientation, where available.                                     | Values may include categories such as``Heterosexual/Straight``, ``Gay/Lesbian``, ``Bisexual``, ``Other``,``Unknown``.                          |
| `prev_offence_history`          | boolean     | Victim previous offence history, where known.                                   | ``TRUE``where the victim has a previous offence, ``FALSE`` otherwise.                                                                          |
| `victim_religion`               | categorical | Victim religion, where known.                                                   | Derived from available metadata:``Christian``, ``Buddhist``, ``Hindu``,``Sikh``,``Muslim``,``Jewish``,``No religion``, ``Other``, ``Unknown``. |
| ``victim_ethnicity``              | categorical | Victim ethnicity, where known.                                                  | Derived from available Home Office metadata.                                                                                                   |
| ``relationship_to_perpetrator``   | categorical | Victim relationship to the perpetrator.                                         | Derived from available Home Office metadata.                                                                                                   |
| ``victim_suicide``                | boolean     | Indicates if death was a result of suicide.                                     | ``TRUE``if death was due to suicide, ``FALSE`` otherwise.                                                                                      |
| ``victim_carer_responsibilities`` | boolean     | Indicates if the victim had caring responsibilities.                            | ``TRUE`` if the victim had caring responsibilities, ``FALSE`` otherwise.                                                                       |
| `victim_mental_health_issues`   | boolean     | Indicates whether any victim mental health-related characteristic was recorded. | Derived from`victim_mh_` variables (see below), where available.                                                                             |

### Victim mental health variables

Variables beginning with `victim_mh_` indicate whether the Home Office metadata recorded a mental health-related characteristic for the victim.

| Variable             | Type    | Description                                                                              | Values / coding notes                                                                                                                                                                                                                                              |
| -------------------- | ------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `victim_mh_[name]` | boolean | Indicates whether this mental health-related characteristic was recorded for the victim. | Replace`[name]` with the specific category used in the dataset: ``adjustment_disorder``, ``anxiety``, ``dementia``, ``depression``, ``panic_attacks``, ``PTSD``, ``pschyosis``, ``self-harm``, ``suicidal thoughts``, ``suicide attempts``, ``other``. |

### Victim vulnerability variables

Variables beginning with `victim_vuln_` indicate whether the Home Office metadata recorded a vulnerability-related characteristic for the victim.

| Variable               | Type    | Description                                                                              | Values / coding notes                                                                                                                                                                      |
| ---------------------- | ------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `victim_vuln_[name]` | boolean | Indicates whether this vulnerability-related characteristic was recorded for the victim. | Replace`[name]` with the specific category used in the dataset: ``alcohol`` ,``housing`` ,``neurodiversity`` ,``physical disability`` ,``pregnancy`` ,``substance abuse`` ,``other``.  |

## File: `perpetrators.csv`

Each row represents one perpetrator associated with an incident.

| Variable                               | Type        | Description                                                                          | Values / coding notes                                                                                                                                                              |
| -------------------------------------- | ----------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `perpetrator_id`                     | string      | Unique identifier for the perpetrator.                                               | Primary key for`perpetrators.csv`.                                                                                                                                               |
| `incident_id`                        | string      | Identifier linking the perpetrator to an incident.                                   | Foreign key linking to`incidents.csv`.                                                                                                                                           |
| ``age_at_fatal_incident``              | categorical | Victim age, where available.                                                         | Ages grouped into ranges, as per Home Office metadata. Categories:``16-19``,``20-24``,``25-34``,``35-44``,``45-54``,``55-64``, ``65+``.                                           |
| `sex_of_perpetrator`                 | categorical | Perpetrator sex, where available.                                                    | Values may include categories such as`female`, `male`, `other`, or ``unknown``.                                                                                              |
| ``sexual_orientation_of_perpetrator``  | categorical | Perpetrator sexual orientation, where available.                                     | Values may include categories such as``Heterosexual/Straight``, ``Gay/Lesbian``, ``Bisexual``, ``Other``,``Unknown``.                                                              |
| `perpetrator_ethnicity`              | categorical | Perpetrator ethnicity, where available.                                              | Derived from available Home Office metadata.                                                                                                                                       |
| ``prev_offence_history ``              | boolean     | Previous offence history, where known.                                               | ``TRUE``where the perpetrator has a previous offence, ``FALSE`` otherwise.                                                                                                        |
| `court_verdict`                      | categorical | Court verdict or case outcome associated with the perpetrator, where available.      | May be missing or not applicable. Eligible values may include:``Murder``, ``Manslaughter``, ``Manslaughter w/ diminished responsibility``, ``Not guilty``, ``Other``, ``Unknown``. |
| ``perpetrator_carer_responsibilities`` | boolean     | Indicates if the perpetrator has carer responsibilities.                            | ``TRUE`` if the victim had caring responsibilities, ``FALSE`` otherwise.                                                                                                           |
| ``perpetrator_carer_for_victim``       | boolean     | Indicates if the perpetrator has carer responsibilities for the victim specifically. | ``TRUE`` if the victim had caring responsibilities for the victim specifically, ``FALSE`` otherwise.                                                                               |
| `perpetrator_mental_health_issues`   | boolean     | Indicates whether any perpetrator mental health-related characteristic was recorded. | Derived from`perpetrator_mh_` variables, where available.                                                                                                                        |

### Perpetrator mental health variables

Variables beginning with `perpetrator_mh_` indicate whether the Home Office metadata recorded a mental health-related characteristic for the perpetrator.

| Variable                  | Type    | Description                                                                                   | Values / coding notes                                                                                                                                                                                                                                               |
| ------------------------- | ------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `perpetrator_mh_[name]` | boolean | Indicates whether this mental health-related characteristic was recorded for the perpetrator. | Replace`[name]` with the specific category used in the dataset: ``adjustment_disorder``, ``anxiety``, ``dementia``, ``depression``, ``panic_attacks``, ``PTSD``, ``pschyosis``, ``self-harm``, ``suicidal thoughts``, ``suicide attempts``, ``other``.  |

### Perpetrator vulnerability variables

Variables beginning with `perpetrator_vuln_` indicate whether the Home Office metadata recorded a vulnerability-related characteristic for the perpetrator.

| Variable                    | Type    | Description                                                                                   | Values / coding notes                                                                                                                                                     |
| --------------------------- | ------- | --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `perpetrator_vuln_[name]` | boolean | Indicates whether this vulnerability-related characteristic was recorded for the perpetrator. | Replace`[name]` with the specific category used in the dataset: ``alcohol`` ,``housing`` ,``neurodiversity`` ,``physical disability`` ,``substance abuse`` ,``other``. |

## Recommended citation

Users should cite the version of the dataset used. A DOI citation will be added following publication on Zenodo.

## Contact

For questions about the dataset, contact Darren Cook at [darren.cook@citystgeorges.ac.uk](mailto:darren.cook@citystgeorges.ac.uk).