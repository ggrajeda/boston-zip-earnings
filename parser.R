# return standardized form of data
standardize <- function(data) {
  # standardize name for regular pay column
  if("REGULAR" %in% colnames(data)) {
    data$REGULAR <- as.numeric(data$REGULAR)
  } else if("Regular" %in% colnames(data)) {
    data$REGULAR <- as.numeric(data$Regular)
  }

  # standardize name for ZIP column
  if("POSTAL" %in% colnames(data)) {
    data$POSTAL  <- as.numeric(data$POSTAL)
  } else if("ZIP" %in% colnames(data) & (year == 2012 | year == 2013)) {
    data$POSTAL  <- as.numeric(substr(data$ZIP, 0, 5))
  } else if("ZIP" %in% colnames(data)) {
    data$POSTAL  <- as.numeric(data$ZIP)
  } else if("Zip Code" %in% colnames(data)) {
    data$POSTAL  <- as.numeric(substr(data$`Zip Code`, 0, 5))
  }

  # standardize name for department column
  if("Department Name" %in% colnames(data)) {
    data$DEPARTMENT <- data$`Department Name`
  } else if("DEPARTMENT NAME" %in% colnames(data)) {
    data$DEPARTMENT <- data$`DEPARTMENT NAME`
  } else if("DEPARTMENT_NAME" %in% colnames(data)) {
    data$DEPARTMENT <- data$DEPARTMENT_NAME
  }

  # standardize name for title column
  if("Title" %in% colnames(data)) {
    data$TITLE <- data$Title
  }
  return(data)
}