# Alexis Kwan
# PA 446 Final Project

# Problem

"How can renters and housing advocates gauge how good housing is for an area?"

# Audience

"Renters and affordable housing advocates"

# Data Sourcing

library(httr)
library(jsonlite)
library(tidyverse)
library(broom)
library(purrr)

# HUD Users Location Affordability Index v.3 data
# data that shows the links between housing and transportation
resp = GET("https://services.arcgis.com/VTyQ9soqVukalItT/arcgis/rest/services/Location_Affordability_Index_v3/FeatureServer/0/query?where=STUSAB%20%3D%20'IL'&outFields=*&returnGeometry=false&outSR=4326&f=json")
jsonRespParsed = content(resp, as="parsed") 

raw_loc_index = map_dfr(jsonRespParsed$features, "attributes")

# HUD Users/USPS Crosswalk data
# data that maps zip codes to census tracts and counties
token = read_file("huduser_token.txt")

raw_tract_to_zips = function(cntyFips, tract) {
  usps_crosswalk_resp = GET("https://www.huduser.gov/hudapi/public/usps",
                            config = add_headers("Content-Type"="application/json",
                                                 "Authorization"=paste("Bearer", token)),
                            query = list(type=6,
                                         query=paste(cntyFips, tract, sep = ""))
  )
  content(usps_crosswalk_resp)
}

# Data Cleaning

## Convert from tracts to zip codes
raw_tract_to_zips(17031, 813000)$data$results

map_dfr(raw_tract_to_zips(17031, 813000)$data$results, ~ .x)

map_dfr(raw_tract_to_zips(17031, 813000)$data$results, ~ .x)$geoid

head(raw_loc_index, n = 1) %>%
  pmap_dfr(function(...) {
    current <- tibble(...)
    # do cool stuff and access content from current row with
    # print(x)
    # print(paste(current$TRACT, current$CNTY_FIPS))
    zips = map_dfr(raw_tract_to_zips(current$CNTY_FIPS, current$TRACT)$data$results, ~ .x)
    zips = zips %>% mutate(CNTY_FIPS = current$CNTY_FIPS)
    # print(zips)
    print(current %>% inner_join(zips))
    # return
    current %>%
      mutate(date = Sys.Date())
  })

raw_loc_index %>% map_dfr(raw_tract_to_zips(., TRACT)$data$results, ~ .x)
     