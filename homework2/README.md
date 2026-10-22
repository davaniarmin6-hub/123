# Homework 2 — Rainfall, 1970

- **Read the report:** open `Homework_2_Rainfall.pdf`.
- **Read or run the code:** open `Homework_2_Rainfall.Rmd` in RStudio.
- **Download everything:** download `Homework_2_Rainfall_bundle.zip` and extract it. Keep the `data` folder beside the Rmd file.

On GitHub, open the file and use **Download raw file**. Alternatively, use the repository's **Code → Download ZIP** option and open its `homework2` folder. These files are on the **work** branch.

With R and RStudio installed, the Rmd automatically installs missing analysis packages and TinyTeX if PDF compilation needs it. An Internet connection is needed for downloads. Packages go into a user library, so the code does not need to write into the system R library.

If even `rmarkdown` and `knitr` are missing, open `Build_Homework_2.R` and click **Source** first. It installs the packages, prepares PDF compilation, and builds the report. If a file-selection window appears, select `Homework_2_Rainfall.Rmd`. An Rmd cannot install its own rendering engine before that engine starts, which is why this small starter is included. The report itself contains no running instructions.

Subsequent runs can use **Knit to PDF** in RStudio. The cross-validation loops take a few minutes. Windows and macOS normally use CRAN binary packages; Linux may also need system libraries for packages such as `sf`. Automatic downloads depend on network access and a supported R version. Installation on a separate clean PC has not been tested.

The Rmd contains the code, plots, calculated results, explanations, weak/good prompts, recorded AI responses, and contribution disclosure. Figures appear in the compiled report; the analysis does not export separate plots or tables. To inspect predictions interactively, run the chunks and open `prediction_grid` in RStudio.

## Input choice

1970 is the earliest year tied for the largest number of complete station records (189). Following the professor's correction, stations 4085 and 4086 are relabelled from Puglia to Basilicata, and station 4367 from Puglia to Calabria. All observations are retained and the original input file is unchanged. The revised sample has 40 Basilicata stations and 149 Calabria stations.

The revised PDF reuses the previously verified cross-validation results and rainfall predictions. Regional labels are not inputs to IDW. The complete calculation code remains in the Rmd for reproducibility; knitting it normally will run that code again.

`RainData.RData` contains both the rainfall observations and their supplied land grid (`grid`, 1,005 locations). `AllGrids.RData` contains marine descriptors for 1995–2010 and does not match the rainfall years (1970–1982). It is inspected and documented, but is not used as the rainfall prediction grid. Both original uploads are included for reproducibility.

Rainfall in mm, elevation in m, and projected coordinates in m are stated working assumptions because the files do not contain complete units/CRS metadata. Review these assumptions and the AI-assisted report before submission.
