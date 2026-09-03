# Recorded alcohol vulnerability indicators in Domestic Homicide Reviews

This repository contains the data and R code used to calculate the prevalence of recorded victim and perpetrator alcohol vulnerability indicators among **619 single-victim incidents** in the Domestic Homicide Review Dataset (DHRD) for England and Wales.

## Repository contents

```text
.
├── R/
│   ├── alcohol_indicator_estimates.R
│   └── alcohol_indicators_by_case_type.R
├── data/
│   ├── raw/
│   │   ├── incidents.csv
│   │   ├── victims.csv
│   │   ├── perpetrators.csv
│   │   └── CODEBOOK.md
│   └── derived/
│       ├── alcohol_indicator_summary.csv
│       ├── alcohol_indicator_crosstab.csv
│       ├── incident_alcohol_indicators.csv
│       ├── alcohol_by_homicide_case_type.csv
│       ├── alcohol_victim_suicide_by_case_type.csv
│       ├── alcohol_by_perpetrator_suicide.csv
│       ├── incident_alcohol_case_types.csv
│       ├── alcohol_by_homicide_case_type.png
│       └── alcohol_by_perpetrator_suicide.png
├── CITATION.cff
├── LICENSE
└── README.md
```

The three files in `data/raw/` are unchanged source-data files. The files in
`data/derived/` are produced by the R scripts.

## Reproduce the analysis

The overall indicator analysis uses base R. The case-type analysis also requires
`ggplot2` to generate its figures. From the repository root, run:

```r
source("R/alcohol_indicator_estimates.R")
source("R/alcohol_indicators_by_case_type.R")
```

The script:

1. excludes the 28 incidents flagged as involving multiple victims;
2. links incident, victim, and perpetrator records using `incident_id`;
3. uses `victim_vuln_alcohol` and `perpetrator_vuln_alcohol` as the recorded indicators;
4. checks that every included incident has one linked victim and perpetrator record and no missing indicator value; and
5. writes the summary, cross-tabulation, and incident-level analysis file to `data/derived/`.

The additional case-type script compares victim, perpetrator and both-person
alcohol indicators across homicide case types, victim-suicide classifications,
and the overlapping `homicide_suicide` incident flag. It documents the handling
of overlapping case-type flags directly in the code and writes tables and
figures to `data/derived/`.

## Data source and citation

Cook, D., & Cook, E. A. (2026). *The Domestic Homicide Review Dataset (DHRD) for England and Wales* (Version 1.0.3) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.21648010

The source dataset contains structured data derived from publicly available Home Office metadata associated with Domestic Homicide Review reports for England and Wales. It covers 647 reports made available by the Home Office between December 2022 and March 2026. See `data/raw/CODEBOOK.md` for variable definitions.

## Licence

The source dataset is licensed under the [Creative Commons Attribution 4.0 International Licence](https://creativecommons.org/licenses/by/4.0/). The licence text is included in `LICENSE`.
