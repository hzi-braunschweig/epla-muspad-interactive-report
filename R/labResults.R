read_lab_results <- function(labresults_path){
  # Reads results of lab analyses of blood samples
  
  ## Alle Datein
  datein <- list.files(labresults_path, pattern = "^cov\\_202.*\\_hzi.*\\.csv$",
    full.names = TRUE, recursive = TRUE)
  
  # Add further CSV files manually
  datein <- c(
    datein, 
    paste0(
      labresults_path,
      "/Laborergebnisse Original CSV 2020/",
      c(
        "4_Reutlingen 2/Nachtrag Reutlingen 2 20202511.csv",
        "5_Osnabrueck/Nachtrag Osnabrueck 1 20202511.csv",
        "6_Magdeburg/Magdeburg 1 Erste Ergebnisse.csv",
        "7_Freiburg 2/Freiburg 2 Erste Ergebnisse.csv"
      )
    )
  )
  
  ## Lesen
  # N.B. the quantitative results have sometimes non-numeric values such as
  # "<3,80", thus all variables are set to character.
  daten <- purrr::map(datein, read.csv2, header = TRUE,
    colClasses = "character", na.strings = c("", NA))
  
  data_raw <- NULL
  for (i in seq_along(daten)) {
    # After visual inspection: skip 1 row after header (the option `skip` of
    # `read.csv2` is not used as it removes column names).
    # Then remove empty rows.
    
    # Quantitative lab results have "," replaced with "." as they are otherwise
    # not correctly exported to Excel, even though it's a string.
    
    index_stadt <- grep(
      "Laborergebnisse Original CSV 202", 
      strsplit(datein[i], "/")[[1]]
    ) + 1
    stadt <- strsplit(datein[i], "/")[[1]][index_stadt]
    stadt <- gsub("^.\\_", "", stadt)
    
    data_raw[[i]] <- daten[[i]][2:nrow(daten[[i]]), ] %>% 
      as_tibble() %>%
      dplyr::filter_all(any_vars(!is.na(.))) %>%
      dplyr::mutate_all(as.character) %>%
      dplyr::mutate(
        stadt = stadt,
        datum = stringr::str_sub(Analysedatum, 1, 10),
        datum = lubridate::dmy(datum),
        dateinname = basename(datein[i]),
        Ergebnis..quantitativ. = 
          stringr::str_replace(Ergebnis..quantitativ., ",", ".")
      )
  }
  labr <- dplyr::bind_rows(data_raw)
  
  return(labr)
}
