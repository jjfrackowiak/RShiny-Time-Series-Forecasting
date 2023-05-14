library(xts)

convert_xts <- function(xts_obj, frequency) {
  # convert to monthly frequency
  if (frequency == "monthly") {
    xts_monthly <- aggregate(xts_obj, as.yearmon, mean)
    return(xts_monthly)
  }
  
  # convert to quarterly frequency
  if (frequency == "quarterly") {
    xts_quarterly <- aggregate(xts_obj, as.yearqtr, mean)
    return(xts_quarterly)
  }
  
  # convert to yearly frequency
  if (frequency == "yearly") {
    xts_yearly <- aggregate(xts_obj, as.numeric(format(index(xts_obj), "%Y")), mean)
    return(xts_yearly)
  }
  
  if (frequency == "daily") {
    return(xts_obj)
  }
  # if frequency is not recognized, return original object
  return(xts_obj)
}