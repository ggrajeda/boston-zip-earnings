#################################################################################
# NOTE: Cartogram code adapted from:                                            #
# https://www.r-graph-gallery.com/331-basic-cartogram.html                      #
#################################################################################

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

#################################################################################
# CODE                                                                          #
#################################################################################

# Write your own directory here
setwd("~/GitHub/ggrajeda.github.io/boston-zip-earnings")

get_chart <- function() {
  neighbs      <- geojson_read("ZIP_Codes.geojson", what="sp")
  
  neighbs@data$ZIP5      <- as.numeric(neighbs@data$ZIP5)
  median_regular         <- rep(0, length(neighbs@data$ZIP5))
  for (i in 1:length(neighbs@data$ZIP5))
    median_regular[i]    <- median(data$REGULAR[which(data$POSTAL == neighbs@data$ZIP5[i])], na.rm = TRUE)
  neighbs@data['SALARY'] <- median_regular
  
  centroids            <- coordinates(neighbs)
  neighbs@data['long'] <- centroids[,1]
  neighbs@data['lat']  <- centroids[,2]
  
  neighbs_st <- st_transform(st_as_sf(neighbs), crs = "+proj=longlat")
  p <-  ggplot() + geom_sf(data = neighbs_st, mapping = aes(fill = SALARY/1000), lwd = 0, color = NA) +
    theme_void() +
    scale_fill_viridis(name="Median Salary", breaks = c(35,50,65,80,95), labels = c("$35k","$50k","$65k","$80k","$95k"), 
                       option = "C", guide = guide_legend( keyheight = unit(3, units = "mm"), keywidth = unit(12, units = "mm"),
                                                           label.position = "bottom", title.position = 'top', title.hjust = 0.5, color = "white")) +
    labs(title = "Boston, MA", subtitle=paste("City Employee Earnings per ZIP Code (",year,")", sep="")) +
    theme(
      text = element_text(color = "#22211d"), 
      plot.background = element_rect(fill = "#f5f5f4", color = NA), 
      panel.background = element_rect(fill = "#f5f5f4", color = NA), 
      legend.background = element_rect(fill = "#f5f5f4", color = NA),
      plot.title = element_text(size= 22, hjust=0.5, color = "#4e4d47"),
      plot.subtitle = element_text(size= 13, hjust=0.5, color = "#4e4d47"),
      legend.position = "bottom"
    )
  ggsave(path="images", filename=paste("zip_earnings", year, "_noid", ".png", sep=""), plot = p)
  return(p)
}

for(year in c(2011:2019)) {
  data <- read_excel(paste("data/earnings",year,".xlsx", sep=""))
  
  if("REGULAR" %in% colnames(data)) {
    data$REGULAR <- as.numeric(data$REGULAR)
  } else if("Regular" %in% colnames(data)) {
    data$REGULAR <- as.numeric(data$Regular)
  }
  if("POSTAL" %in% colnames(data)) {
    data$POSTAL  <- as.numeric(data$POSTAL)
  } else if("ZIP" %in% colnames(data) & (year == 2012 | year == 2013)) {
    data$POSTAL  <- as.numeric(substr(data$ZIP, 0, 5))
  } else if("ZIP" %in% colnames(data)) {
    data$POSTAL  <- as.numeric(data$ZIP)
  } else if("Zip Code" %in% colnames(data)) {
    data$POSTAL  <- as.numeric(substr(data$`Zip Code`, 0, 5))
  }
  
  plot(get_chart())
}
