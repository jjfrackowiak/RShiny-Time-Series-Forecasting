# Project description:

Time-series forecasting dashboard built in RShiny package proposing an optimal model of (S)ARIMA(X) class. 
After loading CSV file with data and specifying desired model parameters:

- dependent variable name
- independent variables names (if any)
- seasonality 
- desired data frequency
- max number of moving-average terms to consider
- max number of autoregressive terms to consider
- max number of differences to consider
- out-of-sample period

the app produces a report including diagnostic plots, plotted forecast 
and model performance measures.

# How to launch the project:

The project can be launch via running launcher.R file which intialises a Shiny window.
RStudio supports also running the app in browser window.

Authors:
Antek Piotrowski
Anirban Das
Jan Frąckowiak


