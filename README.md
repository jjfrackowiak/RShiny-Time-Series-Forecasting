# Project description

This repository stores all files necessary to run time-series forecasting dashboard built <br/>
in RShiny package as a final project for Advanced R classes on Warsaw University's <br/>
Faculty of Economics' Data Science programme. 

# Dashboard visual layout

<img width="1792" alt="Screenshot 2023-06-17 at 12 31 35" src="https://github.com/jjfrackowiak/RShiny-Time-Series-Forecasting/assets/84077365/04ddb280-7a11-465b-8be6-200df6c3d8ec">

# How to launch and use the app

After downloading "Dashboard" folder, the app can be launched by running 
```
Launcher.R
```
file, which initialises a Shiny window. RStudio also supports running the app in browser mode. <br/>

After loading CSV file with data (in daily frequency) and specifying desired model parameters: 

- dependent variable name
- independent variables names (if any)
- seasonality
- desired data frequency
- max number of moving-average terms to consider
- max numer of autoregressive terms to consider
- max number of differences to consider
- out-of-sample period

the app estimates an optimal model of (S)ARIMA(X) class and produces a report <br/>
including diagnostic plots, plotted forecast and model performance measures. <br/>

We are also providing with exemplary data files containing stock quotations, which <br/>
can be loaded to the dashboard as any other data in daily frequency. <br/>

<b>Authors</b> <br/>
Antoni Piotrowski <br/>
Anirban Das <br/>
Jan Frąckowiak


