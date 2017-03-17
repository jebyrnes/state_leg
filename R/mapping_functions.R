library(rgdal)
library(dplyr)
library(broom)
#library(USAboundaries)
library(ggplot2)
library(forcats)
#https://www.census.gov/geo/maps-data/data/cbf/cbf_sld.html for shapefiles
# hoping districts are added tohttps://github.com/ropensci/USAboundaries


make_district_data <- function(shapefile, layer_name, votefile,
                               spatial_dir = "../spatial_data/",
                               vote_dir = "../clean_data/"){
  #Load shapefiles and fortify
  state_districts <- readOGR(paste0(spatial_dir, shapefile),
                             layer=layer_name,
                             stringsAsFactors=FALSE)
  state_districts_data <- state_districts %>% tidy
  state_districts_data$id <- as.numeric(state_districts_data$id)
  
  state_districts$id <- 0:(nrow(state_districts@data)-1)
  state_districts_data <- left_join(state_districts_data, state_districts@data) %>% 
    rename(District = NAME)
  
  state_districts_votes <- read.csv(paste0(vote_dir, votefile), stringsAsFactors = FALSE) 
  
  state_districts_combined <- left_join(state_districts_data, state_districts_votes) %>%
    mutate(Party = ifelse(is.na(Party), "No Election", Party)) %>%
    mutate(Party = factor(Party)) %>%
    mutate(Party = fct_relevel(Party, c("Democrat", "Republican", "Independent", "No Election"))) 
  
  state_districts_combined
}
# 
# ak_upper_combined <- make_district_data("cb_2015_02_sldu_500k", 
#                                         "cb_2015_02_sldu_500k",
#                                         "alaska_senate_2016.csv")
# 
# ggplot(ak_upper_combined, mapping=aes(x=long, y=lat, group=group, fill=Party)) +
#    geom_path() +
#   geom_polygon() + 
#   xlim(c(-180, -130)) +
#   theme_bw() +
#   scale_fill_manual(values = c("Blue", "Red", "White"))
#   
