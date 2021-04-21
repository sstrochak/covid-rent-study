
library(tidyverse)
library(plm)
library(lmtest)
library(clubSandwich)
library(modelsummary)

options(scipen = 999)

data <- read_csv(here::here("data",
                            "monthly-county-combined-dataset.csv"))



# balanced panel ----------------------------------------------------------

### Select time frame and counties for which a balanced panel is available

data <- data %>% 
  filter(month >= "2020-01-01",
         month < "2021-03-01") %>% 
  mutate(across(c(cases, deaths),
                ~ ifelse(is.na(.),
                         0,
                         .))) %>% 
  mutate(cases_per_capita = cases / population,
         deaths_per_capita = deaths / population)



# models ------------------------------------------------------------------

## pooled

mod_pool_rent <- lm(rent_index ~ cases_per_capita + deaths_per_capita 
                    + avg_temp + unemployment_rate,
                    data = data)

mod_pool_own <-lm(zhvi_index ~ cases_per_capita + deaths_per_capita 
                  + avg_temp + unemployment_rate,
                  data = data)

modelsummary(list("Rent index" = mod_pool_rent, 
                  "Home price indec" = mod_pool_own),
             stars = TRUE,
             vcov = ~fips)


## County effects

## Time effects 

## County and time effects

## fixed effects 

# rolling 6-month model ---------------------------------------------------


