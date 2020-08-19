######################################################################################
# NOTE: Choropleth code adapted from:                                                #
# https://www.r-graph-gallery.com/327-chloropleth-map-from-geojson-with-ggplot2.html #                    #
######################################################################################

# install.packages("readxl")
library(readxl)
# install.packages("ggmap")
library(ggmap)
# install.packages("ggplot2")
library(ggplot2)
# install.packages("geojsonio")
library(geojsonio)
# install.packages("broom")
library(broom)
library(viridis)
# install.packages("sf")
library(sf)
# install.packages("sp")
library(sp)
# install.packages("cartogram")
library(cartogram)
# install.packages("ggspatial")
library(ggspatial)
# install.packages("showtext")
library(showtext)

# Write your own directory here
setwd("~/GitHub/boston-zip-earnings")

# Fonts (uncomment if needed, it takes a while)
font_add_google("Zilla Slab", "zillas")
showtext_auto()

source("plotter.R")
source("parser.R")

################################################################################
# MAIN FUNCTION                                                                #
################################################################################

neighbs              <- geojson_read("ZIP_Codes.geojson", what="sp")
neighbs@data$ZIP5    <- as.numeric(neighbs@data$ZIP5)

centroids            <- coordinates(neighbs)
neighbs@data['long'] <- centroids[,1]
neighbs@data['lat']  <- centroids[,2]

# main plots
for(year in c(2011:2019)) {
  data <- read_excel(paste("data/earnings",year,".xlsx", sep=""))
  data <- standardize(data)

  plot(get_choropleth(data, neighbs, year))
  plot(get_common_jobs(data, year))
  plot(get_subset_choropleth(data[data$TITLE == "Teacher",], neighbs, year, "Teacher"))
  plot(get_subset_choropleth(data[data$TITLE != "Teacher",], neighbs, year, "Non-Teacher"))
}

# auxiliary analysis
teacher_median     <- rep(0, 9)
non_teacher_median <- rep(0, 9)

for(year in c(2011:2019)) {
  data <- read_excel(paste("data/earnings",year,".xlsx", sep=""))
  data <- standardize(data)
  
  teachers     <- data[data$TITLE == "Teacher",]
  non_teachers <- data[data$TITLE != "Teacher",]

  teacher_median[year-2010]     <- median(teachers$REGULAR, na.rm = TRUE)
  non_teacher_median[year-2010] <- median(non_teachers$REGULAR, na.rm = TRUE)
}
