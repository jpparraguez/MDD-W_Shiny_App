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
      ##### Download material ----
      # Title
      tags$h3("Downloadable material"),
      # Input_download: Choose dataset
      selectInput("dataset",
                  "Choose a dataset:",
                  choices = c("MDD-W Food Groups", "MDD-W upload data template")),
      # Button_download
      downloadButton("downloadData", "Download"),
      
      # Horizontal line
      tags$hr(),
      
      ##### Upload material ----
      # Title
      tags$h3("Upload your data"),
      # Input_upload: Select a file
      fileInput("file1", "Choose CSV File",
                multiple = FALSE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")
                ),
      
    ),
    ### Main panel for displaying outputs ----
    mainPanel(
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("Templates",
                           plotOutput("Template")),
                  tabPanel("MDD-W Prevalence",
                           plotOutput("plot")),
                  tabPanel("FG Distribution",
                           verbatimTextOutput("summary")),
                  tabPanel("Unhealthy Food Groups",
                           tableOutput("table"))
                  )
      )
    )
  )
      

# Server ----
server <- function(input, output) {
  

}
# Run the app ----
shinyApp(ui, server)
