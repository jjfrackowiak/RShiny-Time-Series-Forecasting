library(shiny)
library(forecast)

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
    df
  })
  
  output$plot1 <- renderPlot({
    plot(data()$x, data()$r,
         xlim = c(0, 10),
         ylim = c(0, 10), col = "blue")
    if(input$line) {
      lm_fit <- lm(r ~ x, data = data())
      abline(lm_fit)
      arima_fit <- arima(data()$r, order = c(1, 0, 1), xreg = data()$x)
      print(arima_fit$fitted)
      lines(data()$x, col = "red")
    
      legend("bottomright", legend = c("r", "ARIMAX Fit"), 
             col = c("blue","red"), lty = 1)
    }
  })
  
  output$selected_x <- renderText({
    arima_fit <- arima(data()$r, order = c(1,1,0), xreg = data()$x)
    pred_value <- predict(arima_fit, n.ahead = 1, newxreg = data.frame(x = as.numeric(input$number)))
    paste("Predicted value of the interest rate r for the selected x value: ", pred_value$pred)
  })
  
  
}


shinyApp(ui = ui, server = server)

