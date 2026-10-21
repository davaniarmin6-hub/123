report <- "Homework_2_Rainfall.Rmd"
if (!file.exists(report)) report <- file.choose()
report <- normalizePath(report, mustWork = TRUE)
stopifnot(grepl("\\.Rmd$", report, ignore.case = TRUE))
setwd(dirname(report))
stopifnot(file.exists("data/RainData.RData"),
          file.exists("data/AllGrids.RData"))

options(repos = c(CRAN = "https://cloud.r-project.org"))
r_series <- paste(R.version$major,
                  strsplit(R.version$minor, ".", fixed = TRUE)[[1]][1],
                  sep = ".")
user_library <- file.path(tools::R_user_dir("Homework2", "data"), r_series)
dir.create(user_library, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user_library, .libPaths()))
needed <- c("gstat", "sp", "knitr", "rmarkdown", "tinytex")
missing <- needed[!vapply(needed, requireNamespace, logical(1),
                          quietly = TRUE)]
if (length(missing) > 0) {
  install.packages(missing, lib = user_library)
}
unavailable <- needed[!vapply(needed, requireNamespace, logical(1),
                              quietly = TRUE)]
if (length(unavailable) > 0) {
  stop("Package installation failed: ", paste(unavailable, collapse = ", "))
}
if (!nzchar(Sys.which("xelatex"))) tinytex::install_tinytex()
rmarkdown::render(report, output_format = "pdf_document")
