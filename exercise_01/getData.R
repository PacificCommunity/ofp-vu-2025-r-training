################################################################################
### Rcode for retrieving Tufman 2 data                                       ###
### SPC 2025 - Vanuatu training                                              ###
### Jessica Leiria Schattschneider                                           ###
################################################################################

# Load libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ####
rm(list=ls())
library("DT")
source("utils.R") # load local functions

# 1. Load existing token or generate a new one  :::::::::::::::::::::::::::: ####

## specify user_name and country_code
user_name = "jessicals@spc.int"
country_code = "VU"

## load token
token <- load_token(user_name, country_code)

# 2. Load existing reports :::::::::::::::::::::::::::: ####

# get from Tufman 2 the list of all reports you have access to, eg, all you can see
# in this webpage: https://www.spc.int/ofp/tufman2/data/ReportDefinition

existing_reports <- get_list_of_t2_reports(
                      token, 
                      country_code, 
                      user_name, 
                      replace = FALSE) |>
                    data.frame()

# Print the result in a table where you can search for what you want
DT::datatable(
  existing_reports |>
    dplyr::select(
      Id = user_report_id,
      Filters = option_labels,
      Title = title, 
                  Description = description, 
                  `Last modified` = last_modified_date_time,
                  ) |>
    arrange(Title),
    filter = "top",  # adds text boxes at the top of each column
  
  options = list(
    pageLength = nrow(existing_reports),
    dom = 'lftrip',  # ensures the search box ("f") is shown
    initComplete = JS(
      "function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
      "}")
  )
)

# 3. Select reports of interest  :::::::::::::::::::::::::::: ####

# We are only interested in Part 1 reports for longline

# select the ids where the word "part 1" appears in title AND the word "Longline" 
# appears in Filters

# filter the wrong way...

filtered_reports <- existing_reports |>
  mutate(across(where(is.character), tolower)) %>%  # only lowercase text columns
  filter(
    grepl("part 1|part1", title, ignore.case = TRUE),
    grepl("longline", option_labels, ignore.case = TRUE)
  )


filtered_reports <- existing_reports |>
  filter(user_report_id %in% c(2890, 2900))


# 4. Explore attributes and define values  :::::::::::::::::::::::::::: ####

# get list of attributes
filtered_attrs <- filtered_reports$report_attrs |>
  paste(collapse = ",") |>                # collapse all values into one string
  str_split(",") |>                       # split by commas
  unlist() |>                             # flatten the list
  str_trim() |>                           # remove leading/trailing spaces
  discard(~ .x == "") |>                  # remove empty entries (requires purrr)
  unique() |>                             # get unique words
  sort()                                  # optional: sort alphabetically

filtered_attrs

# Define parameter values - change the values below according to what you need
attrs <- list(
  flag_code = "VU",
  year = 2024
  )

# 5. Download the data from reports  :::::::::::::::::::::::::::: ####

report_data <- get_reports(token = token, user_name = user_name, country_code = country_code, 
            filtered_reports = filtered_reports, attrs = attrs)

