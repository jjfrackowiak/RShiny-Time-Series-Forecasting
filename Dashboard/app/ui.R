shinyUI(fluidPage(

    # Application title
    titlePanel("Optimal (S)ARIMA(X) Model"),

    # Sidebar layout
    sidebarLayout(
        
        # Sidebar panel
        sidebarPanel(
            # Info widget
            htmlOutput("formatted_text"),
            
            #File Input
            radioButtons("sep", "Expected data separator",
                         choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                         selected = ","),
            
            fileInput("file", "Upload a CSV file with the data in daily frequency",
                      accept = c(".csv")),
            
            
            
            # Date column
            selectInput(inputId = "date_col", label = "Select the date column",
                        choices = NULL),
            
        
            # Granularity
            selectInput(inputId = "granularity", label = "Select desired time granularity",
                        choices = c("Daily", "Monthly", "Quarterly", "Yearly")),
            
            # Variable selection
            selectInput(inputId = "dependent_var", label = "Select dependent variable", choices = NULL),
            checkboxGroupInput(inputId = "independent_vars", label = "Select independent variables", choices = NULL),
            
            # Seasonality
            radioButtons("ses", "Seasonality",
                         choices = c(True = "True", False = "False"),
                         selected = "False"),
            
            #Max number of differences
            numericInput(
              inputId = "max_diff",
              label = "Max. number of differeces",
              value = 1,
              min = 0,
              max = 4,
              step = 1
              #width = NULL
            ),
            
            #Max number of autoregressive terms
            numericInput(
              inputId = "max_auto",
              label = "Max. number of autoregressive terms",
              value = 3,
              min = 1,
              max = 15,
              step = 1
              #width = NULL
            ),
            
            #Max number of MA terms
            numericInput(
              inputId = "max_ma",
              label = "Max. number of moving average terms",
              value = 3,
              min = 0,
              max = 10,
              step = 1
              #width = NULL
            ),
            
            #out-of-sample period
            sliderInput(inputId = "out_of_sample_period", label = "Select the out-of-sample period",
                        min = as.Date("2006-01-01","%Y-%m-%d"),
                        max = as.Date("2016-12-01","%Y-%m-%d"),
                        value=c(as.Date("2016-09-01"), as.Date("2016-12-01")), timeFormat="%Y-%m-%d", ticks = FALSE),
            
            # Button to suggest optimal model and generate report
            actionButton(inputId = "suggest_model", label = "Create best model and generate report")

        ),
        
        # Main panel
        mainPanel(
          
          #Plots and text
          plotOutput("diagnostic_plot")#,
          br(),
          plotOutput("forecast_plot"),
          br(),
          strong(textOutput("MAPE")),
          br(),
          strong(textOutput("MAE")),
          br(),
          strong(textOutput("MSE")),
          br()

        )
        
    ))
)

