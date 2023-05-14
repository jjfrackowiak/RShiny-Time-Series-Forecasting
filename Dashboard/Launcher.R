##### Install theses packages on first run ####
# install.packages("shiny")
# install.packages("readr")
# install.packages("xts")
#install.packages("anytime")

##############################################

# You need to install tinytex for generating the PDF
# tinytex::install_tinytex()

library(shiny)
library(readr)
library(xts)
library(tidyr)
library(Rcpp)


setwd(dirname(rstudioapi::getSourceEditorContext()$path))
runApp("app")