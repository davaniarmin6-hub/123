# Homework 2 — Rainfall, 1970

- **Read the report:** open `Homework_2_Rainfall.pdf`.
- **Read or run the code:** open `Homework_2_Rainfall.Rmd` in RStudio.
- **Download everything:** download `Homework_2_Rainfall_bundle.zip` and extract it. Keep the `data` folder beside the Rmd file.

On GitHub, open the file and use **Download raw file**. Alternatively, use the repository's **Code → Download ZIP** option and open its `homework2` folder. These files are on the **work** branch.

Install `gstat`, `sp`, `knitr`, and `rmarkdown` if necessary. PDF knitting also needs LaTeX; install `tinytex` and run `tinytex::install_tinytex()` if you do not have LaTeX already. Click **Knit to PDF** in RStudio. The cross-validation loops take a few minutes.

The Rmd contains the code, plots, calculated results, explanations, weak/good prompts, recorded AI responses, and contribution disclosure. Figures appear in the compiled report; the analysis does not export separate plots or tables. To inspect predictions interactively, run the chunks and open `prediction_grid` in RStudio.

## Input choice

1970 is the earliest year tied for the largest number of complete station records (189). Station 4367 is relabelled from Puglia to Calabria in memory, without deleting measurements or modifying the original input file.

`RainData.RData` contains both the rainfall observations and their supplied land grid (`grid`, 1,005 locations). `AllGrids.RData` contains marine descriptors for 1995–2010 and does not match the rainfall years (1970–1982). It is inspected and documented, but is not used as the rainfall prediction grid. Both original uploads are included for reproducibility.

Rainfall in mm, elevation in m, and projected coordinates in m are stated working assumptions because the files do not contain complete units/CRS metadata. Review these assumptions and the AI-assisted report before submission.
