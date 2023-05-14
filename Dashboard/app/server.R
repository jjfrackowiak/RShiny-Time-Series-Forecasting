shinyServer(function(input, output, session) {
    
    
    # Update info widget with text description
    output$info_widget <- renderPrint({
        cat("This app allows to preprocess data and demostrate output of
            the best model of ARIMA class, together with forecast and report.
            You should not:
            - load data in other frequency then daily
            - load non-numerical features
            Missing values will be interpolated or removed.")
    })
    
    # Load data
    data <- reactive({
        req(input$file)
        df <- read.csv(input$file$datapath, sep = input$sep)
    })
    
    # Update date column choices based on uploaded data
    observeEvent(data(), {
        updateSelectInput(session, inputId = "date_col", label = "Select the date column",
                          choices = names(data()))
    })
    
    # Update variable choices based on uploaded data
    observeEvent(data(), {
        
        # Get list of all variable names (excluding date column)
        all_vars <- names(data())[names(data()) != input$date_col]
        
        # Update select input for dependent variable
        updateSelectInput(session, inputId = "dependent_var", label = "Select dependent variable",
                          choices = all_vars)
        
        # Update checkbox group input for independent variables
        updateCheckboxGroupInput(session, inputId = "independent_vars", label = "Select independent variables",
                                 choices = all_vars)
    })
    
    # Transform data to time series based on selected granularity
    ts_data <- reactive({
        
        #dealing with missing values
        #C++ function for linear interpolation of values
        sourceCpp("linear_interp.cpp")
        
        data <- data()
        data <- data[!(is.na(data[input$date_col]) | data[input$date_col] == ""), ]
        df_interpolated <- apply(data[,-match(input$date_col, names(data))], 2, interpolate)
        
        #transforming to xts object
        ts_date <-as.Date(data[[input$date_col]], tryFormats = c("%Y-%m-%d",
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
        
        granularity <- switch(input$granularity,
                              "Daily" = "daily",
                              "Monthly" = "monthly",
                              "Quarterly" = "quarterly",
                              "Yearly" = "yearly") 
        
        ts_df = xts(df_interpolated,
                    order.by = ts_date,
                    frequency = granularity)
        
        #importing convert_xts function changing frequencies of xts obj.
        source("convert_xts.R")
        ts_df = convert_xts(ts_df, granularity)
    })
    
    observeEvent(input$suggest_model, {
        print(ts_data())
        #ts_vars <- ts_data()[,input$independent_vars]
        #print(summary(ts_vars))
    })
    
    
    
    in_sample_indices = list()
    out_of_sample_indices = list()
})
