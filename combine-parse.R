# Parse Files
library(stringr)
library(dplyr)
library(purrr)

h <- here::here

county_details <- fs::dir_ls(h("data"), glob = "*.json")

pull_time <- lubridate::as_datetime(str_remove(basename(county_details), "\\.json"))

pull_date <- lubridate::date(pull_time)

dat_information <- data.frame(
	county_details= unname(county_details),
	pull_time,
	pull_date
) %>%
	group_by(pull_date) %>%
	filter(pull_time==max(pull_time))

dat_raw <- map(dat_information$county_details, jsonlite::read_json)

names(dat_raw) <- format(dat_information$pull_date, "%Y-%m-%d")

a <- map(dat_raw, "data")

names(a)

b <- data.table::rbindlist(lapply(a, data.table::rbindlist, fill = TRUE), fill = TRUE,
													 idcol = "report_date")

dat_out <- b[StateName=="North Carolina"]

dat_out$`COVID-19 Community Level - COVID Inpatient Bed Utilization` <- with(
	dat_out, as.numeric(stringr::str_remove_all(pattern = "%", 
														 string = `COVID-19 Community Level - COVID Inpatient Bed Utilization`)
))
str(dat_out)
data.table::setnames(x = dat_out, old = " TotalPop ", new = "TotalPop")
dat_out$Name <- with(dat_out, stringr::str_remove_all(string = Name, pattern = " County, (NC|VA|SC)"))
dat_out$TotalPop <- with(dat_out, stringr::str_remove_all(string = TotalPop, pattern = ","))

data.table::fwrite(dat_out, here::here("output", "cdc-community-level.csv"))
