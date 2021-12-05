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

raw_zips_to_tract = function(zip) {
  usps_crosswalk_resp = GET("https://www.huduser.gov/hudapi/public/usps",
                            config = add_headers("Content-Type"="application/json",
                                                 "Authorization"=paste("Bearer", token)),
                            query = list(type=1,
                                         query=zip)
  )
  content(usps_crosswalk_resp)
}

# Data Cleaning

## Convert from tracts to zip codes
raw_tract_to_zips(17031, 813000)$data$results

map_dfr(raw_tract_to_zips(17031, 813000)$data$results, ~ .x)

map_dfr(raw_tract_to_zips(17031, 813000)$data$results, ~ .x)$geoid

any(is.na(raw_loc_index$CNTY_FIPS))
any(is.na(raw_loc_index$TRACT))

# should be true
is.null(raw_tract_to_zips(17031, 813000)[[1]]$error)

# should be false
is_null(raw_tract_to_zips(17097, 863006)[[1]]$error)

map_dfr(raw_tract_to_zips(17097, 863006)$data$results, ~ .x)

library(furrr)
future::plan(multisession, workers = 10)

test = 
  head(raw_loc_index, n = 3) %>%
  # raw_loc_index %>%
  future_pmap_dfr(function(...) {
    # 
    current <- tibble(...)
    # print(paste(current$TRACT, current$CNTY_FIPS))
    resp = raw_tract_to_zips(current$CNTY_FIPS, current$TRACT)
    print(paste("county + tract:", current$CNTY_FIPS, current$TRACT))
    print(is_null(resp[[1]]$error))
    
    if (is_null(resp[[1]]$error)) {
      zips = map_dfr(resp$data$results, ~ .x)
      # print(paste("county + tract:", current$CNTY_FIPS, current$TRACT))
      # print(zips$geoid)
      # since both raw_loc_index and zips have geoid, we need to rename
      # zips = zips %>% mutate(zip_code = geoid)
      zips = zips %>% mutate(CNTY_FIPS = current$CNTY_FIPS,
                             zip_code = geoid)
      # print(zips)
      
      # print(current %>% inner_join(zips))
      # return
      return(current %>% inner_join(zips, by = "CNTY_FIPS"))
    } else {
      print("Response is empty!")
      current %>% inner_join(
        data.frame(
          zip_code = NULL,
          res_ratio = NULL,
          bus_ratio = NULL,
          oth_ratio = NULL,
          tot_ratio = NULL
        ) %>%
          # map_dfr(raw_tract_to_zips(17031, 813000)$data$results, ~ .x) %>%
          mutate(CNTY_FIPS = current$CNTY_FIPS),
        by = "CNTY_FIPS"
      )
    }
  })
housing_index = hud_2021 %>% left_join(test, by = c("ZIP" = "zip_code"))

hud_2021 = readxl::read_xlsx("fy2021_safmrs_revised.xlsx") %>%
  filter(str_detect(`HUD Metro Fair Market Rent Area Name`, "Chicago")) %>% # 371 ZIP Codes
  select("ZIP" = `ZIP\nCode`, 
         "br_0" = `SAFMR\n0BR`,
         "br_1" = `SAFMR\n1BR`,
         "br_2" = `SAFMR\n2BR`,
         "br_3" = `SAFMR\n3BR`,
         "br_4" = `SAFMR\n4BR`) %>%
  mutate(year = 2021, .before = "ZIP")

map_dfr(raw_zips_to_tract(60002)$data$results, ~ .x)

# head(hud_2021, 2) %>%
housing_index = hud_2021 %>%
  future_pmap_dfr(function(...) {
    # this represents one row
    current <- tibble(...)
    
    # retrieves geoids from HUD API
    resp = raw_zips_to_tract(current$ZIP)
    print(paste("zip:", current$ZIP))
    print(is_null(resp[[1]]$error))
    
    if (is_null(resp[[1]]$error)) {
      zips = map_dfr(resp$data$results, ~ .x)
      # print(paste("county + tract:", current$CNTY_FIPS, current$TRACT))
      # print(zips$geoid)
      # zips = zips %>% mutate(zip_code = geoid)
      # print(paste("geoid:", zips$geoid))
      zips = zips %>% mutate(cnty_fips = substr(geoid, start = 0, stop = 5),
                             tract = substr(geoid, start = 5, stop = 10),
                             ZIP = current$ZIP)
      # print(zips)
      return(current %>% inner_join(zips, by = "ZIP"))
    } else {
      print("Response is empty!")
      current %>% inner_join(
        data.frame(
          ZIP = NULL,
          res_ratio = NULL,
          bus_ratio = NULL,
          oth_ratio = NULL,
          tot_ratio = NULL
        ) %>%
          mutate(ZIP = current$ZIP),
        by = "ZIP"
      )
    }
  })

housing_index = housing_index %>% 
  left_join(raw_loc_index, by=c('geoid'='GEOID'))

sum(is.na(housing_index$OBJECTID))/length(housing_index$OBJECTID)

# TO DO: build the dashboard first
