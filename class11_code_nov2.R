library(broom)
library(purrr)
library(tidyverse)
library(shiny)


################  HTML intro

# <html>
#   
#   <h1>Hello PA 446!</h1>
#   <h1>This is a Heading</h1>
#   <p>This is a paragraph.</p>
#   <p>Edit the code in the window to the left, and click "Run" to view the result.</p>
#   
#  </html>

################  CSS
# <html>
#   <h1>Hello PA 446!</h1>
#   <h1>This is a Heading</h1>
#   <p>This is a paragraph.</p>
#   <p>Edit the code in the window to the left, and click "Run" to view the result.</p>
#   </html>
#   
# <style>
# body {
#   background-color: black;
#   text-align: center;
#   color: white;
#   font-family: Arial;
# }
# 
# p {
#   color: yellow;
# }
# </style>


################  javascript
# <html>
# <body>
# 
# <h2>What Does JavaScript Do?</h2>
# 
# <p id="demo">JavaScript takes users input.</p>
# 
# <button type="button" onclick="document.getElementById('demo').innerHTML = 'And responds with whatever you programmed!'">Click Me!</button>
# 
# </body>
# </html>
#   
  
  
###########JS functions  
# <p id="demo_2"> 'You can also return output of functions' </p>
# 
# <button type="button" onclick="document.getElementById('demo_2').innerHTML = random_float()">Click Me for a random float!</button>
# 
# <script>
# function random_float() {
#   return Math.random();
# }
# 
# </script>



# ui <- fluidPage(
#   "Hello, world!"
# )



###########SHINY, TABS
ui <- fluidPage(
  titlePanel("Tabs"),
  sidebarLayout(
    sidebarPanel("Click on the buttons inside the tabbed menu:"),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("London", textOutput("london_var")),
                  tabPanel("Paris", textOutput("paris_var")),
                  tabPanel("Tokyo", textOutput("tokyo_var")))
    )
  )
)

server <- function(input, output, session) {
  output$london_var <- renderText({
    'London is the capital of England.'})
  
  output$paris_var <- renderText({
    'Paris is the capital of France.'})
  
  output$tokyo_var <- renderText({
    'Tokyo is the capital of Japan.'})
}
shinyApp(ui, server)

###########SHINY, INTRO

ui <- fluidPage(
  "Hello, world!"
)

server <- function(input, output, session) {
}

shinyApp(ui, server)


#######UI AND INPUTS#######

library(tidyverse)
df_salaries <-read_csv('salaries_sept29.csv')
department_vars <- unique(df_salaries$Department)

ui <- fluidPage(
  textInput(inputId = "text_input", label = "CSV name"),
  selectInput(inputId = "user_input", label = "First Input", choices = department_vars),
  verbatimTextOutput(outputId = "summary"),
  tableOutput(outputId = "table")
)

server <- function(input, output, session) {
}

shinyApp(ui, server)


#######USERVER AND OUTPUTS#######
library(tidyverse)
df_salaries <-read_csv('salaries_sept29.csv')
department_vars <- unique(df_salaries$Department)

ui <- fluidPage(
  textInput(inputId = "text_input", label = "CSV name"),
  selectInput(inputId = "select_input", label = "Select Department", choices = department_vars),
  verbatimTextOutput(outputId = "avg_salaries"),
  tableOutput(outputId = "table")
)

server <- function(input, output, session) {
  output$avg_salaries <- renderPrint({
    df_salaries <-read_csv(input$text_input)
    df_filter <- df_salaries %>%
      filter(Department==input$select_input)
    mean(df_filter$annual_salary, na.rm=TRUE)
  })
  
  output$table <- renderTable({
    df_salaries <-read_csv(input$text_input)
    df_filter <- df_salaries %>%
      filter(Department==input$select_input)
    head(df_filter)
  })
}

shinyApp(ui, server)
