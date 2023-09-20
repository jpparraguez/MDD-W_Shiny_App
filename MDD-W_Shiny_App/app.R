# MDD-W Shiny App
# Author: Juan Pablo Parraguez

# Libraries
library(shiny)
library(tidyverse)
library(DT)
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
      # Title and text
      tags$h3("Downloadable material"),
      tags$em("Not sure how to unload your data?"),
      tags$br(),
      tags$p("Try the available *MDD-W Template* to organize your information."),
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
                           tags$h4("Number of initial observations:"),textOutput("nrow_initial"),
                           tags$h4("Number of complete observations:"),textOutput("nrow_complete"),
                           tags$h4("Number columns:"),textOutput("ncol_holder")
                           ),
                  #### Tab 3: MDD-W table ----
                  tabPanel("MDD-W Prevalence",
                           tableOutput("mddw_table")),
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
    # Read the imported value. It will be stored as "imported_data".
    read_excel(input$loaded_file$datapath)
    })
  
  
  ## Render Preview_import ----
  output$preview_loaded_file <- renderTable({
    print(imported_data())
  })

  ## Render Descriptive values ----
  # Numner of initial rows
  output$nrow_initial <- renderText({
    nrow(imported_data())
  })
  # Number of complete rows. NA or empty are not counted
  output$nrow_complete <- renderText({
    nrow(imported_data() %>%
           select(-ID,-WEIGHT) %>% 
           na.omit()
         )
  })
  # Number of columns
  output$ncol_holder <- renderText({
    ncol(imported_data())
  })
 
  ## Render MDDW Table ----
  output$mddw_table <- renderTable({
    imported_data() 
  })
  
  
  ## Download template ----
  # ref: https://stackoverflow.com/questions/68477838/how-to-have-users-download-pre-loaded-formatted-excel-document-in-r-shiny
  output$download_template <- downloadHandler(
    filename = function() {
      paste("MDD-W Template", ".xlsx", sep='')
    },
    content = function(file) {
      myfile <- srcpath <-  "./www/Template_for_upload.xlsx"
      file.copy(myfile, file)
    }
  ) 
    
}
  
# Run the app ----
shinyApp(ui, server)
