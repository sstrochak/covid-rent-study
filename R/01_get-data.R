
library(tidyverse)
library(tigris)
library(lubridate)

fips <- tigris::fips_codes

###### Gather data ########

# For each dataset:
## Convert to long, monthly format
## Create month variable, in date form
## Create fips variable (5 digit fips code)


# Rents -------------------------------------------------------------------

# apartmentlist.com/research/category/data-rent-estimates

rents <- read_csv(here::here("data-raw",
                             "Apartment_List_Rent_Estimates_County_2021_3.csv"))

rents1 <- rents %>% 
  mutate(Bedroom_Size = str_remove(Bedroom_Size, "_")) %>% 
  mutate(fips = str_pad(FIPS_Code,
                        width = 5, side = "left", pad = "0")) %>% 
  select(-County_Name, -Population, -FIPS_Code) %>% 
  pivot_longer(cols = starts_with("20"),
               names_to = "month",
               values_to = "rent") %>% 
  filter(Bedroom_Size == "Overall") %>% 
  select(-Bedroom_Size) %>% 
  group_by(fips) %>% 
  mutate(rent_yoy = (rent - lag(rent, 12)) - lag(rent, 12),
         rent_index = rent / rent[month == "2020_02"] * 100,
         month = ymd(paste0(month, "-01"))) %>% 
  filter(year(month) > 2017)

write_csv(rents1,
          here::here("data", "monthly-county-rent.csv"))


# Home prices -------------------------------------------------------------

zillow <- read_csv("https://files.zillowstatic.com/research/public_v2/zhvi/County_zhvi_uc_sfrcondo_tier_0.33_0.67_sm_sa_mon.csv")

zillow <- zillow %>% 
  mutate(fips = paste0(StateCodeFIPS, MunicipalCodeFIPS)) %>% 
  select(-RegionID, -SizeRank, -RegionName, -RegionType, -StateName,
         -State, -Metro, -StateCodeFIPS, -MunicipalCodeFIPS) %>% 
  gather(key = "month", value = "zhvi", -fips) %>% 
  arrange(fips, month) %>% 
  group_by(fips) %>% 
  mutate(month = ymd(paste0(str_sub(month, 1, 7), "-01")),
         zhvi_yoy = (zhvi - lag(zhvi, 12)) - lag(zhvi, 12),
         zhvi_index = zhvi / zhvi[month == "2020-02-01"] * 100) %>% 
  filter(month >= "2018-01-01")

write_csv(zillow,
          here::here("data", "monthly-county-zhvi.csv"))

# COVID Cases -------------------------------------------------------------

# https://github.com/nytimes/covid-19-data

covid <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")


covid_monthly <- covid %>% 
  mutate(month = substr(date, 1, 7)) %>% 
  group_by(fips, month) %>% 
  summarize(cases = sum(cases),
            deaths = sum(deaths)) %>% 
  mutate(month = ymd(paste0(month, "-01")))

write_csv(covid_monthly,
          here::here("data", "monthly-county-covid-cases.csv"))

# Temperature -------------------------------------------------------------

# https://www.ncdc.noaa.gov/cag/county/mapping/110/tavg/202101/1/value

read_county_temperature <- function(date,
                                    var) {
  
  print(str_glue("Reading {var} data for {date}"))
  
  read_csv(str_glue("https://www.ncdc.noaa.gov/cag/county/mapping/110-t{var}-{date}-1.csv"),
           skip = 4,
           col_names = FALSE,
           col_types = cols(
             X1 = col_character(),
             X2 = col_character(),
             X3 = col_double(),
             X4 = col_double(),
             X5 = col_double(),
             X6 = col_double()
           )) %>% 
    rename_at(vars(everything()),
              ~ c("location", "county_name", "value", "rank", "anomaly", "hist_mean")) %>% 
    select(location, county_name, value) %>% 
    mutate(measure = paste0(var, "_temp"),
           month = date)

}

date_range <- c(paste0(2020, str_pad(1:12, width = 2, side = "left", pad = "0")),
                paste0(2021, str_pad(2, width = 2, side = "left", pad = "0")))

combos <- expand.grid(date_range,
                      c("avg", "min", "max"))

temp <- map2_df(.x = combos$Var1,
                .y = combos$Var2,
               ~ read_county_temperature(date = .x,
                                         var = .y))

temp1 <- temp %>% 
  # Clean up location variable to get proper FIPS code
  separate(location, sep = "-",
           into = c("state", "county_fips")) %>% 
  left_join(select(fips, state, state_code, county_code),
            by = c("state",
                   "county_fips" = "county_code")) %>% 
  mutate(fips = paste0(state_code, county_fips)) %>% 
  select(-state, -county_fips, - county_name, -state_code) %>% 
  # Convert month variable to proper date format
  mutate(month = ymd(paste0(month, "01")),
         ## Account for lag- January 2021 data is reporting Dec 2020 temperatures
         month = month - months(1))

temp_monthly <- temp1 %>% 
  pivot_wider(id_cols = c("month", "fips"),
              names_from = measure) %>% 
  select(fips, month, everything())

write_csv(temp_monthly,
          here::here("data", "monthly-county-temperature.csv"))


# Population and population density ---------------------------------------

pop <- tidycensus::get_acs(geography = "county",
                           variables = "B01003_001") %>% 
  left_join(urbnmapr::get_urbn_map(map = "counties",
                                   sf = TRUE),
            by = c("GEOID" = "county_fips")) %>% 
  sf::st_as_sf() %>% 
  sf::st_transform(crs = 2965) %>% 
  mutate(area = sf::st_area(geometry)) %>% 
  mutate(area_meter = units::set_units(area, meter^2),
         area_sqmile = units::set_units(area, miles^2)) %>% 
  mutate(pop_density = as.numeric(estimate / area_sqmile)) %>% 
  select(fips = GEOID,
         population = estimate,
         population_per_sqmile = pop_density,
         pop_density) %>% 
  sf::st_drop_geometry()


write_csv(pop,
          here::here("data", "county-population-variables.csv"))

# Urban-rural classification ----------------------------------------------

# https://www.ers.usda.gov/data-products/rural-urban-continuum-codes.aspx

urban <- rio::import("https://www.ers.usda.gov/webdocs/DataFiles/53251/ruralurbancodes2013.xls")


urban <- urban %>% 
  select(fips = FIPS,
         rural_classification = RUCC_2013,
         rural_description = Description)


write_csv(urban,
          here::here("data",
                     "county-urban-rural-classification.csv"))

# Job losses --------------------------------------------------------------

# https://www.bls.gov/news.release/cewqtr.toc.htm

emp <- read_delim("https://www.bls.gov/web/metro/laucntycur14.txt",
                  delim = "|",
                skip = 6,
                col_names = FALSE) %>% 
  filter(!is.na(X2)) %>% 
  mutate_all(str_trim) %>% 
  rename_at(vars(everything()),
            ~ c("location", "state_fips", "county_fips", "county_name", "month", 
                "labor_force", "employed", "unemployed", "unemployment_rate")) %>% 
  mutate(fips = paste0(str_trim(state_fips), str_trim(county_fips))) %>% 
  select(-c(location, state_fips, county_fips, county_name)) %>% 
  mutate(month = str_trim(month)) %>% 
  mutate(month = ymd(paste0("20", substr(month, 5, 6),
                            "-", substr(month, 1 ,4), "01"))) %>% 
  mutate(across(c(employed, unemployed, labor_force),
                ~ str_remove(., ",")),
         across(c(employed, unemployed, labor_force, unemployment_rate),
                   as.numeric)) %>% 
  select(fips, month, everything())


write_csv(emp,
          here::here("data",
                     "monthly-county-employment.csv"))



# COVID restrictions ------------------------------------------------------

state_restrictions <- read_csv(here::here("data-raw", "50 States Overview.csv")) %>% 
  select(-x, -y) %>% 
  janitor::clean_names() %>% 
  select(-orders_issued_by_agencies,
         -orders_issued_by_government,
         -max_suspension_count) %>% 
  left_join(unique(select(fips, state_name, state_code)),
            by = c("state" = "state_name")) %>% 
  select(-state)

write_csv(state_restrictions,
          here::here("data",
                     "state-covid-restrictions.csv"))



