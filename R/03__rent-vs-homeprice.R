

library(tidyverse)


data <- read_csv(here::here("data",
                            "monthly-county-combined-dataset.csv"))



data_rent <- data %>% 
  select(fips, county_name, month,
         starts_with("rent"),
         starts_with("zhvi")) 



plot_rent_v_homeprice <- function(my_fips) {
  
  
  name <- data_rent %>% 
    filter(fips == my_fips) %>% 
    pull(county_name) %>% 
    unique()
  
  d <- data_rent %>% 
    filter(fips == my_fips) %>% 
    select(fips, month, rent_index, zhvi_index) %>% 
    gather(key = "tenure", value = "index", -fips, -month) %>% 
    mutate(tenure = ifelse(tenure == "rent_index",
                           "Rent index",
                           "Home value index"))
  
  
  p <- ggplot(data = d,
         aes(x = month, y = index, 
             group = tenure, color = tenure)) +
    geom_line() +
    labs(x = "Month", y = "Index", 
         color = NULL,
         title = paste0("Rent and home price changes in ", name))
  
  ggsave(here::here("figures",
                    paste0("Rent and home price changes in ", name, ".png")))
  
  print(p)
  
}

plot_rent_v_homeprice("06075")
plot_rent_v_homeprice("36061")
plot_rent_v_homeprice("51013")
plot_rent_v_homeprice("45057")
