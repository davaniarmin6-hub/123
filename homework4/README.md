# Homework 4 — Annual rainfall, maximum-likelihood kriging

The report analyses **all 13 years (1970–1982)** separately. It contains the R code, model choices, cross-validation scores, pointwise 95% prediction intervals, yearly maps, and an AI-assistance paragraph.

Files:

- `Homework_4_Rainfall.Rmd`: editable report and complete analysis code.
- `Homework_4_Rainfall.pdf`: compiled report, including code and plots.
- `Build_Homework_4.R`: starter for installing missing R packages and compiling the PDF.
- `data/RainData.RData`: the supplied rainfall observations, matching land grid, and outlines.
- `Homework_4_Rainfall_bundle.zip`: the report, PDF, starter, this README, and data together.

Download and extract the ZIP, keeping its folder structure. With R and RStudio installed, open `Build_Homework_4.R` and click **Source**, or knit the Rmd directly if `rmarkdown` and `knitr` are already available. If the starter asks you to select a file, choose `Homework_4_Rainfall.Rmd`. Packages are installed in a user library. TinyTeX is installed if a LaTeX engine is missing. Internet access is required for installation. On Linux, some packages may also require system build dependencies. This has not been tested on a separate empty PC.

The first run fits many spatial models and can take around 15–25 minutes or longer, depending on the computer. On Unix-like systems the yearly loop uses four worker processes; on Windows it uses a sequential loop. Each year has its own fixed seed, so this does not change the statistical procedure. The expensive annual analysis is cached by knitr; the cache key includes the input data checksum, candidates, modelling functions, and geoR version. Delete `Homework_4_cache` to force recomputation. The submitted PDF was compiled from an actual run. No separate plot-image or CSV exports are required by the analysis.

The matching prediction grid is `grid` inside `RainData.RData`. The previously supplied `AllGrids.RData` contains unrelated marine data and is not included. The original data file is unchanged: the report corrects station 4367 to Calabria and stations 4085 and 4086 to Basilicata in memory, keeping all observations.

There are 12 candidates for each year: raw/log response, elevation/elevation plus coordinates, and exponential/spherical/Matérn 1.5 covariance. Gaussian maximum likelihood estimates parameters. Lowest mean five-fold central 95% interval score selects the candidate, with RMSE breaking exact ties. RMSE, coverage, width, and bias describe the trade-off between mean prediction and interval quality. The model-selection scores are not presented as independent nested-validation estimates. All scores and maps are on the original rainfall scale.

The intervals target annual rainfall at an unobserved station-like location, including the nugget. They are approximate pointwise prediction intervals, with fitted covariance parameters treated as fixed. Grid points outside the station hull or observed elevation range are marked. The report distinguishes this from a smooth latent-surface interval and from a simultaneous or Bayesian interval.

The GitHub location is the repository's **work** branch, folder **homework4**.
