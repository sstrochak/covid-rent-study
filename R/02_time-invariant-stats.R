
library(tidyverse)


data <- read_csv(here::here("data",
                            "monthly-county-combined-dataset.csv"))


county <- data %>% 
  ungroup() %>% 
  group_by(state, fips, county_name) %>% 
  summarize(starting_rent = rent_overall[month == "2021-02-01"], 
            overall_rent_change = 
              (rent_overall[month == "2020-12-01"] - rent_overall[month == "2020-02-01"]) 
            / rent_overall[month == "2020-02-01"],
            rural_class = rural_classification[1],
            population_per_sqmile = population_per_sqmile[1],
            cases_per_capita = sum(cases, na.rm = TRUE) / population[1])



county %>% 
  group_by(rural_class) %>% 
  summarize(counties = n(),
            mean_overall_rent_change = mean(overall_rent_change, na.rm = TRUE),
            median_overall_rent_change = median(overall_rent_change, na.rm = TRUE))

ggplot(county, mapping = aes(x = starting_rent, y = overall_rent_change)) +
  geom_point() +
  geom_smooth(method = "lm")


ggplot(county, mapping = aes(x = cases_per_capita, y = overall_rent_change)) +
  geom_point() +
  geom_smooth(method = "lm")


lm(overall_rent_change ~ cases_per_capita,
   data = county)

m1 <- lm(overall_rent_change ~ starting_rent + I(starting_rent^2),
         data = county)
summary(m1)
plot(m1)


sf <- data %>% 
  filter(fips == "36061") %>% 
  select(month, rent_index) %>% 
  gather(key = "bedrooms", value = "rent", -month)

ggplot(sf, mapping = aes(x = month, y = rent, 
                         color = bedrooms, group = bedrooms)) +
  geom_line()

ggplot(sf, mapping = aes(x = month, y = rent, 
                         color = bedrooms, group = bedrooms)) +
  geom_line()
