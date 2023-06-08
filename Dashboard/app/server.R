shinyServer(function(input, output, session) {
    
    
    # Update info widget with text description
    output$formatted_text <- renderText({
      HTML("<p style='font-size: 14px; text-align: justify;'>
            <b>App description:</b><br>
            This app allows to preprocess data and demostrate output of<br>
            the best model of (S)ARIMA(X) class, together with forecast and report.<br><br>
            You should not:<br>
            - load data in other frequency then daily<br>
            - load non-numerical features<br><br>
            Missing values will be interpolated or removed.<br>
            Data in daily frequency is accepted in multiple formats<br><br>
            </p>")
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
        req(input$file)
        req(input$granularity)
        
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
    
    observeEvent(c(input$granularity, input$date_col),{
        
        #requirements
        req(input$file)
        req(input$granularity)
        
        #Update out of sample slider group input for independent variables
        ts_df = ts_data()
        
        if (input$granularity=="Daily"){
        #all dates necessary for the out-of-sample slider
        cut_75_d = index(ts_df)[ceiling(0.75*length(index(ts_df)))]
        cut_75_d = as.Date(cut_75_d, format)
        min_d = as.Date(min(index(ts_df)), format)
        max_d = as.Date(max(index(ts_df)), format)
        values_d = c(cut_75_d, max_d)
  
        updateSliderInput(session, inputId = "out_of_sample_period", label = "Select the out-of-sample period",
                          min = min_d,
                          max = max_d,
                          value = values_d,
                          timeFormat= "%Y-%m-%d")}
        else {
        cut_75_d = ceiling(0.75*length(index(ts_df)))
        min_d = 1
        max_d = length(index(ts_df))
        values_d = c(cut_75_d, max_d)
        
        updateSliderInput(session, inputId = "out_of_sample_period", label = "Select the out-of-sample indices",
                          min = min_d,
                          max = max_d,
                          value = values_d, step = 1)}
        
    })
    
    #generating dict. with info to be fed into our decomposition pipeline and 
    #our models (After clicking "Suggest model" button)
    #elements can be accessed like: model_info_named_list$key (eg. xts_obj)
    observeEvent(input$suggest_model, {
        req(input$file)
      
        xts_for_model = ts_data()
        
        model_info_named_list = list(
        "xts_obj" = xts_for_model,
        "out_of_sample_indices" = input$out_of_sample_period, #dates in case of daily data, indices in other cases
        "selected_dep_var_names" = input$dependent_var,
        "selected_indep_vars_names" = input$independent_vars,
        "chosen_frequency" = input$granularity,
        "ses" = input$ses, 
        "max_auto" = input$max_auto,
        "max_ma" = input$max_ma, 
        "max_diff" = input$max_diff
        )
        
        print(model_info_named_list)
    })
})
