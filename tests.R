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
names(ts_df)

source("Dashboard/app/convert_xts.R")

ts_df  = convert_xts(ts_df, "quarterly")

names(ts_df) <- c("r","x")
ts_df
min(index(ts_df))
max(index(ts_df))
cut_75 = index(ts_df)[floor(0.75*length(index(ts_df)))]
cut_75
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

format = "%Y-%m-%d"
}
if (input$granularity == "Monthly"){
  format = "%b %Y"
}
if (input$granularity == "Quarterly"){
  format = "%Y Q%q"
}
if (input$granularity == "Yearly"){
  format = "%Y"

d = "2022-11-05"
m = "Oct 2022"
q = "2022 Q4"
y = 2022

cut_75_d = as.character(m)
format = "%Y-%m-%d"

cut_75_d = as.Date(cut_75_d, "%b %Y")
class(m)

cut_75_d

convert_yearly_dates(index(ts_df))

index(ts_df)

convert_yearly_dates <- function(xts_obj) {
  # Get the year from the list argument
  year <- as.numeric(format(as.character(xts_obj), "%Y"))
  
  # Construct the date string for the last day of each year
  date_string <- paste(year, "12", "31", sep = "-")
  
  # Convert the date string to Date format
  year_dates <- as.Date(date_string)
  
  return(year_dates)
}
