# Project description:

This repository stores all files neccessary to run time-series forecasting dashboard 
built in RShiny package as a final project for Advanced R classes on 
Warsaw University’s Faculty of Economics' Data Science programme.

After loading CSV file with data (in daily frequency) and specifying desired model parameters:

- dependent variable name
- independent variables names (if any)
- seasonality 
- desired data frequency
- max number of moving-average terms to consider
- max number of autoregressive terms to consider
- max number of differences to consider
- out-of-sample period

the app estimates an optimal model of (S)ARIMA(X) class
and produces a report including diagnostic plots, plotted forecast 
and model performance measures.

# How to launch the project:

After downloading "Dashboard" folder, the app can be launched by running 
```
launcher.R 
```
file which intialises a Shiny window.
RStudio also supports running the app in browser window.

We are also providing an exemplary CSV containg SP500 quotations 
which can be fed into the dashboard as any other data registered in daily frequency.

<b>Authors:</b><br/>
Antek Piotrowski <br/>
Anirban Das <br/>
Jan Frąckowiak <br/>


