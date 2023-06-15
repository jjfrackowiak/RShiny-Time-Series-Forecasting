##### Install theses packages on first run ####
# install.packages("shiny")
# install.packages("readr")
# install.packages("xts")
#install.packages("anytime")

##############################################3
library(shiny)
library(readr)
library(xts)
library(tidyr)
library(Rcpp) 
library(forecast)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
runApp("app")