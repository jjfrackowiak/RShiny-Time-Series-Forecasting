library(anytime)
library(xts)
library(readr)
library(lubridate)
install.packages('parsedate')
library(parsedate)
library(Rcpp)

data = read.csv("random_data.csv")

#dealing with missing values
#C++ function for linear interpolation of values
sourceCpp("Dashboard/app/linear_interp.cpp")


data <- data[!(is.na(data["Date"])|data["Date"]==""), ]

data <- data()[!(is.na(data()[input$date_col]) | data()[input$date_col]), ]

df_interpolated <- apply(data[,-match(input$date_col, names(data))], 2, interpolate)


df_interpolated <- apply(data[,-match("Date", names(data))], 2, interpolate)
ts_date <-as.Date(data[["Date"]], tryFormats = c("%Y-%m-%d",
                                                  "%m/%d/%Y",
                                                  "%d/%m/%Y",
                                                  "%Y/%m/%d",
                                                  "%Y.%m.%d",
                                                  "%d-%b-%y",
                                                  "%b %d, %Y",
                                                  "%d %B %Y",
                                                  "%m/%d/%y",
                                                  "%d/%m/%y",
                                                  "%Y%m%d"))
ts_df = xts(df_interpolated,
            order.by = ts_date,
            frequency = 'daily')
ts_df

convert_xts(ts_df, "monthly")

# define function to convert xts object to lower frequency

convert_xts <- function(xts_obj, frequency) {
  # convert to monthly frequency
  if (frequency == "monthly") {
    xts_monthly <- aggregate(xts_obj, as.yearmon, mean)
    return(as.data.frame(xts_monthly))
  }
  
  # convert to quarterly frequency
  if (frequency == "quarterly") {
    xts_quarterly <- aggregate(xts_obj, as.yearqtr, mean)
    return(as.data.frame(xts_quarterly))
  }
  
  # convert to yearly frequency
  if (frequency == "yearly") {
    xts_yearly <- aggregate(xts_obj, as.numeric(format(index(xts_obj), "%Y")), mean)
    return(as.data.frame(xts_yearly))
  }
  
  # if frequency is not recognized, return original object
  return(as.data.frame(xts_obj))
}

