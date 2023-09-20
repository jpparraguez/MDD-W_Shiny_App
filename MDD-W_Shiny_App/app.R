# MDD-W Shiny App
# Author: Juan Pablo Parraguez

# Libraries
library(shiny)
library(tidyverse)
library(data.table)
library(readxl)

# UI ----
ui <- fluidPage(titlePanel("MDD-W Shiny App"),
  ### Sidebar  ----
  sidebarLayout(
    #### Load material ----
    sidebarPanel(
      # Title
      tags$h3("Upload your data from Excel (.xlsx)"),
      # Input_upload: Select a file
      fileInput("loaded_file", "Choose CSV File",
                multiple = FALSE,
                accept = c(".xlsx")
      ),
      # Horizontal line
      tags$hr(),
      
      
      #### Download material ----
      # Title
      tags$h3("Downloadable material"),
      
      # Button_download
      downloadButton("download_template", "Download Template"),
      
    ),
    ### Main panel ----
    mainPanel(
      # Output:
      tabsetPanel(type = "tabs",
                  #### Tab1: Preview import ----
                  tabPanel("Preview Imported Data",
                           tableOutput("preview_loaded_file")),
                  #### Tab2: Describe imported data ----
                  tabPanel("Data description",
                           tags$h4("Number of initial observations:"),
                           textOutput("nrow_holder"),
                           tags$h4("Number columns:"),
                           textOutput("ncol_holder")),
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
server <- function(input, output, session) {
  
  # Save loaded data as reactive value. This way it can be used across.
  imported_data <- reactive({
    # Check for required values before proceeding with next step. If not true, stop operation.
    req(input$loaded_file)    
    # Read the imported value. It's stored as "imported_data".
    # read.csv(input$loaded_file$datapath)
    read_excel(input$loaded_file$datapath)
    })
  
  ## Render Preview_import ----
  output$preview_loaded_file <- renderTable({
    # # Check for required values before proceeding with next step. If not true, stop operation.
    # req(input$loaded_file)
    # # Store readed file in an object
    # imported_data <- read.csv(input$loaded_file$datapath)
    # # Return the object
    data.table(imported_data())
    
    })
  
  
  
  
  ## Descriptive values ----
    output$nrow_holder <- renderText({
    nrow(imported_data())
  })
  output$ncol_holder <- renderText({
    ncol(imported_data())
  })
 
  
  # Download template
  output$download_template <- downloadHandler(
    filename = function() {
      paste("MDD-W Template", ".xlsx", sep='')
    },
    content = function(file) {
      # myfile <- srcpath <- 'Home/Other Layer/Fancy Template.xlsx'
      myfile <- srcpath <-  "./www/Template_for_upload.xlsx"
      file.copy(myfile, file)
    }
  ) 
    
}
  
# Run the app ----
shinyApp(ui, server)
