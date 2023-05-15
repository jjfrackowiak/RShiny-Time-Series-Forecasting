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
            fileInput("file", "Upload a CSV file with the data in daily frequency",
                      accept = c(".csv")),
            
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                         selected = ","),
            
            # Date column
            selectInput(inputId = "date_col", label = "Select the date column",
                        choices = NULL),
            
        
            # Granularity
            selectInput(inputId = "granularity", label = "Select desired time granularity",
                        choices = c("Daily", "Monthly", "Quarterly", "Yearly")),
            
            # Variable selection
            selectInput(inputId = "dependent_var", label = "Select dependent variable", choices = NULL),
            checkboxGroupInput(inputId = "independent_vars", label = "Select independent variables", choices = NULL),
            
            #out-of-sample period
            sliderInput(inputId = "out_of_sample_period", label = "Select the out-of-sample period",
                        min = as.Date("2006-01-01","%Y-%m-%d"),
                        max = as.Date("2016-12-01","%Y-%m-%d"),
                        value=c(as.Date("2016-09-01"), as.Date("2016-12-01")), timeFormat="%Y-%m-%d", ticks = FALSE)),
            
            # Button to suggest optimal model and generate report
            actionButton(inputId = "suggest_model", label = "Create best model and generate report")
            
        ),
        
        # Main panel
        mainPanel(
            
            # Report (Could be printable as PDF)
            
        )
        
    )
)
