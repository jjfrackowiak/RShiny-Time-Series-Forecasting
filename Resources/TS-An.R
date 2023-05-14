library(shiny)
library(forecast)
library(xts)

ui <- fluidPage(
  titlePanel("Prediction of Interest Rate Value r - ARIMAX Model"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Upload a CSV file with the data",
                accept = c(".csv")),
      checkboxInput("header", "Header", TRUE),
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                   selected = ","),
      numericInput("number",
                   label = "Enter the value of x for which you want to predict r. The predicted value of the interest rate for the selected x value will be displayed below the graph",
                   value = ""),
      br(),
      checkboxInput("line", "Display the fitted line?", value = TRUE)
    ),
    
    mainPanel(
      plotOutput("plot1", click = "plot_click"),
      br(),
      strong(textOutput("selected_x"))
    )
  )
)

server <- function(input, output) {
  
  data <- reactive({
    req(input$file1)
    df <- read.csv(input$file1$datapath, header = input$header, sep = input$sep)
    # Convert Date column to a date object
    df$Date <- as.Date(df$Date, format = "%d/%m/%Y")
    # Convert data frame to time series object
    ts_data <- xts(df[,-1], df$Date) 
    ts_data
  })
  
  output$plot1 <- renderPlot({
    plot(data()$r, type = "o", col = "blue",
         xlab = "Date",
         ylab = "Interest Rate Value (r)")
    if(input$line) {
      lm_fit <- lm(r ~ time(data()), data = data())
      arima_fit <- arima(data()$r, order = c(1, 0, 1), xreg = data()$x)
      lines(arima_fit$fitted, col = "red", lwd = 3)
      legend("bottomright", legend = c("r", "ARIMAX Fit"), 
             col = c("blue","red"), lty = 3)
    }
  })
  
  output$selected_x <- renderText({
    arima_fit <- arima(data()$r, order = c(1,1,0), xreg = data()$x)
    pred_value <- predict(arima_fit, n.ahead = 1, newxreg = data.frame(x = as.numeric(input$number)))
    paste("Predicted value of the interest rate r for the selected x value (one period ahead): ", pred_value$pred)
  })
  
}


shinyApp(ui = ui, server = server)
