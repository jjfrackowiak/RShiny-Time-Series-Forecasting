##### Install theses packages on first run ####
# install.packages("shiny")
# install.packages("readr")
# install.packages("xts")
# install.packages("anytime")
# install.packages("shinythemes")

##############################################3
library(shiny)
library(readr)
library(xts)
library(tidyr)
library(Rcpp) 
library(forecast)
library(shinythemes)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
runApp("app")
