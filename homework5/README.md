# Homework 5 — Bayesian rainfall prediction, 1970

The report follows the revised Homework 4: **1970 only**, 189 stations,
elevation as the trend, log rainfall and spherical residual covariance.
All three stations with corrected regional labels remain in the data.
The supplied rainfall file also contains the matching 1,005-point land grid.

## Files

- `Homework_5_Rainfall.Rmd`: complete analysis, visible R code and discussion.
- `Homework_5_Rainfall.pdf`: compiled report with computed results and maps.
- `Build_Homework_5.R`: installs missing R dependencies and compiles the PDF.
- `data/RainData.RData`: original supplied observations, grid and outlines.
- `README.md`: file guide and reproduction notes.
- `Homework_5_Rainfall_bundle.zip`: all five files above in one folder.

## Reproduce

Download and extract the ZIP, keeping the `data` subfolder. Open
`Build_Homework_5.R` in RStudio and source it. If needed, the file chooser asks
for `Homework_5_Rainfall.Rmd`. Alternatively, knit the Rmd after the required
rendering packages are available.

R must already be installed. The starter installs missing R packages into
a user library and TinyTeX if `xelatex` is unavailable. Package/TeX downloads
need internet access and a writable user library. RStudio supplies Pandoc;
when using plain R outside RStudio, install Pandoc separately. On systems
without package binaries, compiling packages may require system build tools.
The PDF can be read without installing R or any package.

The first run takes several minutes. Calculation chunks are cached locally;
the cache is not included in the download. Delete `Homework_5_cache` to force
a complete rerun. The cache key includes the data checksum, analysis functions
and geoR version. Plots are embedded in the report; there are no separate
user-facing image exports.

## What is compared

Both methods refit the same fixed model structure within the same five
training folds used in Homework 4. The Bayesian model uses a flat trend prior,
a proper scaled inverse-chi-squared variance prior, a discrete exponential
range prior and a discrete uniform relative-nugget prior. It integrates
parameter uncertainty and includes the nugget when predicting observations.

The main comparison is the **95% Interval Score** on held-out rainfall.
Coverage and width accompany it. Both point forecasts are **predictive medians**,
assessed using MAE. Homework 4 used likelihood predictive means; its original
mean-based RMSE is reproduced as a check, but is not compared to a Bayesian
median's RMSE. The conjugate log-scale Bayesian model has well-defined rainfall
quantiles but no finite arithmetic rainfall mean. The report explains this
limitation rather than averaging back-transformed draws.

Parameter intervals are **credible intervals**. Intervals for new rainfall
values are **posterior predictive intervals**. Both are central equal-tailed
95% intervals; map intervals are pointwise, not simultaneous. The report
includes parameter-grid and prior sensitivity checks and a simulation
stability check. This is direct posterior simulation on a covariance grid,
not MCMC.

The covariance family and trend were selected in Homework 4. This comparison
is conditional on that structure and uses one random five-fold split; it is
not a new independent assessment of the earlier selection process. The report
makes no claim that Bayesian kriging is universally better.

## Revision after the range-prior feedback

The 22 November revision retains the main prior and explains it in terms of
actual residual correlations, rather than relying on the 610 km grid cutoff.
It adds the study-area distances, the spherical half-correlation distance,
and posterior correlation and covariance summaries at 50, 100 and 150 km.
The calculations keep each draw's range, sill and nugget together.

The former wider-prior check is replaced by a shorter-range prior with an
exponential scale of 75 km. It is a full-data sensitivity check, not a new
validation comparison. The report explicitly shows that long-distance
correlation is prior-sensitive. The main prior, model, validation predictions
and maps are unchanged. No years, covariance families or validation schemes
were added. The report's wording has also been shortened and simplified.
