# Interactive quality control report for SARS-CoV-2 serology study EPLA / MuSPAD 

Generates an interactive report based on serological lab results, blood sample IDs, and temperature logs from the EPLA / MuSPAD study. It contains among other things interactive tables for the samples and results together with histograms of samples per day or per study center or lab. Furthermore, samples and lab results are (partially) matched, with teh data sets obtained shown in interactive tables and a bubble plot of date when the sample was sent vs. date when it was analyzed in the lab.

The report is an HTML file generated via R scripts and R markdown.

## Installation

To install the necessary libraries which are not yet installed on your computer, run the following in an R session:

```r
required_packages <- c("flexdashboard", "tidyr", "ggplot2", "forcats", 
  "janitor", "lubridate", "DT", "ggiraph", "pdftools", "readr", "dplyr",
  "purrr", "stringr", "readxl")
for (pack in required_packages) {
  if (!require(pack, character.only = TRUE)) {
      install.packages(pack)
  }
}
```

If you are not using RStudio, you will also need to install the R package `rmarkdown` as well as Pandoc: https://pandoc.org/installing.html

## Data paths

The locations of the data files need to be specified. This done in [R/data-paths.R](R/data-paths.R). There to use cases are already considered:

1. the default: the directories containing data files have been copied in "data/" in this project directory
2. the files stay in their default locations on the EPID's internal network and this project directory has been copied under "EPLA/MUSPAD-1/": uncomment the corresponding lines

## Generating the report

The report is generated in this directory and called "epla-muspad-interactive-report.html"

### RStudio

Open "epla-muspad-interactive-report.Rproj", open "epla-muspad-interactive-report.Rmd", click "Knit" in the Source pane or press Command + Shift + k (macOS) / Ctrl + Shift + k (Linux, Windows) .

### R console

In a console go to the directory containing "epla-muspad-interactive-report.Rmd" and execute:

```shell
Rscript -e "library(flexdashboard); rmarkdown::render('epla-muspad-interactive-report.Rmd', 'flex_dashboard')"
```

### Double click in Windows

*This hasn't been tested!*

In Windows, one can make it a user friendlier by putting the above line of code in a BAT file: open a text editor, copy the above line of code, and save the file in the same directory as "epla-muspad-interactive-report.Rmd" and give it a name ending with ".bat", e.g., "generate_report.bat").

That way the user can generate the report by simply double-clicking that BAT file.

However the R packages listed above have to be already installed in the user's computer.

## Authors

Stéphane Ghozzi, Stephan Glöckner

Epidemiology Department EPID
Helmholtz Centre for Infection Research HZI
Inhoffenstrasse 7, 38124 Braunschweig, Germany

## MIT License

Copyright (c) 2021 the authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.