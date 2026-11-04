# Homework 3 — Wolfcamp variogram models and likelihood kriging

- `Homework_3_Wolfcamp.Rmd`: analysis code and student-style report.
- `Homework_3_Wolfcamp.pdf`: compiled report with code, results and plots.
- `Homework_3_Wolfcamp_bundle.zip`: all files together.
- `Build_Homework_3.R`: starter for an R installation without the required packages.

The files are in `homework3` on the repository's **work** branch. On GitHub, open a file and choose **Download raw file**, or download and extract the bundle.

With R and RStudio installed, open the Rmd and knit to PDF. Missing packages and TinyTeX (if needed) are installed automatically. If even `knitr` and `rmarkdown` are missing, open `Build_Homework_3.R` and click **Source** first. If a file-selection window appears, select `Homework_3_Wolfcamp.Rmd`. An Rmd cannot install its rendering engine before that engine starts, so the starter handles this first step.

Internet access is needed for installation. Packages are installed into a user library rather than the system library. Windows and macOS normally use CRAN binaries; Linux can require additional build tools. Installation on a separate clean PC has not been tested. Once dependencies are available, the data are loaded locally from `geoR`; no separate data download is needed.

The report has no running instructions inside it. Figures are embedded in the report, and the analysis does not export separate plot or CSV files. The main result objects are `selection`, `cv_scores` and `grid`.

Based on the professor's feedback, the revised analysis compares three trends and four covariance specifications using the same five-fold cross-validation split. The lowest pooled RMSE selects the model, with MAE breaking exact ties. Gaussian ML still estimates the parameters; AIC is supporting evidence and does not filter or select candidates.

A separate nested five-fold assessment repeats this predictive comparison inside each outer training set. It distinguishes the model-selection score from the outer assessment score, and the smooth-head prediction target from a new observed head. This takes longer than the original AIC-based comparison. Failed or nonconverged optimizer starts are counted; the analysis stops if a candidate has no converged fit.

The revision uses the student's latest uploaded Rmd as its starting point. The original AI exchange is retained as historical material, with a new revision prompt, response and assessment explaining the corrected selection procedure.
