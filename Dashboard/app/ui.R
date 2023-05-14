library(shiny)
library(ggplot2)
library(plotly)
library(xts)
library(quantmod)
library(dygraphs)
library(tidyquant)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(zoo)
library(recommenderlab)
library(ggplot2)                       
library(data.table)
library(reshape2)
library(tidyr)
library(dtplyr) # dplyr is part of dtplyr
library(dplyr)
library(R6)
library(PBSmodelling)
library(rmarkdown)
library(shinybusy)


shinyUI(fluidPage(

    # Application title
    titlePanel("Optimal (S)ARIMA(X) Model"),

    # Sidebar layout
    sidebarLayout(
        
        # Sidebar panel
        sidebarPanel(
            
            #File Input
            fileInput("file", "Upload a CSV file with the data in daily frequency",
                      accept = c(".csv")),
            
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                         selected = ","),
            
            # Info widget
            verbatimTextOutput(outputId = "info_widget"),
            
            # Date column
            selectInput(inputId = "date_col", label = "Select the date column",
                        choices = NULL),
            
        
            # Granularity
            selectInput(inputId = "granularity", label = "Select time granularity",
                        choices = c("Daily", "Monthly", "Quarterly", "Yearly")),
            
            # Variable selection
            selectInput(inputId = "dependent_var", label = "Select dependent variable", choices = NULL),
            checkboxGroupInput(inputId = "independent_vars", label = "Select independent variables", choices = NULL),
            
            #out-of-sample period
            sliderInput(inputId = "out_of_sample_period", label = "Select the out-of-sample period",
                              min = 0, max = 1, value = c(0.5, 1), step = 0.01),
            
            # Button to suggest optimal model and generate report
            actionButton(inputId = "suggest_model", label = "Create best model and generate report")
            
        ),
        
        # Main panel
        mainPanel(
            
            # Summary table
            tableOutput(outputId = "summary_table")
            
        )
        
    )
))
