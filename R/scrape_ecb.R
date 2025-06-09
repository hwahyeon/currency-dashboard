library(xml2)
library(dplyr)
library(readr)
library(lubridate)

update_exchange_rates <- function(output_path = "data/recent.csv") {
  # ECB XML URL
  url <- "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
  xml <- read_xml(url)
  ns <- c(ns = "http://www.ecb.int/vocabulary/2002-08-01/eurofxref")
  
  # Extract date
  date_node <- xml_find_first(xml, ".//ns:Cube[@time]", ns)
  date <- xml_attr(date_node, "time") |> as.Date()
  
  # Extract exchange rate data
  rates <- xml_find_all(xml, ".//ns:Cube[@currency]", ns)
  df <- tibble(
    date = date,
    currency = xml_attr(rates, "currency"),
    rate = as.numeric(xml_attr(rates, "rate"))
  )
  
  # Merge with existing file if exists
  if (file.exists(output_path)) {
    old <- read_csv(output_path, show_col_types = FALSE) |>
      mutate(
        date = as.Date(date),
        rate = as.numeric(rate)
      )
    df <- bind_rows(old, df) |>
      distinct(date, currency, .keep_all = TRUE) |>
      arrange(desc(date), currency)
  }
  
  # Ensure data folder exists
  dir.create(dirname(output_path), showWarnings = FALSE, recursive = TRUE)
  
  # Save to CSV
  write_csv(df, output_path)
}

update_exchange_rates()
