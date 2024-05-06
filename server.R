library(shiny)
library(ggplot2)
library(plotly)
library(caret)
library(randomForest)

shinyServer(function(input, output, session) {
  data <- reactive({
    req(input$file)
    df <- read.csv(input$file$datapath)
    return(df)
  })
  
  observe({
    req(data())
    col_names <- colnames(data())
    updateSelectInput(session, "x", choices = col_names)
    updateSelectInput(session, "y", choices = col_names)
  })
  
  plotData <- eventReactive(input$plotBtn, {
    req(input$plotType, input$x, input$y)
    df <- data()
    x_col <- input$x
    y_col <- input$y
    
    if (input$plotType == "scatter") {
      return(ggplot(data = df, aes_string(x = x_col, y = y_col)) + geom_point())
    } else if (input$plotType == "bar") {
      return(ggplot(data = df, aes_string(x = x_col, y = y_col)) + geom_bar(stat = "identity"))
    } else if (input$plotType == "line") {
      return(ggplot(data = df, aes_string(x = x_col, y = y_col)) + geom_line())
    }
  })
  
  output$dynamicPlot <- renderPlot({
    if (input$plotBtn > 0) {
      plotData()
    }
  })
  
  observeEvent(input$predictButton, {
    req(input$temp, input$rainfall, input$P, input$N, input$K, data())
    xtrain <- data()[, c("temperature", "rainfall", "N", "P", "K")]
    ytrain <- as.factor(data()$Crop)
    
    set.seed(123)
    model <- randomForest(ytrain ~ ., data = data.frame(ytrain, xtrain))
    
    new_data <- data.frame(
      temperature = input$temp,
      rainfall = input$rainfall,
      P = input$P,
      N = input$N,
      K = input$K
    )
    
    predicted_crop <- predict(model, new_data)
    predicted_crop_name <- crop_mapping$Crop[crop_mapping$CropCode == as.numeric(predicted_crop)]
    
    output$predictionText <- renderText({
      if (length(predicted_crop_name) == 0) {
        "No prediction available"
      } else {
        paste("The predicted crop is", predicted_crop_name, ", This crop is suitable to grow as per your requirements")
      }
    }) 
    output$predictionImage <- renderUI({
      if (!is.null(predicted_crop_name)) {
        img_src <- paste0("images/", tolower(predicted_crop_name), ".jpg")
        tags$img(src = img_src, width = "400px")
      }
    })
  })
  #for download the plot
  output$downloadPlot <- downloadHandler(
    filename = function() {
      paste("plot", ".png", sep = "")
    },
    content = function(file) {
      if (!is.null(input$plotBtn) && input$plotBtn > 0) {
        ggsave(file, plot = plotData(), device = "png")
      }
    }
  )
  
  observeEvent(input$nextButton, {
    # Switch to the "Next" tab when the button is clicked and hide the "Welcome" tab
    updateTabsetPanel(session, "tabs", selected = "Analysis")
  })
})
