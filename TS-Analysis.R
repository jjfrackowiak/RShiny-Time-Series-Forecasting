library(shiny)

ui <- fluidPage(
  titlePanel("Prediction of Interest Rate Value r - ARIMA Model"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Upload a CSV file with the data",
                accept = c(".csv")),
      checkboxInput("header", "Header", TRUE),
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                   selected = ","),
      numericInput("number3",
                   label = "Enter the value of x for which you want to predict r. The predicted value of the interest rate for the selected x value will be displayed below the graph",
                   value = ""),
      br(),
      checkboxInput("line", "Display the line obtained by regression?", value = TRUE)
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
         ylim = c(0, 10))
    if(input$line) {
      model <- forecast::Arima(data()$r, order = c(1, 0, 0), xreg = data()$x)
      abline(coef(model))
    }
  })
  
  output$selected_x <- renderText({
    model <- forecast::Arima(data()$r, order = c(1, 0, 0), xreg = data()$x)
    forecast_result <- forecast::forecast.Arima(model, h = 1, xreg = data.frame(x = input$number3))
    pred_value <- forecast_result$mean[1]
    paste("Predicted
