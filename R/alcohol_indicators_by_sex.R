# Analyse recorded alcohol vulnerability indicators by victim and perpetrator sex.
#
# Sex categories and alcohol indicators reproduce the Home Office metadata. The
# results are descriptive and do not establish alcohol use, causation, or risk.

data_dir <- file.path("data", "raw")
output_dir <- file.path("data", "derived")
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

read_source <- function(file_name) {
  path <- file.path(data_dir, file_name)
  if (!file.exists(path)) stop("Source file not found: ", path)
  read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

as_indicator <- function(x) {
  value <- tolower(trimws(as.character(x)))
  ifelse(value %in% c("true", "yes", "1"), TRUE,
    ifelse(value %in% c("false", "no", "0"), FALSE, NA)
  )
}

normalise_sex <- function(x) {
  value <- tolower(trimws(as.character(x)))
  result <- ifelse(value == "female", "Female",
    ifelse(value == "male", "Male",
      ifelse(value %in% c("unknown", "other", ""), "Unknown", NA_character_)
    )
  )
  result
}

format_result <- function(numerator, denominator) {
  if (denominator == 0) return(NA_character_)
  paste0(numerator, "/", denominator, " (",
    sprintf("%.1f", 100 * numerator / denominator), "%)")
}

sex_levels <- c("Female", "Male", "Unknown")

incidents <- read_source("incidents.csv")
victims <- read_source("victims.csv")
perpetrators <- read_source("perpetrators.csv")

incident_fields <- c(
  "multiple_victims", "intimate_partner_violence", "familial_homicide",
  "parricide", "homicide_suicide"
)
for (field in incident_fields) incidents[[field]] <- as_indicator(incidents[[field]])
victims$victim_suicide <- as_indicator(victims$victim_suicide)
victims$victim_alcohol_indicator <- as_indicator(victims$victim_vuln_alcohol)
victims$victim_sex <- normalise_sex(victims$sex_of_victim)
perpetrators$perpetrator_alcohol_indicator <-
  as_indicator(perpetrators$perpetrator_vuln_alcohol)
perpetrators$perpetrator_sex <- normalise_sex(perpetrators$sex_of_perpetrator)

if (anyDuplicated(incidents$incident_id) || anyDuplicated(victims$incident_id) ||
    anyDuplicated(perpetrators$incident_id)) {
  stop("Expected one record per incident in each analysis file.")
}

analysis_data <- merge(
  incidents,
  victims[c(
    "incident_id", "victim_suicide", "victim_alcohol_indicator", "victim_sex"
  )],
  by = "incident_id", all = FALSE
)
analysis_data <- merge(
  analysis_data,
  perpetrators[c(
    "incident_id", "perpetrator_alcohol_indicator", "perpetrator_sex"
  )],
  by = "incident_id", all = FALSE
)
analysis_data <- analysis_data[!analysis_data$multiple_victims, ]

required <- c(
  incident_fields, "victim_suicide", "victim_alcohol_indicator",
  "perpetrator_alcohol_indicator", "victim_sex", "perpetrator_sex"
)
if (nrow(analysis_data) != sum(!incidents$multiple_victims) ||
    anyNA(analysis_data[required])) {
  stop("Single-victim records are incomplete or contain unrecognised values.")
}

analysis_data$overlapping_case_type_flags <- rowSums(analysis_data[c(
  "intimate_partner_violence", "familial_homicide", "parricide"
)]) > 1
analysis_data$underlying_case_type <- ifelse(
  analysis_data$parricide, "Parricide",
  ifelse(analysis_data$intimate_partner_violence, "IPV",
    ifelse(analysis_data$familial_homicide, "Other familial", "Other/uncategorised")
  )
)

# Overall sex-specific prevalence, including the small unknown-sex groups.
overall_rows <- list()
index <- 1
for (party in c("Victim", "Perpetrator")) {
  sex_field <- if (party == "Victim") "victim_sex" else "perpetrator_sex"
  indicator_field <- if (party == "Victim") {
    "victim_alcohol_indicator"
  } else {
    "perpetrator_alcohol_indicator"
  }
  for (sex in c(sex_levels, "Total")) {
    subset <- if (sex == "Total") analysis_data else
      analysis_data[analysis_data[[sex_field]] == sex, ]
    recorded <- sum(subset[[indicator_field]])
    total <- nrow(subset)
    overall_rows[[index]] <- data.frame(
      party = party, sex = sex, recorded = recorded,
      not_recorded = total - recorded, total = total,
      percent_recorded = round(100 * recorded / total, 1),
      stringsAsFactors = FALSE
    )
    index <- index + 1
  }
}
overall_by_sex <- do.call(rbind, overall_rows)

# Apply the same mutually exclusive homicide classification as the case-type
# analysis: exclude IPV/familial overlaps and classify familial/parricide as
# parricide. Unknown-sex cases remain in case totals but not sex-specific cells.
homicides <- analysis_data[!analysis_data$victim_suicide, ]
retained_homicides <- homicides[
  !(homicides$intimate_partner_violence & homicides$familial_homicide),
]
retained_homicides$case_type <- paste0(
  retained_homicides$underlying_case_type, " homicide"
)
case_levels <- c(
  "IPV homicide", "Other familial homicide", "Parricide homicide",
  "Other/uncategorised homicide"
)

make_wide_sex_table <- function(data, group_field, groups) {
  rows <- list()
  for (i in seq_along(c(groups, "All retained homicide cases"))) {
    group <- c(groups, "All retained homicide cases")[i]
    group_data <- if (group == "All retained homicide cases") data else
      data[data[[group_field]] == group, ]
    row <- data.frame(case_type = group, stringsAsFactors = FALSE)
    for (sex in c("Female", "Male")) {
      victim_rows <- group_data[group_data$victim_sex == sex, ]
      perpetrator_rows <- group_data[group_data$perpetrator_sex == sex, ]
      row[[paste0("victim_", tolower(sex))]] <- format_result(
        sum(victim_rows$victim_alcohol_indicator), nrow(victim_rows)
      )
      row[[paste0("perpetrator_", tolower(sex))]] <- format_result(
        sum(perpetrator_rows$perpetrator_alcohol_indicator), nrow(perpetrator_rows)
      )
    }
    rows[[i]] <- row
  }
  result <- do.call(rbind, rows)
  result[c(
    "case_type", "victim_female", "victim_male",
    "perpetrator_female", "perpetrator_male"
  )]
}

homicide_by_sex <- make_wide_sex_table(
  retained_homicides, "case_type", case_levels
)

# Suicide-related sex comparison. Use all 65 victim-suicide cases because this
# table does not divide them into case-type categories, so overlapping case-type
# flags do not create duplicate groups. The homicide_suicide flag is treated as
# an overlapping characteristic among cases where the victim did not die by suicide.
victim_suicides <- analysis_data[analysis_data$victim_suicide, ]
perpetrator_suicides <- homicides[homicides$homicide_suicide, ]
victim_suicides$suicide_type <- "Victim suicide"
perpetrator_suicides$suicide_type <- "Homicide followed by perpetrator suicide"
suicide_cases <- rbind(victim_suicides, perpetrator_suicides)

suicide_rows <- list()
suicide_groups <- c(
  "Victim suicide", "Homicide followed by perpetrator suicide",
  "All suicide-related cases"
)
for (i in seq_along(suicide_groups)) {
  group <- suicide_groups[i]
  group_data <- if (group == "All suicide-related cases") suicide_cases else
    suicide_cases[suicide_cases$suicide_type == group, ]
  row <- data.frame(case_type = group, stringsAsFactors = FALSE)
  for (sex in c("Female", "Male")) {
    victim_rows <- group_data[group_data$victim_sex == sex, ]
    perpetrator_rows <- group_data[group_data$perpetrator_sex == sex, ]
    row[[paste0("victim_", tolower(sex))]] <- format_result(
      sum(victim_rows$victim_alcohol_indicator), nrow(victim_rows)
    )
    row[[paste0("perpetrator_", tolower(sex))]] <- format_result(
      sum(perpetrator_rows$perpetrator_alcohol_indicator), nrow(perpetrator_rows)
    )
  }
  suicide_rows[[i]] <- row
}
suicide_by_sex <- do.call(rbind, suicide_rows)
suicide_by_sex <- suicide_by_sex[c(
  "case_type", "victim_female", "victim_male",
  "perpetrator_female", "perpetrator_male"
)]

write.csv(overall_by_sex,
  file.path(output_dir, "alcohol_by_sex.csv"), row.names = FALSE)
write.csv(homicide_by_sex,
  file.path(output_dir, "alcohol_by_homicide_case_type_and_sex.csv"),
  row.names = FALSE)
write.csv(suicide_by_sex,
  file.path(output_dir, "alcohol_by_suicide_type_and_sex.csv"), row.names = FALSE)

message("Sex analysis complete for ", nrow(analysis_data),
  " linked single-victim incidents.")
