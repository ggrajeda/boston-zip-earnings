######################################################################################
# NOTE: Choropleth code adapted from:                                                #
# https://www.r-graph-gallery.com/327-chloropleth-map-from-geojson-with-ggplot2.html #                    #
######################################################################################

# plot choropleth according to median salary
get_choropleth <- function(data, neighbs, year) {
  zip_count  <- transform(table(data$POSTAL))
  common_zip <- zip_count$Var1[zip_count$Freq >= 20]
  data       <- data[data$POSTAL %in% common_zip,]

  median_regular         <- rep(0, length(neighbs@data$ZIP5))
  for (i in 1:length(neighbs@data$ZIP5))
    median_regular[i]    <- median(data$REGULAR[which(data$POSTAL == neighbs@data$ZIP5[i])], na.rm = TRUE)
  neighbs@data['SALARY'] <- median_regular

  neighbs_st <- st_transform(st_as_sf(neighbs), crs = "+proj=longlat")
  p <-  ggplot() + geom_sf(data = neighbs_st, mapping = aes(fill = SALARY/1000), lwd = 0, color = NA) +
    theme_void() +
    scale_fill_viridis(name="Median Salary", breaks = c(30,50,70,90,110), labels = c("$30k","$50k","$70k","$90k","$110k"), limits = c(0,150),
                       option = "C", guide = guide_legend( text.width = 1, keyheight = unit(5, units = "mm"), keywidth = unit(20, units = "mm"),
                                                           label.position = "bottom", title.position = 'top', title.hjust = 0.5, color = "white")) +
    labs(title = "Boston, MA", subtitle=paste("City Employee Earnings per ZIP Code (",year,")", sep="")) +
    theme(
      text = element_text(color = "#22211d", size = 60, family = "zillas"), 
      plot.background = element_rect(fill = "white", color = NA), 
      panel.background = element_rect(fill = "white", color = NA), 
      legend.background = element_rect(fill = "white", color = NA),
      plot.title = element_text(size = 150, hjust = 0.5, color = "#4e4d47"),
      plot.subtitle = element_text(size = 90, hjust = 0.5, color = "#4e4d47"),
      legend.position = "bottom",
      legend.text  = element_text(margin = margin(t = -25, b = 0)),
      legend.title = element_text(size = 70, margin = margin(t = 0, b = -20))
    )
  png(paste("images/zip_earnings", year, "_noid.png", sep=""), width=300, height=300, units="mm", res=300,
      pointsize = 12)
  plot(p)
  dev.off()
  return(p)
}

# plot five most common jobs
get_common_jobs <- function(data, year) {
  common_jobs     <- transform(sort(table(data$TITLE),decreasing = TRUE)[1:5])
  common_jobs$Job <- as.character(common_jobs$Var1)
  common_data     <- data[data$TITLE %in% common_jobs$Job,]
  p <- ggplot(data = common_jobs, aes(x = reorder(Job, + Freq), y = Freq, fill = as.factor(Freq))) + geom_bar(stat = "identity") +
    xlab("") + ylab("Count") + ylim(0,6000) + theme_minimal() +
    scale_fill_brewer(palette = "GnBu") +
    theme(
      text = element_text(color = "#22211d", size = 60,family="zillas"), 
      plot.background = element_rect(fill = "white", color = NA), 
      plot.title = element_text(size = 120, hjust = 0.5, color = "#4e4d47"),
      plot.subtitle = element_text(size = 90, hjust = 0.5, color = "#4e4d47"),
      axis.text = element_text(size = 70),
      axis.title = element_text(size = 80, hjust=0.5),
      legend.position = "none"
    ) +
    labs(title = paste("Most Common Positions ", "(", year, ")", sep="")) +
    coord_flip()
  png(paste("images/job_freq", year, ".png", sep=""), width=300, height=300, units="mm", res=300,
      pointsize = 12)
  plot(p)
  dev.off()
  return(p)
}

# plot choropleth according to median salary of a given subset
get_subset_choropleth <- function(data, neighbs, year, subset) {
  zip_count  <- transform(table(data$POSTAL))
  common_zip <- zip_count$Var1[zip_count$Freq >= 20]
  data       <- data[data$POSTAL %in% common_zip,]

  median_regular         <- rep(0, length(neighbs@data$ZIP5))
  for (i in 1:length(neighbs@data$ZIP5))
    median_regular[i]    <- median(data$REGULAR[which(data$POSTAL == neighbs@data$ZIP5[i])], na.rm = TRUE)
  neighbs@data['SALARY'] <- median_regular
  
  neighbs_st <- st_transform(st_as_sf(neighbs), crs = "+proj=longlat")
  p <-  ggplot() + geom_sf(data = neighbs_st, mapping = aes(fill = SALARY/1000), lwd = 0, color = NA) +
    theme_void() +
    scale_fill_viridis(name="Median Salary", breaks = c(30,50,70,90,110), labels = c("$30k","$50k","$70k","$90k","$110k"), limits = c(0,150),
                       option = "C", guide = guide_legend( text.width = 1, keyheight = unit(5, units = "mm"), keywidth = unit(20, units = "mm"),
                                                           label.position = "bottom", title.position = 'top', title.hjust = 0.5, color = "white")) +
    labs(title = "Boston, MA", subtitle=paste(subset, " Earnings per ZIP Code (",year,")", sep="")) +
    theme(
      text = element_text(color = "#22211d", size = 60, family = "zillas"), 
      plot.background = element_rect(fill = "white", color = NA), 
      panel.background = element_rect(fill = "white", color = NA), 
      legend.background = element_rect(fill = "white", color = NA),
      plot.title = element_text(size = 150, hjust = 0.5, color = "#4e4d47"),
      plot.subtitle = element_text(size = 90, hjust = 0.5, color = "#4e4d47"),
      legend.position = "bottom",
      legend.text  = element_text(margin = margin(t = -25, b = 0)),
      legend.title = element_text(size = 70, margin = margin(t = 0, b = -20))
    )
  png(paste("images/zip_earnings_", tolower(subset), year, "_noid.png", sep=""), width=300, height=300, units="mm", res=300,
      pointsize = 12)
  plot(p)
  dev.off()
  return(p)
}