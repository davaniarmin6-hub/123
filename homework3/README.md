# Homework 3 — Wolfcamp variogram models and likelihood kriging

- `Homework_3_Wolfcamp.Rmd`: analysis code and student-style report.
- `Homework_3_Wolfcamp.pdf`: compiled report with code, results and plots.
- `Homework_3_Wolfcamp_bundle.zip`: all files together.
- `Build_Homework_3.R`: starter for an R installation without the required packages.

The files are in `homework3` on the repository's **work** branch. On GitHub, open a file and choose **Download raw file**, or download and extract the bundle.

With R and RStudio installed, open the Rmd and knit to PDF. Missing packages and TinyTeX (if needed) are installed automatically. If even `knitr` and `rmarkdown` are missing, open `Build_Homework_3.R` and click **Source** first. If a file-selection window appears, select `Homework_3_Wolfcamp.Rmd`. An Rmd cannot install its rendering engine before that engine starts, so the starter handles this first step.

Internet access is needed for installation. Packages are installed into a user library rather than the system library. Windows and macOS normally use CRAN binaries; Linux can require additional build tools. Installation on a separate clean PC has not been tested. Once dependencies are available, the data are loaded locally from `geoR`; no separate data download is needed.

The report has no running instructions inside it. Figures are embedded in the report, and the analysis does not export separate plot or CSV files. The main result objects are `selection`, `cv_scores` and `grid`.

The analysis compares Gaussian ML fits for three trends and four covariance specifications. It favours fewer parameters among models within two AIC units, checks predictions with model selection repeated inside five training folds, and distinguishes the smooth-head prediction target from a new observed head. The prompt, recorded AI response and contribution disclosure are included.
