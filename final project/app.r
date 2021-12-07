


library(tidyverse)
library(broom)
library(purrr)
library(furrr)

library(shiny)
library(DT)
library(ggplot2)
library(shinydashboard)
library(plotly)

loc_index = read_csv("loc_index.csv")

ui = dashboardPage(
  dashboardHeader(title = "Renter Livability"),
  dashboardSidebar(
    textInput(inputId = "text_input", label = "County FIPS")
  ),
  dashboardBody(
    fluidRow(
      valueBoxOutput("commute")
    ),
    fluidRow(
      box(
        width = 4, status = "info", solidHeader = TRUE,
        title = "Area Rent vs City Rent",
        plotOutput("ggp")
      ),
      box(
        
      )
    ),
    fluidRow(
      column(8, tableOutput(outputId = "table")),
    )
  )
)

server = function(input, output, session) {
  output$commute <- renderValueBox({
    df_filter <- loc_index %>%
      filter(CNTY_FIPS==input$text_input)
    
    commuteDistance <- median(df_filter$median_commute, na.rm = T)
    
    cityMedian <- median(loc_index$median_commute, na.rm = T) 
      
    valueBox(
      value = formatC(commuteDistance, digits = 3, format = "f"),
      subtitle = "Median Commute Distance",
      icon = icon("clock-o", lib = "font-awesome"),
      color = if (commuteDistance > cityMedian) "yellow" else "aqua"
    )
  })
  
  output$table <- renderTable({
    df_filter <- loc_index %>%
      filter(CNTY_FIPS==input$text_input)
    head(df_filter)
  })
  
  output$ggp <- renderPlot({
    loc_index %>%
      group_by(CNTY_FIPS) %>%
      mutate(area = median_gross_rent,
             city = median(median_gross_rent, na.rm = T)) %>%
      pivot_longer(cols=c(area, city), names_to = "area", values_to = "rent") %>%
      filter(CNTY_FIPS==input$text_input) %>%
      ggplot(aes(x = area, y = rent)) + 
        geom_col() +
        xlab("") +
        ylab("Rent")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)