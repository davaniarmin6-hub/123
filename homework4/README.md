# Homework 4 — Rainfall in 1970, maximum-likelihood kriging

This revision follows the professor's feedback and analyses **1970 only**, the year used in Homework 2. The full analysis is rerun from the original data: exploration of trend and Gaussianity, 12 candidate models, five-fold cross-validation, variogram and residual diagnostics, grid predictions, and approximate pointwise 95% prediction intervals. No previous analysis cache is read.

Files:

- `Homework_4_Rainfall.Rmd`: complete code and focused student-style report.
- `Homework_4_Rainfall.pdf`: compiled report with code, results and plots.
- `Build_Homework_4.R`: installs missing R packages and compiles the PDF.
- `data/RainData.RData`: unchanged supplied data, matching land grid and outlines; the Rmd immediately selects 1970 for analysis.
- `Homework_4_Rainfall_bundle.zip`: all five files together.

Download and extract the ZIP, keeping the folder structure. With R and RStudio installed, open `Build_Homework_4.R` and click **Source**, or knit the Rmd if `knitr` and `rmarkdown` are already installed. If the starter opens a file-selection window, choose `Homework_4_Rainfall.Rmd`. Missing packages are installed into a user library; TinyTeX is installed if the required LaTeX engine is missing. Internet access is needed for installation. Linux can require additional system build tools. Installation on a separate empty computer has not been tested.

Every knit recomputes the 1970 analysis, including all cross-validation fits. There is no parallel or multi-year loop and caching is disabled. The run takes a few minutes depending on the computer. Plots are embedded in the report; the analysis does not export separate plot or CSV files.

All 189 stations remain in the analysis. Station 4367 is assigned to Calabria; stations 4085 and 4086 are assigned to Basilicata. The prediction grid contains 1,005 points and is the `grid` object inside `RainData.RData`. The unrelated marine `AllGrids.RData` file is not needed.

The mean 95% Interval Score is the primary predictive selection criterion, with RMSE breaking exact ties. The report also gives RMSE, interval coverage, mean width and bias, and explains the limits of using selection folds for assessment. All scores and mapped results are on the original rainfall scale.

This is a maximum-likelihood analysis. Its intervals are approximate prediction intervals with covariance parameters treated as fixed. A short clarification distinguishes these from Bayesian credible intervals for parameters and posterior predictive intervals for unobserved values. No Bayesian posterior is fitted.

GitHub location: **work** branch, **homework4** folder.
