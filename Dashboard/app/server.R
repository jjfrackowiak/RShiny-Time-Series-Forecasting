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
        tryCatch({
        df <- read.csv(input$file$datapath, sep = input$sep)
        }, error = function(e){
          # Error handling code
          showNotification("Error occurred: ", conditionMessage(e), type = "error")
        })
    })
    
    
    # Update date column choices based on uploaded data
    observeEvent(data(), {
          tryCatch({
          updateSelectInput(session, inputId = "date_col", label = "Select the date column",
                          choices = names(data()))
          }, error = function(e){
            # Error handling code
            showNotification("Error occurred: ", conditionMessage(e), type = "error")
          })
    })
    
    # Update variable choices based on uploaded data
    observeEvent(data(), {
        
        tryCatch({
        # Get list of all variable names (excluding date column)
        all_vars <- names(data())[names(data()) != input$date_col]
        
        # Update select input for dependent variable
        updateSelectInput(session, inputId = "dependent_var", label = "Select dependent variable",
                          choices = all_vars)
        
        # Update checkbox group input for independent variables
        updateCheckboxGroupInput(session, inputId = "independent_vars", label = "Select independent variables",
                                 choices = all_vars)
        }, error = function(e){
          # Error handling code
          showNotification("Error occurred: ", conditionMessage(e), type = "error")
        })
    })
    
    # Transform data to time series based on selected granularity
    ts_data <- reactive({
        req(input$file)
        req(input$granularity)
        tryCatch({
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
        }, error = function(e){
          # Error handling code
          showNotification("Error occurred: ", conditionMessage(e), type = "error")
        })
        
    })
    
    observeEvent(c(input$granularity, input$date_col),{
        
        tryCatch({
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
    }, error = function(e){
      # Error handling code
      showNotification("Error occurred: ", conditionMessage(e), type = "error")
    })
        
    })
    
    #generating dict. with info to be fed into 
    #the model (After clicking "Suggest model" button)
    observeEvent(input$suggest_model, {
        req(input$file)
      
        xts_for_model = ts_data()
        
        out_of_sample_period <- input$out_of_sample_period
        
        if (input$granularity == "Daily"){
          dates <- index(xts_for_model)
          out_of_sample_start <- as.numeric(which(dates == out_of_sample_period[1]))
          out_of_sample_end <- as.numeric(which(dates == out_of_sample_period[2]))
          
          print("_______________________")
        }
        
        else{
          out_of_sample_start <- out_of_sample_period[1]
          out_of_sample_end <- out_of_sample_period[2]
          
          print("$$$$$$$$$$$$$$$$$$$$$$")
        }
        
        in_sample_start <- as.numeric(1)
        in_sample_end <- as.numeric(out_of_sample_start-1)
        
        print(in_sample_start)
        print(in_sample_end)
        
        decomposer <- setClass("decomposer",
                               slots = list(dataset = "ANY", date = "character", dependent = "character",
                                            independent = "ANY", gran = "character", seas = "character",
                                            max_aut = "character", max_d = "character"),
                               validity = function(object){
                                 return(TRUE)
                               })
        
        
        setGeneric(name = "auto_arima", 
                   def = function(x) {
                     standardGeneric(("auto_arima"))
                   })
        
        setMethod("auto_arima", signature = "decomposer",
                  definition = function(x){
                    data = x@dataset
                    main = x@dependent
                    indep = x@independent
                    m_a = as.integer(x@max_aut)
                    m_d = as.integer(x@max_d)
                    season = as.logical(x@seas)
                    model <- if (!is.null(indep)) 
                                        auto.arima(data[,main],
                                        xreg = as.matrix(data[, indep]),
                                        trace = TRUE,
                                        seasonal = season,
                                        stepwise = FALSE,
                                        approximation = FALSE,
                                        max.p = m_a,
                                        max.d = m_d) 
                            else auto.arima(data[,main],
                                      trace = TRUE,
                                      seasonal = season,
                                      stepwise = FALSE,
                                      approximation = FALSE,
                                      max.p = m_a,
                                      max.d = m_d
                    )
                    model
                  })
        
        decomposer <- new(Class = "decomposer", 
                          dataset = xts_for_model[in_sample_start:in_sample_end,],
                          date = input$date_col,
                          dependent = input$dependent_var,
                          independent = input$independent_vars,
                          gran = input$granularity,
                          seas = input$ses,
                          max_aut = as.character(input$max_auto),
                          max_d = as.character(input$max_diff))
        
        
        output$diagnostic_plot<- renderPlot({{
          #plotting diagnostic plots
          
          #trained_model < - auto_arima(decomposer)
          
          checkresiduals(auto_arima(decomposer))
          
          #checkresiduals(trained_model)
          
          
        }})
        
        output$model_description <- renderText({
          #HTML("<p style='font-size: 14px; text-align: justify;'>
          #          <b>Report:</b><br>
          #          </p>")
          #r <- as.numeric(unlist(strsplit(input$number1,",")))
          #x <- as.numeric(unlist(strsplit(input$number2,",")))
          #lm(x ~ r)
          #matrix_coef <- summary(lm(x ~ r))$coefficients
          #pred_value <- (matrix_coef[2,1]*as.numeric(input$number3)+matrix_coef[1,1])
          
          #paste("The predicted value of the rate r for the selected value of x: ")
        })
        
        
        
        
        forecast_decomposer <- new(Class = "decomposer",
                                   dataset = xts_for_model[out_of_sample_start:out_of_sample_end,],
                                   date = input$date_col,
                                   dependent = input$dependent_var,
                                   independent = input$independent_vars,
                                   gran = input$granularity,
                                   seas = input$ses,
                                   max_aut = as.character(input$max_auto),
                                   max_d = as.character(input$max_diff))
        
        #forecast_model <- checkresiduals(auto_arima(forecast_decomposer))
        
        regressor <- forecast_decomposer@dataset[, input$independent_vars]
        forecast <- forecast(auto_arima(decomposer),
                             xreg = as.matrix(regressor),
                             h = length(out_of_sample_start:out_of_sample_end))
        
        output$forecast_plot <- renderPlot({
        plot(forecast)
          
        })
        
        
        output$error_margin <- renderText({
          
           actual <- as.numeric(xts_for_model[out_of_sample_start:out_of_sample_end, input$dependent_var])
           forecasted <- as.numeric(forecast$mean)
          
            MAPE <- mean(abs((actual - forecasted) / actual)) * 100
           result <- paste("Mean Absolute Percentage Error:", round(MAPE, 2), "%\n")
          
           MAE <- mean(abs(actual - forecasted))
            result <- paste("Mean Absolute Error:", round(MAE, 2),"\n")
          
           MSE <- mean((actual - forecasted)^2)
            result <- paste("Mean squared Error:", round(MSE, 2), "\n")
          
          # result
          
        })
        
        
    })
})