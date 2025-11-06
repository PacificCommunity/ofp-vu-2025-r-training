
library("tidyverse")
library("tidyr")
library("viridis")
library("data.table")
library("stringr")
library("processx")
library("dotenv")
library("jsonlite")

load_dot_env()

# function to generate a token
generate_token <- function(user_name, country_code){
  result <- run(
    "curl",
    args = c(
      "-X", "POST",
      "https://www.spc.int/ofp/tufman2api/api/ApiAccess/GetToken",
      "-H", "Content-Type: application/json",
      "-H", paste0("TufInstance: ", country_code),
      "-H", paste0(' "TufUser: ", user_name, "'),
      "-d", sprintf('{"userEmail": "%s", "password": "%s"}', user_name, Sys.getenv("TUF_PASSWORD"))
    )
  )
  
  if (result$stdout == ""){
    stop("There was an issue with your request. Maybe you used the wrong country code?")
  }
  
  resp_content <- fromJSON(result$stdout)
  
  # Save both tokens with creation timestamp
  token_data <- list(
    access = resp_content$access_token,
    refresh = resp_content$refresh_token,
    created_at = Sys.time()
  )
  
  token <- token_data$access
  
  if (is.null(token)){
    stop("The token generated is empty, this might mean you don't have permissions to generate a token. Please,
         contact the DM SPC team for help: 'ofpdmpro@spc.int'")
  }else{
    
    saveRDS(token_data, 'token.RData')
    cat("New token saved successfully!\n")
    
    return(token)
  }
  
}  

# check if token exits and is valid, otherwise create one
load_token <- function(user_name, country_code){
  
  if (file.exists("token.RData")) {
    token_data <- readRDS('token.RData')
    
    # Check if token has expired (3600 seconds = 1 hour)
    time_elapsed <- as.numeric(difftime(Sys.time(), token_data$created_at, units = "secs"))
    
    if (time_elapsed < 3600) {
      cat("Token loaded and still valid (", round(3600 - time_elapsed), " seconds remaining)\n")
      token <- token_data$access
    } else {
      cat("Token expired...\n")
      token <- generate_token(user_name = user_name, 
                              country_code = country_code)
    }
  }else{
    token <- generate_token(user_name = user_name, 
                            country_code = country_code)
  }

  return(token)
  }

get_list_of_t2_reports <- function(token, country_code, user_name, replace = FALSE){
  
  
  if (replace){
    filename_csv <- paste0("./data/list_of_t2_reports_", tolower(country_code), ".csv")
  
  }else{
    
    filename_csv <- paste0("./data/list_of_t2_reports_", tolower(country_code), ".csv")
    
    # Check if file exists
    if(file.exists(filename_csv)){
      print(paste0("Returning list of exisiting reports in Tufman2 created on : ", as.character(file.info(filename_csv)$ctime)))
      
      res <- read.csv(filename_csv)
      return(res)
    }
  }
  # Get the full list of reports user has available and the attributes that each of them require ####
  result_reports <- run(
    "curl",
    args = c(
      "-X", "GET",
      "https://www.spc.int/ofp/tufman2api/api/ReportDefinition/AllSimple",
      "-H", "accept: application/json, text/plain, */*'",
      "-H", paste0("authorization: Bearer ", token),
      "-H", "content-type: application/json",
      "-H", paste0("tufinstance: ", country_code),
      "-H", "tufmodule: Reports",
      "-H", paste0("tufuser: ", user_name)
    )
  )
  
  if (result_reports$stdout == ""){
    stop("There was an issue with your request. Maybe you used the wrong country code?")
  }
  
  all_reports <- fromJSON(result_reports$stdout) |>
    select(Guid, 1:9, OptionLabels, LastModifiedDateTime)
  
  # Get reports attributes and combine with full list of reports ####
  attributes_per_report <- data.frame()
  for(i in 1:nrow(all_reports)) {
    
    # inform 
    print(paste0("Requesting attrs for report ", i, " from ", nrow(all_reports), ":", all_reports$Title[i]))
    
    sel_guid = all_reports$Guid[i]
    
    result_attributes <- run(
      "curl",
      args = c(
        "-X", "GET",
        paste0("https://www.spc.int/ofp/tufman2api/api/ReportDefinition/ByGuid?guid=", sel_guid),
        "-H", "accept: application/json, text/plain, */*'",
        "-H", paste0("authorization: Bearer ", token),
        "-H", "content-type: application/json",
        "-H", paste0("tufinstance: ", country_code),
        "-H", "tufmodule: Reports",
        "-H", paste0("tufuser: ", user_name)
      )
    )
    
    
    if (result_attributes$stdout == ""){
      stop("There was an issue with your request. Maybe you used the wrong country code?")
    }
    
    attributes_report <- jsonlite::fromJSON(result_attributes$stdout, flatten = TRUE)
    attributes_report_df <- bind_rows(attributes_report)
    
    # dive into the df and get the required attribute for the guid
    attrs_all <- attributes_report_df$Options[[1]] |>
      data.frame() |>
      filter(StatusId > 0) |>
      pull(Name) |>
      paste0(collapse=", ")

    attrs_guid <- data.frame(guid = sel_guid, 
                             report_attrs = attrs_all, 
                             sql_query = attributes_report_df$Sql[[1]])
    
    # get group by if exist 
    attrs_group_by <- attributes_report_df$Options$GroupBys |>
      data.frame()
    
    if (nrow(attrs_group_by)>0 ){
      attrs_group_by_res <- attrs_group_by |>
        slice(1) |>
        pull(Key)
      
      attrs_guid$report_group_by <- attrs_group_by_res 
      
    }else{
      attrs_guid$report_group_by <- NA
    }
      
    attributes_per_report <- rbind(attributes_per_report, attrs_guid)
    
  }
  
  all_reports_with_attrs <- all_reports |>
    janitor::clean_names() |>
    left_join(attributes_per_report) |>
    select(1:2, report_attrs, everything()) |>
    mutate(option_labels = sapply(option_labels, function(x) paste(x, collapse = ", "))) |>
    data.frame()
  
  sapply(all_reports_with_attrs, is.list)
  
  print(paste0("Saving reports available as a new csv: ", filename_csv))
  write.csv(all_reports_with_attrs, file = filename_csv)
  
  # get the unique attributes based on all reports
  # unique_attrs <- all_reports_with_attrs$report_attrs |>
  #   paste(collapse = ",") |>                # collapse all values into one string
  #   str_split(",") |>                       # split by commas
  #   unlist() |>                             # flatten the list
  #   str_trim() |>                           # remove leading/trailing spaces
  #   discard(~ .x == "") |>                  # remove empty entries (requires purrr)
  #   unique() |>                             # get unique words
  #   sort()                                  # optional: sort alphabetically
  
  return(all_reports_with_attrs)
  
  # return(list(t2_reports = all_reports_with_attrs, 
  #             unique_attrs = unique_attrs))
  
  }


get_reports <- function(token, user_name, country_code, filtered_reports, attrs,
                        base_url = "https://www.spc.int/ofp/tufman2api/api/ReportDefinition/DownloadResults",
                        lang = "en",overwrite = TRUE){

    reports_selected <- filtered_reports |>
      pull(title)
    
    api_calls <- vector("character", length(reports_selected))
    for (i in seq_along(reports_selected)) {
      
      # Get guid and attributes for this report
      report_info <- filtered_reports |>
        filter(title == reports_selected[i]) |>
        select(guid, report_attrs, report_group_by, user_report_id, title)
      
      guid <- report_info$guid
      user_id <- report_info$user_report_id
      group_by <- report_info$report_group_by
      
      report_attr_names <- strsplit(report_info$report_attrs, ",") |> 
        unlist() |> trimws()
      
      # Build runParams only for attributes relevant to this report
      params_list <- attrs[names(attrs) %in% report_attr_names]
      
      # Add group_by if not NA or empty
      if (!is.null(group_by) && !is.na(group_by) && nzchar(group_by)) {
        params_list$group_by <- group_by
      }
      
      # Convert runParams list to JSON and URL encode it
      runParams_json <- jsonlite::toJSON(params_list, auto_unbox = TRUE)
      runParams_encoded <- utils::URLencode(runParams_json, reserved = TRUE)
      
      # Build the full curl URL
      api_url <- glue::glue(
        "{base_url}?guid={guid}&lang={lang}&runParams={runParams_encoded}"
      )
      
      ret <- run(
        "curl",
        args = c(
          "-X", "GET",
          api_url,
          "-H", "accept: application/json, text/plain, */*'",
          "-H", paste0("authorization: Bearer ", token),
          "-H", "content-type: application/json",
          "-H", paste0("tufinstance: ", country_code),
          "-H", "tufmodule: Reports",
          "-H", paste0("tufuser: ", user_name)
        )
      )
      
      if (is.null(ret$stdout) || trimws(paste(ret$stdout, collapse = "")) == "") {
        message(
          paste0(
            "No data available for report: ", report_info$title,
            " and attributes: ", as.character(runParams_json),
            ", or your token has expired. Skipping..."
          )
        )
        next
      }
      
      if (grepl("^[{\\[]", trimws(ret$stdout))) {
        # JSON case
        ret_df <- jsonlite::fromJSON(paste(ret$stdout, collapse = ""), flatten = TRUE)$Rows |>
          data.frame()
      } else {
        # CSV case
        ret_df <- read.csv(text = ret$stdout, stringsAsFactors = FALSE)
      }
      
      
      if(length(ret_df) == 0){
        print(paste0("No data available for report: ", report_info$title, " and attributes: ",
                     as.character(runParams_json), ", skipping..."))
        next
      }

      ret_df <- ret_df |>
        dplyr::mutate(
          attrs_query = runParams_json,
          guid = guid
        ) |>
        dplyr::select(guid, attrs_query, dplyr::everything())
      
      # save to folder t2_reports_data
      if (overwrite){
        filename_csv <- paste0("./data/t2_reports_data/", tolower(country_code), "_", user_id, "_", Sys.Date(), ".csv")
      }else{
        filename_csv <- paste0("./data/t2_reports_data/", tolower(country_code), "_", user_id, "_", ".csv")
      }
      
      print(paste0("Saving data from report ", report_info$title, " as csv: ", filename_csv))
      write.csv(ret_df, file = filename_csv)
      
      api_calls[i] <- api_url
      
    }
    return(api_calls)
    
}
  