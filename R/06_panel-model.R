
library(tidyverse)
library(modelsummary)

data <- read_csv(here::here("data",
                            "monthly-county-combined-dataset.csv"))


# create summarized dataset  ----------------------------------------------


pit <- data %>% 
  group_by(fips, county_name) %>% 
  summarize(population = mean(population),
            population_per_sqmile = mean(population_per_sqmile),
            rural_classifiction = mean(rural_classification, na.rm = TRUE),
            total_covid_cases = sum(cases, na.rm = TRUE),
            cases_per_capita = total_covid_cases / population,
            total_covid_deaths = sum(deaths, na.rm = TRUE),
            deaths_per_capita = total_covid_deaths / population,
            total_executive_orders = mean(total_executive_orders),
            governor_party = governor_party[1],
            jan_temp = avg_temp[month == "2021-01-01"],
            july_temp = avg_temp[month == "2020-07-01"],
            rent_now = rent[month == "2021-02-01"],
            rent_then = rent[month == "2020-02-01"],
            homeprice_now = zhvi[month == "2021-02-01"],
            homeprice_then = zhvi[month == "2020-02-01"],
            pmms_change = pmms[month == "2020-03-01"] - pmms[month == "2020-02-01"],
            rent_change = (rent_now - rent_then) / rent_then,
            homeprice_change = (homeprice_now - homeprice_then) / homeprice_then,
            unemployment_rate_change = unemployment_rate[month == "2020-02-01"] -
              unemployment_rate[month == "2021-02-01"]) %>% 
  ungroup()




# model -------------------------------------------------------------------

count(pit, rural_classifiction)


m1 <- lm(rent_change ~ cases_per_capita +
           deaths_per_capita +
           jan_temp +
           population_per_sqmile + 
           unemployment_rate_change,
         data = pit)

m2 <- lm(homeprice_change ~ cases_per_capita +
           deaths_per_capita +
           jan_temp +
           population_per_sqmile + 
           unemployment_rate_change,
         data = pit)

modelsummary(list("Rent change" = m1,
                  "Home price change" = m2),
             stars = TRUE,
             vcov = "HC1",
             gof_omit = "AIC|BIC|Log.Lik")


modelplot(list("Rent change" = m1,
               "Home price change" = m2))
ggsave(here::here("figures",
                  "time-invariant-model-plot.png"))
