# MDD-W Shiny App
# Author: Juan Pablo Parraguez

# Libraries
library(shiny)
library(ggplot2)
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
      fileInput("loaded_file", "Choose your Excel file",
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
      tabsetPanel(
        type = "tabs",
        #### Tab1: Preview import ----
        tabPanel(
          "Preview Imported Data",
          tableOutput("preview_loaded_file")
        ),
        #### Tab2: Describe imported data ----
        tabPanel(
          "Data description",
          tags$h4("Number of initial observations:"), textOutput("nrow_initial"),
          tags$h4("Number of complete observations:"), textOutput("nrow_complete"),
          tags$h4("Number columns:"), textOutput("ncol_holder")
        ),
        #### Tab 3: MDD-W table ----
        tabPanel(
          "MDD-W Prevalence",
          tags$h4("Percentage of women achieving MDD-W: "),
          textOutput("mddw_prevalence"),
          tags$h4("Food Group Diversity Score (FGDS) mean: "),
          textOutput("fgds_average"),
          tags$br(),
          tags$h4("Included data"),
          tableOutput("mddw_table")
        ),
        #### Tab 4: FGDS plot
        tabPanel(
          "FGDS Distribution",
          plotOutput("fgds_plot")
        ),
        #### Tab 5: FG consumption
        tabPanel(
          "FG consumption",
          plotOutput("fg_plot")
        )
      )
      )
    )
  )
      

# Server ----
server <- function(input, output, session) {
  ## Import and wrangle data ----
  # Raw imported data.
  imported_data <- reactive({
    # Check for required values before proceeding with next step. If not true, stop operation.
    req(input$loaded_file)    
    # Read the imported value. It will be stored as "imported_data".
    read_excel(input$loaded_file$datapath,
               na = c("",NA))
    })
  
  # Treated data.
  cleaned_data <- reactive({
    # Check for required values before proceeding with next step. If not true, stop operation.
    req(input$loaded_file)
    # Read the imported value. It will be stored as "imported_data".
    read_excel(input$loaded_file$datapath,
      na = c("", NA)
    ) %>%
      # Select only the columns with MDDW counting FGs
      select("FG_01":"FG_10") %>%
      # Remove rows with NA and empty cells (All empty cells are assigned as NA when importing)
      na.omit() %>%
      # Calculate FGDS and MDDW
      mutate(
        FGDS = rowSums(.[1:10]),
        MDDW = ifelse(FGDS > 4, 1, 0)
      )
  })
  
  ## Tab 1: Render Preview_import ----
    output$preview_loaded_file <- renderTable({
    print(imported_data())
  })

  ## Tab 2: Descriptive values ----
  # Number of initial rows
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
  # ---
    
  ## Tab 3: Render MDDW Table and values ----
  # MDDW Prevalence
  output$mddw_prevalence <- renderText({
    paste0(round(mean(cleaned_data()$MDDW),2)*100,"% of the sample")
  })
  # FGDS Average
  output$fgds_average <- renderText({
    paste0(round(mean(cleaned_data()$FGDS),2)," mean consumed food groups")
  })
  
  # Data for MDDW
  output$mddw_table <- renderTable({
    cleaned_data()
  })
  
  ## Tab 4: FGDS plot ----
  output$fgds_plot <- renderPlot({
    ggplot(cleaned_data(), aes(x = FGDS)) +
      geom_histogram(binwidth = 1, color = "#207cb4", fill = "#a8cce4") +
      scale_x_continuous(breaks = 0:10) +
      labs(
        title = "Food Group Diversity Score",
        subtitle = "Histogram",
        caption = "Juan Pablo Parraguez"
      ) +
      theme_minimal()
  },
  width = "auto",
  height = 800)
  
  ## Tab 5: FG consumption plot ----
  output$fg_plot <- renderPlot({
    cleaned_data() %>%
      pivot_longer(
        cols = c("FG_01":"FG_10"),
        names_to = "FG",
        values_to = "consumed"
      ) %>%
      group_by(FG) %>%
      summarise(Consumption = round(mean(consumed), 4) * 100) %>%
      ggplot() +
      aes(x = FG, y = Consumption, fill = FG) +
      geom_col() +
      geom_text(aes(label = Consumption), hjust = -0.25, size = 3) +
      scale_fill_brewer(palette = "Paired", direction = 1) +
      ylim(0, 100) +
      labs(
        x = "Food groups",
        y = "Consumption of food group",
        title = "Percentage of women consuming different food groups",
        subtitle = "MDD_W Main food groups",
        caption = "Juan Pablo Parraguez"
      ) +
      coord_flip() +
      theme_minimal() +
      theme(legend.position = "none")
  },
  height = 800)
  
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
