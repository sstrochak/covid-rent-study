

library(tidyverse)


data <- read_csv(here::here("data",
                            "monthly-county-combined-dataset.csv"))



nat_over_time <- data %>% 
  group_by(month) %>% 
  summarize(`Rent index` = mean(rent_index, na.rm = TRUE),
            `Home prices index` = mean(zhvi_index, na.rm = TRUE),
            `Average temperatue` = mean(avg_temp, na.rm = TRUE),
            `COVID cases` = mean(cases, na.rm = TRUE),
            `COVID deaths` = mean(deaths, na.rm = TRUE),
            `Unemployment rate` = mean(unemployment_rate, na.rm = TRUE),
            `Mortgage rate` = mean(pmms, na.rm = TRUE)) %>% 
  filter(month > "2020-01-01",
         month <= "2020-12-01")



nat_over_time %>% 
  gather(key = "metric", value = "value", -month) %>% 
  ggplot(aes(x = month, y = value)) +
    geom_line() +
    facet_wrap(~metric, scales = "free") +
  theme_minimal() +
  labs(x = NULL, y = NULL)

ggsave(here::here("figures",
                  "avg-stats-over-time.png"),
       width = 7.5, height = 5)


all_stats <- data %>% 
  filter(month > "2020-01-01",
         month <= "2020-12-01") %>% 
  select(`Rent index` = rent,
         `Home price index` = zhvi_index,
         `Average temperature` = avg_temp,
         `COVID cases` = cases,
         `COVID deaths` = deaths,
         `Unemployment rate` = unemployment_rate,
         Population = population,
         `Population density` = population_per_sqmile,
         `Rural classification` = rural_classification,
         `Mortgage rate` = pmms) %>% 
  ungroup()

modelsummary::datasummary_skim(all_stats)
