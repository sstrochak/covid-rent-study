
library(tidyverse)
library(lubridate)

fips <- tigris::fips_codes


# Read in -----------------------------------------------------------------

rents1 <- read_csv(here::here("data",
                              "monthly-county-rent.csv"))

zillow <- read_csv(here::here("data",
                              "monthly-county-zhvi.csv"))

temp_monthly <- read_csv(here::here("data",
                                    "monthly-county-temperature.csv"))

covid_monthly <- read_csv(here::here("data",
                                     "monthly-county-covid-cases.csv"))

emp <- read_csv(here::here("data",
                           "monthly-county-employment.csv"))

pop <- read_csv(here::here("data",
                           "county-population-variables.csv"))

urban <- read_csv(here::here("data",
                             "county-urban-rural-classification.csv"))

pmms <- read_csv(here::here("data",
                            "monthly-pmms.csv"))

state_restrictions <- read_csv(here::here("data",
                                          "state-covid-restrictions.csv"))
# Merge and write out -----------------------------------------------------

data <- rents1 %>% 
  left_join(zillow, by = c("fips", "month")) %>% 
  left_join(temp_monthly, by = c("fips", "month")) %>% 
  left_join(covid_monthly, by = c("fips", "month")) %>% 
  left_join(emp, by = c("fips", "month")) %>% 
  left_join(pop, by = "fips") %>% 
  left_join(urban, by = "fips") %>% 
  left_join(pmms, by = "month")

# Add back county and state names
data <- data %>% 
  left_join(fips %>% 
              mutate(fips = paste0(state_code, county_code)) %>% 
              select(fips, state, state_code,
                     county_name = county), 
            by = c("fips")) %>% 
  # Add state level data
  left_join(state_restrictions, by = "state_code") %>% 
  select(state, fips, county_name, month, everything(), -state_code)

# Write out
write_csv(data,
          here::here("data",
                     "monthly-county-combined-dataset.csv"),
          na = "")