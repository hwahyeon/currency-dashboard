library(rmarkdown)

render(
  input = "report/report.Rmd",
  output_file = "index.html",
  output_dir = "report",
  quiet = TRUE
)
