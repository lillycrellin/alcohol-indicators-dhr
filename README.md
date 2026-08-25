# Recorded alcohol vulnerability indicators in Domestic Homicide Reviews

This repository contains the data and R code used to calculate the prevalence of recorded victim and perpetrator alcohol vulnerability indicators among **619 single-victim incidents** in the Domestic Homicide Review Dataset (DHRD) for England and Wales.

## Results

| Recorded indicator | n/N | % |
|---|---:|---:|
| Any victim or perpetrator indicator | 356/619 | 57.5 |
| Victim only | 62/619 | 10.0 |
| Perpetrator only | 134/619 | 21.6 |
| Both victim and perpetrator | 160/619 | 25.8 |
| Neither victim nor perpetrator | 263/619 | 42.5 |

Across the overlapping party-level totals, a victim indicator was recorded in 222 incidents (35.9%) and a perpetrator indicator in 294 incidents (47.5%). The victim total is 62 victim-only incidents plus 160 incidents with both indicators; the perpetrator total is 134 perpetrator-only incidents plus the same 160 incidents with both indicators.

These figures describe **indicators recorded in the Home Office metadata**. They do not establish that alcohol caused or was directly involved in 57.5% of the homicides, and they are not estimates of alcohol abuse or dependence in the wider domestic-homicide population.

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

1. excludes the 28 incidents flagged as involving multiple victims;
2. links incident, victim, and perpetrator records using `incident_id`;
3. uses `victim_vuln_alcohol` and `perpetrator_vuln_alcohol` as the recorded indicators;
4. checks that every included incident has one linked victim and perpetrator record and no missing indicator value; and
5. writes the summary, cross-tabulation, and incident-level analysis file to `data/derived/`.

The mutually exclusive cross-tabulation is:

| | Perpetrator: no | Perpetrator: yes |
|---|---:|---:|
| **Victim: no** | 263 (neither) | 134 (perpetrator only) |
| **Victim: yes** | 62 (victim only) | 160 (both) |

## Data source and citation

Cook, D., & Cook, E. A. (2026). *The Domestic Homicide Review Dataset (DHRD) for England and Wales* (Version 1.0.3) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.21648010

The source dataset contains structured data derived from publicly available Home Office metadata associated with Domestic Homicide Review reports for England and Wales. It covers 647 reports made available by the Home Office between December 2022 and March 2026. See `data/raw/CODEBOOK.md` for variable definitions.

## Licence

The source dataset is licensed under the [Creative Commons Attribution 4.0 International Licence](https://creativecommons.org/licenses/by/4.0/). The licence text is included in `LICENSE`.
