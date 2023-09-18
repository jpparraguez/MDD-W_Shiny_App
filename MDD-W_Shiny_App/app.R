# MDD-W Shiny App
# Author: Juan Pablo Parraguez

# Libraries
library(shiny)
library(tidyverse)

# UI ----
ui <- fluidPage(
  ## App title ----
  titlePanel("MDD-W Shiny App"),
  ### Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs
    sidebarPanel(
      ##### Upload material ----
      # Title
      tags$h3("Upload your data"),
      # Input_upload: Select a file
      fileInput("loaded_file", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
      ),
      # Horizontal line
      tags$hr(),
      
      
      ##### Download material ----
      # Title
      tags$h3("Downloadable material"),
      # Input_download: Choose dataset
      radioButtons("select_template", "Templates",
                   choices = c("MDD-W Food Groups",
                               "MDD-W upload data template")
                   ),

      # Button_download
      downloadButton("downloadData", "Download"),
      
    ),
    ## Main panel for displaying outputs ----
    mainPanel(
      # Output:
      tabsetPanel(type = "tabs",
                  tabPanel("Preview Imported Data",
                           tableOutput("preview_loaded_file")),
                  tabPanel("MDD-W Prevalence",
                           plotOutput("plot")),
                  tabPanel("FG Distribution",
                           verbatimTextOutput("summary")),
                  tabPanel("Unhealthy Food Groups",
                           tableOutput("table")),
                  tabPanel("Templates",
                           tableOutput("select_template"))
                  )
      )
    )
  )
      

# Server ----
server <- function(input, output) {
  ## Render Preview_import ----
  output$preview_loaded_file <- renderTable({
    # Check for required values before proceeding with next step. If not true, stop operation.
    req(input$loaded_file)
    
    # Store readed file in an object
    imported_data <- read.csv(input$loaded_file$datapath)
    # Return the object
    return(imported_data)
    
    })
  
  ## Download templates ----
  output$select_template <- downloadHandler(
    filename = function() {
      paste(input$dataset, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(datasetInput(), file, row.names = FALSE)
    }
  )
}

# Run the app ----
shinyApp(ui, server)
