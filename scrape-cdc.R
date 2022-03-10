library(jsonlite)

if(!dir.exists("data")) dir.create("data")

end <- "/coronavirus/2019-ncov/modules/science/us-community-levels-by-county.json"

slugify_date <- function(x){
	x <- stringi::stri_replace_all_regex(x,"[^\\P{P}-]","")
	x <- gsub(x, pattern = " ", replacement = "-")
	x
}
ping_time <- slugify_date(Sys.time())

download.file(
  paste0("https://www.cdc.gov/", end),
sprintf("data/%s.json", ping_time),
quiet = TRUE,
cacheOK = FALSE
)
