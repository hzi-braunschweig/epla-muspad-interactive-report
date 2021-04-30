#' @param proj_mod The mode of the project, which sets where the input and 
#'   output data are stored, is either "dev" (for local development) or "prod"
#'   (on HZI's internal network).
#' @return dataset for logtaq
read_log_pdfs <- function(logs_path){
  
  ## Alle Datein
  datein <- list.files(
    logs_path, 
    pattern = "pdf",
    full.names = TRUE, 
    recursive = TRUE
  )
  
  ## Lesen
  daten <- map(datein, pdf_text)
  
  pdf_tables <- NULL
  for (i in seq_along(daten)) {
    print(i)
    if (length(daten[[i]]) >= 3) {
      print("more than 3 pages")
      first_page_with_table <- min(
        grep("IndexDatum", gsub(" ", "", daten[[i]]))
      )
      pdf_tables[[i]] <- daten[[i]][first_page_with_table] %>%
        readr::read_delim(delim = " ") %>% 
        dplyr::mutate_all(stringr::str_trim) %>% 
        dplyr::select(1:4) %>% 
        purrr::set_names(c("index", "datum", "uhrzeit", "celsius")) %>% 
        dplyr::filter(grepl("[0-9]", index),
                      nchar(index) < 3) %>% 
        dplyr::mutate(celsius = stringr::str_replace_all(celsius, "\\,", "."),
                      celsius = as.numeric(celsius),
                      index = as.numeric(index),
                      datum = lubridate::dmy(datum),
                      file = basename(datein[i]),
                      file_id = i)
    } else {
      print("less than 3 pages")
    }
  }
  
  LoqTaq <- dplyr::bind_rows(pdf_tables) %>% 
    dplyr::group_by(file_id) %>% 
    dplyr::mutate(
      start_date = min(datum),
      stadt = dplyr::case_when(
        grepl("Reutlingen", file) ~ "Reutlingen",
        grepl("Freiburg", file) ~ "Freiburg"
      )
    )
  
  return(LoqTaq)
}