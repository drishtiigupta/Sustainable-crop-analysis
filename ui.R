library(shiny)
shinyUI(
  fluidPage(
    tags$style(HTML("
      .centered-content {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
       .nav-tabs {
          background-color:orange; 
          border: solid #fff 2px;
          padding: 0;
       }
    ")),
    tabsetPanel(
      id = "tabs",
      tabPanel("Welcome", 
               div(
                 class = "centered-content",
                 tags$video(
                   autoplay = "autoplay",
                   loop = "loop",
                   muted = "muted",
                   style = "position: fixed; right: 0; bottom: 0; min-width: 100%; min-height: 100%; width: auto; height: auto; z-index: -100;",
                   src = "bgvideo/home.mp4"  # Replace with your video file name
                 ),
                   h1(style = "color: white;font-size: 120px;","Welcome"),
                 actionButton("nextButton", "Move to ananlysis", style = "background-color: orange; color: white;")
               )
      ),
      tabPanel("Analysis", 
               div(
                 titlePanel("Crop Prediction and Dynamic Plot"),
                 style = "background-color: green; color: white;"
               ),
               sidebarLayout(
                 sidebarPanel(
                   style = "background-color: black; color:white;",
                   fileInput("file", "Choose a CSV file"),
                   selectInput("plotType", "Select Plot Type", 
                               choices = c("scatter", "bar", "line"), 
                               selected = "scatter"),
                   selectInput("x", "X-Axis:", choices = NULL),
                   selectInput("y", "Y-Axis:", choices = NULL),
                   actionButton("plotBtn", "Generate Plot"),
                   numericInput("temp", "Temperature", value = 22),
                   numericInput("rainfall", "Rainfall", value = 270),
                   numericInput("N", "Nitrogen (N)", value = 69),
                   numericInput("P", "Phosphorus (P)", value = 55),
                   numericInput("K", "Potassium (K)", value = 38),
                   actionButton("predictButton", "Predict Crop"),
                   width = 3
                 ),
                 mainPanel(
                   fluidRow(
                     column(10, plotOutput("dynamicPlot")),
                     column(2, align = "right", downloadButton("downloadPlot", "Download Plot"))
                   ),
                   br(),
                   br(),
                   br(),
                   br(),
                   tags$div(style = "font-size: 18px; color: blue;", textOutput("predictionText")),
                   uiOutput("predictionImage"), 
                   width = 9
                 )
               )
      )
    )
  )
)
