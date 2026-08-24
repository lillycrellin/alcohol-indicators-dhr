# Recorded alcohol vulnerability indicators in Domestic Homicide Reviews

This repository contains the data and R code used to calculate the prevalence of recorded victim and perpetrator alcohol vulnerability indicators among **619 single-victim incidents** in the Domestic Homicide Review Dataset (DHRD) for England and Wales.

## Repository contents

```text
.
├── R/
│   └── alcohol_indicator_estimates.R
├── data/
│   ├── raw/
│   │   ├── incidents.csv
│   │   ├── victims.csv
│   │   ├── perpetrators.csv
│   │   └── CODEBOOK.md
│   └── derived/
│       ├── alcohol_indicator_summary.csv
│       ├── alcohol_indicator_crosstab.csv
│       └── incident_alcohol_indicators.csv
├── CITATION.cff
├── LICENSE
└── README.md
```

The three files in `data/raw/` are unchanged source-data files. The files in `data/derived/` are produced by the R script.

## Reproduce the analysis

The analysis uses base R and requires no additional packages. From the repository root, run:

```r
source("R/alcohol_indicator_estimates.R")
```

The script:

1. excludes 28 incidents that have been flagged as involving multiple victims;
2. links incident, victim, and perpetrator records using `incident_id`;
3. uses `victim_vuln_alcohol` and `perpetrator_vuln_alcohol` as the recorded indicators;
4. checks that every included incident has one linked victim and perpetrator record and no missing indicator value; and
5. writes the summary, cross-tabulation, and incident-level analysis file to `data/derived/`.


## Data source and citation

Cook, D., & Cook, E. A. (2026). *The Domestic Homicide Review Dataset (DHRD) for England and Wales* (Version 1.0.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.21108268

The source dataset contains structured data derived from publicly available Home Office metadata associated with Domestic Homicide Review reports for England and Wales. It covers 647 reports made available by the Home Office between December 2022 and March 2026. See `data/raw/CODEBOOK.md` for variable definitions.

## Licence

The source dataset is licensed under the [Creative Commons Attribution 4.0 International Licence](https://creativecommons.org/licenses/by/4.0/). The licence text is included in `LICENSE`.
