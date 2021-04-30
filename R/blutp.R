#' @param proj_mod The mode of the project, which sets where the input and 
#'   output data are stored, is either "dev" (for local development) or "prod"
#'   (on HZI's internal network).
#' @return Liste aller eingelesenen Blutplroben
#' @return datum, monovette, dateiname und stadt
read_blut <- function(bloodsamples_path){
  
  ## Alle Datein
  datein <- list.files(bloodsamples_path, pattern = "xlsx", full.names = TRUE, 
    recursive = TRUE) %>% 
    grep("\\~\\$", ., value = TRUE, invert = TRUE)
  
  # Usually there is just one sheet, but not always, in which case we provide 
  # the sheet name.
  sheet_name <- rep(NA, length(datein))
  special_sheet_files <- list(
    list(
      file = paste0(bloodsamples_path, "/Aachen/Monovetten, 09.09.2020.xlsx"), 
      sheet = "Tabelle1"
    ), 
    list(
      file = paste0(
        bloodsamples_path, "/Freiburg 2/Monovetten Freiburg 12.12.2020.xlsx"
      ), 
      sheet = "Tabelle1"
    )
  )
  for (i in 1:length(special_sheet_files)) {
    i_file <- which(datein == special_sheet_files[[i]]$file)
    sheet_name[i_file] <- special_sheet_files[[i]]$sheet
  }

  # Usually, the first column contains the data of interest, but not always, in 
  # which case we provide the column numbers.
  read_column <- rep(1, length(datein))
  read_column_files <- list(
    list(
      file = paste0(bloodsamples_path, "/Freiburg/Monovetten 07.08.2020.xlsx"), 
      column = 2
    )
  )
  for (i in 1:length(read_column_files)) {
    i_file <- which(datein == read_column_files[[i]]$file)
    read_column[i_file] <- read_column_files[[i]]$column
  }
  
  ## Lesen
  ## col_names = FALSE; da einige Datein die erste Reihe Monovette und Datum enthält
  ## Read only the first column
  # daten <- purrr::map(datein, read_excel, col_names = FALSE)
  daten <- lapply(
    1:length(datein), 
    function (i)
      if (is.na(sheet_name[i])) { 
        read_excel(datein[i], col_names = FALSE, 
          range = cell_cols(read_column[i]))
      } else {
        read_excel(datein[i], col_names = FALSE, 
          range = cell_cols(read_column[i]), sheet = sheet_name[i])
      }
  )
  
  data_raw <- NULL
  for (i in seq_along(daten)) {
    # The date is read from the 10 last characters of the file name, generally 
    # leading "DD.MM.YYYY". However there are some special cases:
    # - "Monovetten Freiburg 04.12.20.xlsx" has date 2020-12-04
    # - "Monovetten 11.08.2020 und Mi 12.08.2020.xlsx" has date 2020-08-12
    # - "Monovetten Magdeburg 18.11.xlsx" is handled specifically to have date 
    #   2020-11-18
    # - "Monovetten_Magdeburg_DDMMYY.xlsx" is handled specifically to have date 
    #   20YY-MM-DD
    # - "Monovetten 10.11.2020 Teil 2.xlsx" is handled specifically to have date 
    #   2020-11-10  
    
    #i <- 2
    dateinname <- basename(datein[i])
    if (dateinname == "Monovetten Magdeburg 18.11.xlsx") {
      datum <- as.Date("2020-11-18")
    } else if (dateinname == "Monovetten 10.11.2020 Teil 2.xlsx") {
      datum <- as.Date("2020-11-10")
    } else if (grepl("Monovetten_Magdeburg_", dateinname)) {
      datum <- dateinname %>%
        stringr::str_remove_all("\\.xlsx") %>%
        stringr::str_sub(-6) %>%
        lubridate::dmy()
    } else {
      datum <- dateinname %>%
        stringr::str_remove_all("\\.xlsx") %>%
        stringr::str_sub(-10) %>%
        lubridate::dmy()
    }
    index_stadt <- which(strsplit(datein[i], "/")[[1]] == "Blutprobenlisten") + 1
    stadt <- strsplit(datein[i], "/")[[1]][index_stadt]
    
    data_raw[[i]] <- daten[[i]] %>% 
      dplyr::rename(monovette = 1) %>% 
      dplyr::mutate_all(as.character) %>% 
      dplyr::mutate(dateinname = dateinname, datum = datum) %>% 
      filter(!grepl("Monov", monovette, ignore.case = TRUE)) %>% 
      dplyr::select(datum, monovette, dateinname) %>% 
      dplyr::mutate(stadt = stadt)
    
  }
  # Missing sample IDs (`monovette` is `NA`) correspond to empty cells in the
  # Excel sheets
  # Some files start with a header "ID" which is removed here
  blutp <- dplyr::bind_rows(data_raw) %>% 
    dplyr::filter(!is.na(monovette), monovette != "ID")
  
  return(blutp)
  
}
