# Reproduce alcohol vulnerability indicator estimates for single-victim incidents.

data_dir <- file.path("data", "raw")
output_dir <- file.path("data", "derived")

if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

read_source <- function(file_name) {
  read.csv(file.path(data_dir, file_name), stringsAsFactors = FALSE, check.names = FALSE)
}

as_indicator <- function(x) {
  y <- tolower(trimws(as.character(x)))
  ifelse(y %in% c("true", "yes", "1"), TRUE,
         ifelse(y %in% c("false", "no", "0"), FALSE, NA))
}

percent <- function(n, d) round(100 * n / d, 1)

incidents <- read_source("incidents.csv")
victims <- read_source("victims.csv")
perpetrators <- read_source("perpetrators.csv")

incidents$multiple_victims <- as_indicator(incidents$multiple_victims)
victims$victim_alcohol_indicator <- as_indicator(victims$victim_vuln_alcohol)
perpetrators$perpetrator_alcohol_indicator <- as_indicator(perpetrators$perpetrator_vuln_alcohol)

if (anyNA(incidents$multiple_victims)) {
  stop("The multiple_victims field contains unrecognised or missing values.")
}

# Restrict the denominator before linking victim and perpetrator records.
single_incidents <- incidents[!incidents$multiple_victims, "incident_id", drop = FALSE]

if (anyDuplicated(single_incidents$incident_id) ||
    anyDuplicated(victims$incident_id) ||
    anyDuplicated(perpetrators$incident_id)) {
  stop("Expected one record per incident in each analysis file.")
}

incident_alcohol <- merge(
  single_incidents,
  victims[c("incident_id", "victim_alcohol_indicator")],
  by = "incident_id",
  all = FALSE
)
incident_alcohol <- merge(
  incident_alcohol,
  perpetrators[c("incident_id", "perpetrator_alcohol_indicator")],
  by = "incident_id",
  all = FALSE
)

if (nrow(incident_alcohol) != nrow(single_incidents) ||
    !setequal(incident_alcohol$incident_id, single_incidents$incident_id)) {
  stop("Not every single-victim incident has one linked victim and perpetrator record.")
}

if (anyNA(incident_alcohol$victim_alcohol_indicator) ||
    anyNA(incident_alcohol$perpetrator_alcohol_indicator)) {
  stop("Alcohol indicator fields contain unrecognised or missing values.")
}

incident_alcohol$any_alcohol_indicator <-
  incident_alcohol$victim_alcohol_indicator |
  incident_alcohol$perpetrator_alcohol_indicator

incident_alcohol$both_victim_and_perpetrator_alcohol <-
  incident_alcohol$victim_alcohol_indicator &
  incident_alcohol$perpetrator_alcohol_indicator

denominator <- nrow(incident_alcohol)

summary_rows <- data.frame(
  estimate = c(
    "Victim alcohol indicator",
    "Perpetrator alcohol indicator",
    "Victim or perpetrator alcohol indicator",
    "Both victim and perpetrator alcohol indicators"
  ),
  numerator = c(
    sum(incident_alcohol$victim_alcohol_indicator),
    sum(incident_alcohol$perpetrator_alcohol_indicator),
    sum(incident_alcohol$any_alcohol_indicator),
    sum(incident_alcohol$both_victim_and_perpetrator_alcohol)
  ),
  denominator = denominator,
  stringsAsFactors = FALSE
)
summary_rows$percent <- percent(summary_rows$numerator, summary_rows$denominator)

cross_tab <- as.data.frame.matrix(table(
  victim_alcohol = incident_alcohol$victim_alcohol_indicator,
  perpetrator_alcohol = incident_alcohol$perpetrator_alcohol_indicator
))
cross_tab$victim_alcohol <- row.names(cross_tab)
row.names(cross_tab) <- NULL
cross_tab <- cross_tab[c("victim_alcohol", "FALSE", "TRUE")]

write.csv(summary_rows, file.path(output_dir, "alcohol_indicator_summary.csv"), row.names = FALSE)
write.csv(cross_tab, file.path(output_dir, "alcohol_indicator_crosstab.csv"), row.names = FALSE)
write.csv(incident_alcohol, file.path(output_dir, "incident_alcohol_indicators.csv"), row.names = FALSE)

message("Analysed ", denominator, " single-victim incidents; excluded ",
        sum(incidents$multiple_victims), " multiple-victim incidents.")
