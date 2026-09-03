# Analyse recorded alcohol vulnerability indicators by DHR case type.
#
# Home Office metadata tags are used throughout. They indicate that an alcohol
# vulnerability was recorded, not alcohol consumption, intoxication or cause.

data_dir <- file.path("data", "raw")
output_dir <- file.path("data", "derived")
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("Package 'ggplot2' is required for the figures.")
}

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

summarise_indicators <- function(data, group_variable, group_levels, measures) {
  rows <- list()
  index <- 1
  for (group in group_levels) {
    group_data <- data[data[[group_variable]] == group, , drop = FALSE]
    for (field in names(measures)) {
      numerator <- sum(group_data[[field]])
      denominator <- nrow(group_data)
      rows[[index]] <- data.frame(
        case_type = group,
        indicator = unname(measures[field]),
        numerator = numerator,
        denominator = denominator,
        percent = if (denominator == 0) NA_real_ else
          round(100 * numerator / denominator, 1),
        stringsAsFactors = FALSE
      )
      index <- index + 1
    }
  }
  do.call(rbind, rows)
}

# Read the source files and convert the fields required for this analysis.
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
perpetrators$perpetrator_alcohol_indicator <-
  as_indicator(perpetrators$perpetrator_vuln_alcohol)

# Link incident, victim and perpetrator records, retaining single-victim cases.
analysis_data <- merge(
  incidents,
  victims[c("incident_id", "victim_suicide", "victim_alcohol_indicator")],
  by = "incident_id", all = FALSE
)
analysis_data <- merge(
  analysis_data,
  perpetrators[c("incident_id", "perpetrator_alcohol_indicator")],
  by = "incident_id", all = FALSE
)
analysis_data <- analysis_data[!analysis_data$multiple_victims, ]

required <- c(
  incident_fields, "victim_suicide", "victim_alcohol_indicator",
  "perpetrator_alcohol_indicator"
)
if (anyNA(analysis_data[required])) {
  stop("Required indicator fields contain missing or unrecognised values.")
}
if (anyDuplicated(analysis_data$incident_id)) {
  stop("More than one linked row was found for an incident.")
}

analysis_data$both_alcohol_indicators <-
  analysis_data$victim_alcohol_indicator &
  analysis_data$perpetrator_alcohol_indicator
analysis_data$overlapping_case_type_flags <- rowSums(analysis_data[c(
  "intimate_partner_violence", "familial_homicide", "parricide"
)]) > 1

# Parricide takes priority because it is a specific subtype of familial homicide.
analysis_data$underlying_case_type <- ifelse(
  analysis_data$parricide, "Parricide",
  ifelse(analysis_data$intimate_partner_violence, "IPV",
    ifelse(analysis_data$familial_homicide, "Other familial", "Other/uncategorised")
  )
)

measures <- c(
  victim_alcohol_indicator = "Victim alcohol indicator",
  perpetrator_alcohol_indicator = "Perpetrator alcohol indicator",
  both_alcohol_indicators = "Both-person alcohol indicators"
)

# Homicide case types: exclude the six cases carrying both IPV and familial
# flags. Retain the 80 familial-plus-parricide cases without IPV as parricide.
all_homicides <- analysis_data[!analysis_data$victim_suicide, ]
homicides_by_type <- all_homicides[
  !(all_homicides$intimate_partner_violence & all_homicides$familial_homicide),
]
homicides_by_type$case_type <- factor(
  paste(homicides_by_type$underlying_case_type, "homicide"),
  levels = c(
    "IPV homicide", "Other familial homicide", "Parricide homicide",
    "Other/uncategorised homicide"
  )
)
case_type_table <- summarise_indicators(
  homicides_by_type, "case_type", levels(homicides_by_type$case_type), measures
)

# Victim-suicide classifications: exclude two cases with overlapping IPV,
# familial or parricide flags so the displayed categories do not overlap.
victim_suicides <- analysis_data[
  analysis_data$victim_suicide & !analysis_data$overlapping_case_type_flags,
]
victim_suicides$case_type <- factor(
  victim_suicides$underlying_case_type,
  levels = c("IPV", "Other familial", "Parricide", "Other/uncategorised")
)
victim_suicide_table <- summarise_indicators(
  victim_suicides, "case_type", levels(victim_suicides$case_type), measures
)

# homicide_suicide is an overlapping incident tag, not a mutually exclusive
# case type. Restricting to victim_suicide == FALSE leaves 64 flagged cases,
# provisionally interpreted as homicide followed by perpetrator suicide.
all_homicides$perpetrator_suicide_group <- ifelse(
  all_homicides$homicide_suicide,
  "Homicide followed by perpetrator suicide",
  "Homicide without perpetrator suicide"
)
perpetrator_suicide_levels <- c(
  "Homicide without perpetrator suicide",
  "Homicide followed by perpetrator suicide"
)
perpetrator_suicide_table <- summarise_indicators(
  all_homicides, "perpetrator_suicide_group",
  perpetrator_suicide_levels, measures
)

# Create publication-ready figures in an IAS-inspired blue palette.
indicator_colours <- c(
  "Victim alcohol indicator" = "#536BB2",
  "Perpetrator alcohol indicator" = "#7B8FC8",
  "Both-person alcohol indicators" = "#A2AFD7"
)

make_bar_chart <- function(data, title, subtitle) {
  data$indicator <- factor(data$indicator, levels = unname(measures))
  ggplot2::ggplot(data, ggplot2::aes(case_type, percent, fill = indicator)) +
    ggplot2::geom_col(
      position = ggplot2::position_dodge(width = 0.78), width = 0.68,
      colour = "#69737A", linewidth = 0.25
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(percent, "%")),
      position = ggplot2::position_dodge(width = 0.78),
      hjust = -0.15, size = 3.1, colour = "#303438"
    ) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(
      limits = c(0, 100), breaks = seq(0, 100, 20),
      labels = function(x) paste0(x, "%"),
      expand = ggplot2::expansion(mult = c(0, 0.03))
    ) +
    ggplot2::scale_fill_manual(values = indicator_colours, drop = FALSE) +
    ggplot2::labs(
      title = title, subtitle = subtitle, x = NULL,
      y = "Cases with a recorded alcohol indicator (%)", fill = NULL,
      caption = "Source: DHRD v1.0.3. Single-victim incidents only."
    ) +
    ggplot2::theme_classic(base_size = 11, base_family = "sans") +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "white", colour = NA),
      panel.background = ggplot2::element_rect(fill = "white", colour = NA),
      plot.title = ggplot2::element_text(size = 15, colour = "#25292C"),
      plot.subtitle = ggplot2::element_text(
        size = 10.5, colour = "#464B4F", margin = ggplot2::margin(b = 12)
      ),
      axis.text = ggplot2::element_text(colour = "#404448", size = 9.5),
      axis.title.x = ggplot2::element_text(
        colour = "#555A5E", size = 10, margin = ggplot2::margin(t = 10)
      ),
      axis.line.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_line(colour = "#555A5E", linewidth = 0.35),
      legend.position = "bottom", legend.justification = "left",
      plot.caption = ggplot2::element_text(size = 8.5, colour = "#666B6E"),
      plot.title.position = "plot", plot.caption.position = "plot"
    )
}

case_type_plot <- make_bar_chart(
  case_type_table,
  "Figure 1. Recorded alcohol indicators across homicide case types",
  "Six IPV/familial overlaps excluded; familial/parricide cases retained as parricide"
)
perpetrator_suicide_plot <- make_bar_chart(
  perpetrator_suicide_table,
  "Figure 2. Alcohol indicators where the perpetrator died by suicide",
  "Homicide followed by perpetrator suicide compared with other homicides"
)

write.csv(case_type_table,
  file.path(output_dir, "alcohol_by_homicide_case_type.csv"), row.names = FALSE)
write.csv(victim_suicide_table,
  file.path(output_dir, "alcohol_victim_suicide_by_case_type.csv"), row.names = FALSE)
write.csv(perpetrator_suicide_table,
  file.path(output_dir, "alcohol_by_perpetrator_suicide.csv"), row.names = FALSE)
write.csv(analysis_data[c(
  "incident_id", "underlying_case_type", "overlapping_case_type_flags",
  "victim_suicide", "homicide_suicide", names(measures)
)], file.path(output_dir, "incident_alcohol_case_types.csv"), row.names = FALSE)

ggplot2::ggsave(file.path(output_dir, "alcohol_by_homicide_case_type.png"),
  case_type_plot, width = 12, height = 7, dpi = 300, bg = "white")
ggplot2::ggsave(file.path(output_dir, "alcohol_by_perpetrator_suicide.png"),
  perpetrator_suicide_plot, width = 11, height = 5.5, dpi = 300, bg = "white")

message("Case-type analysis complete for ", nrow(analysis_data),
  " linked single-victim incidents.")
