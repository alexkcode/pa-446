


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
  dashboardSidebar(
    selectizeInput(
      'food_id', '1. Ingredient', choices = ca_food_choices,
      options = list(
        placeholder = 'Type to search for ingredient',
        onInitialize = I('function() { this.setValue(""); }')
      )
    ),
    conditionalPanel('input.food_id != ""', 
                     selectizeInput('measure_unit', '2. Measure Unit', choices = c("Select an ingredient" = "")),
                     numericInput('quantity', '3. Quantity', value = 1, min = 0, step = 1)),
    actionButton("add", "Add ingredient"),
    actionButton("remove", "Remove ingredient"),
    numericInput("serving", "Number of servings contained", min = 0.01, step = 1, value = 1),
    tags$p("Note: All nutrient information is based on the Canadian Nutrient File. Nutrient amounts do not account for variation in nutrient retention and yield losses of ingredients during preparation. % daily values (DV) are taken from the Table of Daily Values from the Government of Canada. This data should not be used for nutritional labeling.")
  ),
)

server = function(input, output, session) {
  # make reactive to store ingredients
  ing_df <- shiny::reactiveValues()
  ing_df$df <- data.frame("quantity" = numeric(), 
                          "units" = character(), 
                          "ingredient_name" = character(), 
                          "FoodID" = numeric(), 
                          stringsAsFactors = F)
  ing_df$measure <- data.frame("numeric" = numeric(),
                               "units" = character(),
                               "description" = character(),
                               "ConversionFactorValue" = numeric(),
                               "MeasureID" = numeric(),
                               "FoodID" = numeric(),
                               stringsAsFactors = F)
}

# Run the application 
shinyApp(ui = ui, server = server)