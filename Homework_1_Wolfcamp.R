# ============================================================================
# Spatial statistics 2026-2027
# Professor: Dr. Lasinio
# Student: Mojtaba Alinejad
# HOMEWORK 1 | WOLFCAMP DATA | PARTS 1 AND 2
# ============================================================================
#
# This file contains my prompts, code, results and discussion together.
# Checked with R 4.5.0, geoR 1.9-6, gstat 2.1-6, MBA 0.1-3 and sp 2.2-0.
# The cross-validation loops can take a few minutes to finish.
# In RStudio, the figures appear in the Plots pane. Use its Previous arrow
# to see earlier figures; none of the figures is saved as an image file.
#
# CONTENTS
# Part 1: Bad/good prompts, exploratory analysis, results and discussion.
# Part 2A: A function for choosing the IDW power p.
# Part 2B: Prediction scores, a 20 x 20 grid, maps and discussion.
#
# DATA
# Wolfcamp contains 85 piezometric-head measurements from an aquifer in Texas.
# The geoR documentation gives coordinates in km and heads in metres.
# These are continuous measurements at spatial locations, not longitude
# and latitude. I use ordinary Euclidean distances in these coordinates.
# Reference in R: help("wolfcamp", package = "geoR").
#
# ============================================================================
# PART 1 | HOW THE PROMPT CHANGES THE ANALYSIS
# ============================================================================

# BAD PROMPT:
# "Confirm that the Wolfcamp data are spatially dependent. Use R to draw
# a variogram and give me a yes-or-no answer."

# GOOD PROMPT:
# "Using wolfcamp from the geoR package in R, assess whether there is
# evidence of spatial structure in the measured piezometric heads.
# First inspect the data structure, sample size, missing values, duplicate
# locations, and coordinate/measurement units. Identify the spatial data
# type and justify an appropriate diagnostic rather than applying a list
# of methods automatically. Provide runnable R code, a map, and an empirical
# semivariogram with explicit distance bins and pair counts. Explain what
# patterns would and would not support spatial dependence. If you use a
# statistical comparison, state its null hypothesis and assumptions, and
# set a seed for reproducibility. Check whether a broad change in the mean
# across space could affect the raw-data interpretation; flag this
# limitation without requiring a full trend model. Report only numerical
# results actually calculated and conclude cautiously, distinguishing raw
# spatial structure from residual dependence."

required_packages <- c("geoR", "gstat", "MBA", "sp")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages) > 0) {
  stop("Please install these packages first: ",
       paste(missing_packages, collapse = ", "))
}
data("wolfcamp", package = "geoR")
out <- "homework1_results"
dir.create(out, showWarnings = FALSE)

# 1A. My analysis for the bad prompt ----------------------------------------
# The calculation is valid; the prompt's framing and requested conclusion
# are weak. A variogram by itself does not justify a definitive yes/no.
v_bad <- geoR::variog(wolfcamp, messages = FALSE)
par(mfrow = c(1, 1))
plot(v_bad, pch = 19, xlab = "Distance (km)",
     ylab = expression("Semivariance (" * m^2 * ")"),
     main = "Minimal analysis: raw Wolfcamp semivariogram")


# 1B. My analysis for the good prompt ---------------------------------------
# Source for units and description: help("wolfcamp", package = "geoR").
# These are continuous point-referenced measurements at fixed locations.
# Coordinates are in km; piezometric heads are in metres.
dat <- data.frame(x = wolfcamp$coords[, 1],
                  y = wolfcamp$coords[, 2], head = wolfcamp$data)
checks <- data.frame(
  observations = nrow(dat),
  missing_values = sum(is.na(dat)),
  duplicate_locations = sum(duplicated(dat[c("x", "y")]))
)
stopifnot(all(is.finite(as.matrix(dat))),
          checks$duplicate_locations == 0)
write.csv(checks, file.path(out, "data_checks.csv"), row.names = FALSE)
write.csv(dat, file.path(out, "wolfcamp_data.csv"), row.names = FALSE)

# Explore the spatial arrangement, distribution and possible mean trend.
quartile <- cut(dat$head, quantile(dat$head, seq(0, 1, 0.25)),
                include.lowest = TRUE, labels = FALSE)
palette <- c("#2166AC", "#67A9CF", "#FDAE61", "#B2182B")
par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3, 1))
plot(dat$x, dat$y, asp = 1, pch = 19, col = palette[quartile],
     xlab = "X coordinate (km)", ylab = "Y coordinate (km)",
     main = "Locations coloured by head quartile")
legend("topright", legend = c("Q1: lowest", "Q2", "Q3", "Q4: highest"),
       col = palette, pch = 19, cex = 0.75, bty = "n")
hist(dat$head, breaks = "FD", col = "#D9EAF1", border = "white",
     xlab = "Piezometric head (m)", main = "Head distribution")
plot(dat$x, dat$head, pch = 19, col = "#365A73",
     xlab = "X coordinate (km)", ylab = "Head (m)", main = "Head versus X")
lines(lowess(dat$x, dat$head), col = "#B2182B", lwd = 2)
plot(dat$y, dat$head, pch = 19, col = "#365A73",
     xlab = "Y coordinate (km)", ylab = "Head (m)", main = "Head versus Y")
lines(lowess(dat$y, dat$head), col = "#B2182B", lwd = 2)


# Explicit bins: 12 equal-width intervals up to half the maximum distance.
# Longer lags are omitted here because they are less local and can be
# sensitive to the sampling geometry. This is a diagnostic choice.
distance_matrix <- as.matrix(dist(dat[c("x", "y")]))
pairs <- which(lower.tri(distance_matrix), arr.ind = TRUE)
distance <- distance_matrix[pairs]
max_lag <- max(distance) / 2
v_good <- geoR::variog(wolfcamp,
                      breaks = seq(0, max_lag, length.out = 13),
                      max.dist = max_lag, messages = FALSE)
variogram_table <- data.frame(lag_km = v_good$u,
                             semivariance_m2 = v_good$v,
                             pairs = v_good$n)
write.csv(variogram_table, file.path(out, "variogram_bins.csv"),
          row.names = FALSE)

# Transparent permutation comparison for RAW spatial structure.
# H0: measured heads are exchangeable across the fixed locations.
# Statistic: mean semivariance among the closest 10% of all site pairs.
# This neighbourhood is defined by coordinates alone, before examining
# head differences. Small values indicate unusually similar neighbours.
near_cutoff <- unname(quantile(distance, 0.10))
near <- pairs[distance <= near_cutoff, , drop = FALSE]
near_semivariance <- function(z) {
  mean((z[near[, 1]] - z[near[, 2]])^2) / 2
}
observed <- near_semivariance(dat$head)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(2026)
B <- 9999
null_statistics <- replicate(B, near_semivariance(sample(dat$head)))
p_value <- (1 + sum(null_statistics <= observed)) / (B + 1)

results <- data.frame(
  n = nrow(dat), total_pairs = nrow(pairs),
  maximum_distance_km = max(distance), variogram_max_lag_km = max_lag,
  near_cutoff_km = near_cutoff, near_pairs = nrow(near),
  observed_near_semivariance_m2 = observed,
  permutation_mean_m2 = mean(null_statistics),
  sample_variance_m2 = var(dat$head),
  observed_to_permutation_mean = observed / mean(null_statistics),
  permutations = B, permutation_p_value = p_value
)
write.csv(results, file.path(out, "numerical_results.csv"), row.names = FALSE)
write.csv(data.frame(null_semivariance_m2 = null_statistics),
          file.path(out, "permutation_statistics.csv"), row.names = FALSE)

par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
plot(v_good, pch = 19, xlab = "Distance (km)",
     ylab = expression("Semivariance (" * m^2 * ")"),
     main = "Raw semivariogram: explicit bins",
     ylim = c(0, max(v_good$v) * 1.13))
text(v_good$u, v_good$v, labels = v_good$n, pos = 3, cex = 0.65)
mtext("Numbers above points are pair counts", side = 3, cex = 0.7)
hist(null_statistics, breaks = 35, col = "#D9EAF1", border = "white",
     xlim = range(c(observed, null_statistics)),
     xlab = expression("Nearby-pair semivariance (" * m^2 * ")"),
     main = "Randomly shuffled heads")
abline(v = observed, col = "#B2182B", lwd = 2)
legend("topleft", legend = sprintf("Observed = %.1f; p = %.4f", observed, p_value),
       col = "#B2182B", lwd = 2, bty = "n", cex = 0.8)


print(checks)
print(round(results, 6))
print(transform(variogram_table,
                lag_km = round(lag_km, 2),
                semivariance_m2 = round(semivariance_m2, 2)))
cat("\nInterpretation: assess raw spatial structure using the plots and\n",
    "permutation comparison together. A changing spatial mean violates\n",
    "exchangeability too, so this is NOT a test of residual dependence.\n",
    "No trend model has been fitted or removed in this exercise.\n")

# 1C. My results and discussion ---------------------------------------------
# I found 85 observations, with no missing values or duplicate locations.
# Both variograms rise with distance. In the explicit-bin variogram,
# semivariance increases from 1,563.74 m^2 in the first bin (centre 9.09 km)
# to 36,953.13 m^2 in the last bin (centre 209.02 km). Semivariance is half
# the average squared difference between the measurements in a distance bin.
# A rising pattern means that nearby measurements tend to be more similar.
# A flat pattern would offer less evidence of this relationship, but would
# not prove independence. Bin centres are not estimates of a correlation range.
#
# For the closest 10% of pairs, the distance cutoff is 53.92 km. These 357
# pairs have mean semivariance 2,429.51 m^2, compared with 34,724.07 m^2 after
# shuffling. My observed value is about 7% of the shuffled mean. None of the
# 9,999 permutations gave a value this small, so the corrected Monte Carlo
# p-value is 0.0001. This is the smallest possible value with this simulation,
# not a zero probability. I shuffled whole sets of heads, rather than
# treating overlapping pairs as independent observations.
#
# My bad prompt already suggests the answer by saying "confirm". Although
# its variogram is useful, the prompt encourages me to jump to a yes/no
# conclusion. My good prompt makes me check the data, explain my choices,
# and show how someone else can reproduce the result. The variograms use
# different bins and distance limits, so their individual values should
# not be compared as though the settings were identical.
#
# The map shows higher heads towards the southwest and lower heads towards
# the northeast. This broad trend can also produce the increasing variogram
# and the small permutation p-value. The shuffling comparison assumes that
# heads can be exchanged between locations under its null hypothesis; a
# changing mean also breaks that assumption. Pooling all directions into
# one variogram may also hide differences between directions.
#
# I conclude that the RAW data show strong spatial structure. I have not
# shown that dependence remains after removing the broad trend. The good
# prompt improves how I check and interpret the result; its advantage is
# not simply that it produces a longer answer.

# ============================================================================
# PART 2 | IDW AND MULTILEVEL B-SPLINES
# ============================================================================
# MY PROMPT FOR PART 2
# "Using the same Wolfcamp data, write clear R code for my homework.
# Build a function that chooses the IDW power p using gstat::idw and
# cross-validation. Compare tuned IDW with multilevel B-splines using
# predictions at the same held-out locations and RMSE in metres. Keep
# parameter selection inside the training data, so the held-out heads do
# not influence the choice of p. Use five outer folds for the comparison
# and leave-one-out cross-validation within each training set to choose p.
# Keep the B-spline settings fixed and state them. Then use all observations
# to make a 20 x 20 grid from the coordinate ranges. Use gstat::idw for IDW,
# MBA::mba.points for validation, and MBA::mba.surf for the grid. Explain
# why fitting errors or differences between the two maps are not proper
# measures of prediction accuracy. Include readable plots, the results
# actually calculated, and a short discussion in ordinary student language."
#
# MY APPROACH
# IDW is a weighted average, with weights proportional to distance^(-p).
# A larger p gives more weight to nearby observations. I keep all training
# observations as possible neighbours and choose p from 0.5 to 8 by 0.5.
# For B-splines I use n = 1, m = 1 and h = 8 (the package defaults).
# I set these choices before looking at the comparison scores.
#
# I cannot calculate prediction errors at the new grid points because I
# do not know their true heads. Instead, I hide observed values, predict
# at those locations, and compare predictions with the values I hid.
# My main score is RMSE = sqrt(mean((observed - predicted)^2)).
# A smaller RMSE is better; its unit is metres. I also report MAE in metres
# and mean error (predicted minus observed), where zero indicates no
# average overprediction or underprediction on these held-out observations.

# 2A. A function to choose the IDW power p -----------------------------------

# This short helper uses gstat's IDW, rather than reimplementing its weights.
predict_idw <- function(train, new_locations, p) {
  gstat::idw(
    head ~ 1, locations = ~ x + y, data = train,
    newdata = new_locations, idp = p, nmax = Inf, debug.level = 0
  )$var1.pred
}

# For each candidate p, leave out one observation at a time and predict it
# from the others. Choose the p with the smallest leave-one-out RMSE.
# The returned table lets me inspect the whole curve, not just its minimum.
choose_idw_p <- function(data, p_values = seq(0.5, 8, by = 0.5)) {
  stopifnot(nrow(data) >= 3, all(is.finite(p_values)), all(p_values > 0))
  cv_rmse <- numeric(length(p_values))

  for (j in seq_along(p_values)) {
    predictions <- numeric(nrow(data))

    for (i in seq_len(nrow(data))) {
      predictions[i] <- predict_idw(
        train = data[-i, ],
        new_locations = data[i, c("x", "y"), drop = FALSE],
        p = p_values[j]
      )
    }

    stopifnot(all(is.finite(predictions)))
    cv_rmse[j] <- sqrt(mean((data$head - predictions)^2))
  }

  list(
    best_p = p_values[which.min(cv_rmse)],
    scores = data.frame(p = p_values, RMSE_m = cv_rmse)
  )
}

# 2B. Compare predictions on the same held-out locations ---------------------
# I use five balanced groups of 17 locations. For each group, I choose p
# using only the other 68 measurements, then predict the hidden group.
# This is nested cross-validation: the inner loop chooses p and the outer
# loop checks predictions. Each measurement is scored once in the outer loop.
# Random folds assess prediction among this sampling network. They do not
# establish performance in a distant or completely unsampled region.

set.seed(2026)
fold <- sample(rep(1:5, length.out = nrow(dat)))
cv_idw <- cv_mba <- numeric(nrow(dat))
selected_p <- numeric(5)
outside_training_hull <- logical(nrow(dat))
mba_h <- 8

for (k in 1:5) {
  test_rows <- which(fold == k)
  train <- dat[-test_rows, ]
  test_xy <- dat[test_rows, c("x", "y")]

  message("Part 2: evaluating held-out group ", k, " of 5")
  tuning <- choose_idw_p(train)
  selected_p[k] <- tuning$best_p
  cv_idw[test_rows] <- predict_idw(train, test_xy, tuning$best_p)
  cv_mba[test_rows] <- MBA::mba.points(
    xyz = train[, c("x", "y", "head")], xy.est = test_xy,
    n = 1, m = 1, h = mba_h, extend = TRUE, verbose = FALSE
  )$xyz.est[, 3]

  # Some hidden sites can lie beyond the training sites' convex hull.
  # I keep them for both methods and count them, instead of dropping them.
  hull <- chull(train$x, train$y)
  outside_training_hull[test_rows] <- sp::point.in.polygon(
    test_xy$x, test_xy$y, train$x[hull], train$y[hull]
  ) == 0
}

# extend = TRUE allows MBA to include boundary test coordinates in its
# domain. It does not supply the hidden head values to the fitted surface.
stopifnot(all(is.finite(cv_idw)), all(is.finite(cv_mba)))
scores <- data.frame(
  Method = c("IDW (p chosen within training data)", "MBA (h = 8)"),
  RMSE_m = c(sqrt(mean((cv_idw - dat$head)^2)),
             sqrt(mean((cv_mba - dat$head)^2))),
  MAE_m = c(mean(abs(cv_idw - dat$head)), mean(abs(cv_mba - dat$head))),
  Mean_error_m = c(mean(cv_idw - dat$head), mean(cv_mba - dat$head))
)
fold_results <- data.frame(fold = 1:5, selected_p = selected_p)
cv_predictions <- data.frame(
  dat, fold = fold, IDW = cv_idw, MBA = cv_mba,
  outside_training_hull = outside_training_hull
)
write.csv(scores, file.path(out, "part2_prediction_scores.csv"), row.names = FALSE)
write.csv(fold_results, file.path(out, "part2_power_by_fold.csv"), row.names = FALSE)
write.csv(cv_predictions, file.path(out, "part2_held_out_predictions.csv"),
          row.names = FALSE)

# 2C. Interpolate on a 20 x 20 grid using all observations -------------------
# Now that the comparison is complete, I choose p again using all 85 sites.
# This final p is used for the map. Its tuning RMSE is not substituted for
# the outer cross-validation score reported above.

message("Part 2: choosing the final power for the grid")
final_tuning <- choose_idw_p(dat)
best_p <- final_tuning$best_p
write.csv(final_tuning$scores, file.path(out, "part2_idw_power_tuning.csv"),
          row.names = FALSE)

grid_x <- seq(min(dat$x), max(dat$x), length.out = 20)
grid_y <- seq(min(dat$y), max(dat$y), length.out = 20)
grid <- expand.grid(x = grid_x, y = grid_y)
grid$IDW <- predict_idw(dat, grid[, c("x", "y")], best_p)

mba_surface <- MBA::mba.surf(
  xyz = dat[, c("x", "y", "head")], no.X = 20, no.Y = 20,
  n = 1, m = 1, h = mba_h, extend = TRUE
)$xyz.est

# Check that the two methods really use the same coordinates and ordering.
stopifnot(
  isTRUE(all.equal(grid_x, mba_surface$x, check.attributes = FALSE)),
  isTRUE(all.equal(grid_y, mba_surface$y, check.attributes = FALSE))
)
grid$MBA <- as.vector(mba_surface$z)

# I also check mba.points against mba.surf on these same grid coordinates.
mba_grid_check <- MBA::mba.points(
  dat[, c("x", "y", "head")], grid[, c("x", "y")],
  n = 1, m = 1, h = mba_h, extend = TRUE, verbose = FALSE
)$xyz.est[, 3]
stopifnot(nrow(grid) == 400, all(is.finite(grid$IDW)),
          all(is.finite(grid$MBA)),
          max(abs(grid$MBA - mba_grid_check)) < 1e-6)

hull <- chull(dat$x, dat$y)
hull <- c(hull, hull[1])
grid$inside_hull <- sp::point.in.polygon(
  grid$x, grid$y, dat$x[hull], dat$y[hull]
) > 0
write.csv(grid, file.path(out, "part2_grid_20x20.csv"), row.names = FALSE)

# The rectangle includes locations outside the observation convex hull.
# I show all 400 predictions as requested and mark the hull on the maps.
# Predictions outside it are extrapolations and deserve more caution.

# 2D. Figures ---------------------------------------------------------------
# Both maps use the SAME colour scale, so their colours can be compared.
map_colours <- hcl.colors(100, "YlOrRd", rev = TRUE)
colour_range <- range(grid$IDW, grid$MBA)
layout(matrix(1:3, nrow = 1), widths = c(1, 1, 0.4))
par(mar = c(4.5, 4.2, 3.5, 1))
for (method in c("IDW", "MBA")) {
  image(grid_x, grid_y, matrix(grid[[method]], nrow = 20),
        col = map_colours, zlim = colour_range, asp = 1,
        xlab = "X coordinate (km)", ylab = "Y coordinate (km)",
        main = if (method == "IDW") paste("IDW: p =", best_p)
               else paste("Multilevel B-splines: h =", mba_h))
  points(dat$x, dat$y, pch = 21, bg = "white", cex = 0.45)
  lines(dat$x[hull], dat$y[hull], lty = 2)
  mtext("20 x 20 grid; dashed line = observation hull", side = 3, cex = 0.65)
}
par(mar = c(3, 0.5, 2, 2.5))
colour_levels <- seq(colour_range[1], colour_range[2], length.out = 100)
image(c(0, 1), colour_levels, matrix(rep(colour_levels, each = 2), nrow = 2),
      col = map_colours, axes = FALSE, xlab = "", ylab = "")
axis(4, las = 1, cex.axis = 0.8)
mtext("Head (m)", side = 3, cex = 0.8)


par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
plot(final_tuning$scores, type = "b", pch = 19,
     xlab = "IDW power p", ylab = "Leave-one-out RMSE (m)",
     main = "Choose p for the final map")
abline(v = best_p, col = "#B2182B", lty = 2)
prediction_range <- range(dat$head, cv_idw, cv_mba)
plot(dat$head, cv_idw, pch = 16, col = "#2166AC",
     xlim = prediction_range, ylim = prediction_range, asp = 1,
     xlab = "Observed head (m)", ylab = "Held-out prediction (m)",
     main = "Predictions checked on hidden values")
points(dat$head, cv_mba, pch = 17, col = "#B2182B")
abline(0, 1, lty = 2)
legend("topleft", legend = c("IDW", "Multilevel B-splines"),
       col = c("#2166AC", "#B2182B"), pch = c(16, 17), bty = "n")


# 2E. Numerical results -----------------------------------------------------
cat("\nPART 2: RESULTS\n")
print(fold_results, row.names = FALSE)
print(scores, row.names = FALSE, digits = 5)
cat("Final IDW power for the 20 x 20 map:", best_p, "\n")
cat("Minimum full-data tuning RMSE:", min(final_tuning$scores$RMSE_m), "m\n")
cat("Held-out locations outside their training hull:",
    sum(outside_training_hull), "of", nrow(dat), "\n")
cat("Grid predictions outside the observation hull:",
    sum(!grid$inside_hull), "of", nrow(grid), "\n")
capture.output(sessionInfo(), file = file.path(out, "sessionInfo.txt"))

# 2F. My results and discussion ---------------------------------------------
# These are the results from the code above, rounded to two decimal places.
#
# Choosing p using all observations, for the final map:
#   Best candidate p:                  4.00
#   Leave-one-out RMSE at p = 4:       65.11 m
#   Leave-one-out RMSE at p = 2:       75.01 m
#
# Comparing predictions in the FIVE OUTER FOLDS:
#   Method                    RMSE (m)      MAE (m)      Mean error (m)
#   IDW, p tuned in training     65.85        49.47            -15.25
#   Multilevel B-splines         61.57        47.38            -11.50
#
# The powers chosen within folds 1 to 5 were 5, 3.5, 3.5, 5 and 4.
# These scores use all 85 held-out predictions. I pooled their errors before
# calculating RMSE, rather than averaging the five fold RMSEs.
#
# WHAT I LEARNED ABOUT p
# My function chose p = 4 from the candidate values. This agrees with the
# lowest point of the tuning curve. Small powers performed worse because
# distant observations received more weight. However, making p larger and
# larger did not keep improving the result. The curve is quite flat around
# its minimum: p = 3.5 gave RMSE 65.17 m, very close to 65.11 m for p = 4.
# I would therefore describe 4 as the best value among those I checked,
# not as a precisely known or universally optimal power.
#
# WHAT I LEARNED FROM THE METHOD COMPARISON
# B-splines gave the lower held-out RMSE: 61.57 m compared with 65.85 m for
# IDW. This is a reduction of about 4.29 m, or 6.5%. The MAE also favoured
# B-splines, although the difference was small. Both mean errors were
# negative, so both methods underpredicted on average in this comparison.
#
# I kept the final-map tuning score (65.11 m) separate from IDW's comparison
# score (65.85 m). The first helped choose p using all the data. The second
# came from hidden observations that were not used to choose their p.
# Comparing the minimum tuning score directly with the B-spline score
# would give IDW an advantage from selecting its best result on those data.
#
# WHAT I LEARNED FROM THE MAPS
# Both methods reproduce the main pattern: higher heads in the southwest
# and lower heads in the northeast. Their local predictions differ, but
# a visually smoother surface is not automatically more accurate. I used
# held-out prediction errors, rather than appearance or differences between
# the maps, to decide which method performed better in this experiment.
# I also avoided judging accuracy from predictions at the fitting sites:
# an interpolator can reproduce those values and still predict poorly at
# new locations.
#
# LIMITATIONS AND MY CONCLUSION
# The 20 x 20 grid has 400 locations. Of these, 140 lie outside the convex
# hull of the observed sites, so those map values are extrapolations.
# Eleven held-out sites were also outside their training set's hull. I kept
# those sites in the comparison for both methods; the scores therefore
# include some boundary extrapolation as well as interpolation.
#
# My folds are random, so nearby training and test sites can occur. This
# evaluates prediction within the existing network, not prediction across
# large unsampled gaps. Spatially separated folds would address that other
# question. A different split may also change the numerical comparison.
#
# I used the default B-spline settings, including h = 8, without tuning h.
# Therefore, this compares tuned IDW with that particular B-spline setup.
# I have not shown that the difference is statistically significant or
# that either method supplies reliable prediction uncertainty.
#
# For this experiment, I would prefer the B-spline predictions because
# both RMSE and MAE were lower. IDW with p = 4 remains a straightforward
# alternative and captures the broad spatial pattern well. The main
# lesson for me is to choose settings using training data and compare
# methods using values that were hidden from fitting and tuning.
#
# END OF HOMEWORK 1 ---------------------------------------------------------

