library(broom)
library(purrr)
library(tidyverse)
library(shiny)

df_salaries <-read_csv('salaries_sept29.csv') ###these 2 lines are here to make the code more understandable. When building your app, don't do this
department_vars <- unique(df_salaries$Department)
#####possible inputs

# 
# ui <- fluidPage(
#   ###text
#   textInput("name", "What's your name?"),
#   passwordInput("password", "What's your password?"),
#   textAreaInput("story", "Tell me about yourself", rows = 3),
#   
#   ###numeric
#   numericInput("num", "Number one", value = 0, min = 0, max = 100),
#   sliderInput("num2", "Number two", value = 50, min = 0, max = 100),
#   sliderInput("rng", "Range", value = c(10, 20), min = 0, max = 100),
# 
#   ###date
#   dateInput("dob", "When were you born?"),
#   dateRangeInput("holiday", 
#                  "When do you want to go on vacation next?"),
#   
#   
#   ###selectors
#   selectInput("department", 
#               "What's your favourite department?", department_vars),
#   radioButtons("department_2", 
#                "What's your least favourite department?", 
#                department_vars),
#   checkboxGroupInput("department_3", 
#                      "What departments do you like?", department_vars)
# )
# 
# server <- function(input, output, session) {
# }
# 
# shinyApp(ui, server)

#####output, tables
# df_salaries <-read_csv('salaries_sept29.csv')
# dept_1 <- df_salaries%>%
#   filter(Department=='POLICE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(50)
# # view(dept_1)
# ui <- fluidPage(
#   tableOutput("static"),
#   dataTableOutput("dynamic")
# )
# 
# server <- function(input, output, session) {
#   output$static <- renderTable(head(dept_1)) ####note the head function here
#   output$dynamic <- renderDataTable(dept_1,
#                                     options = list(pageLength = 5))
# }
# shinyApp(ui, server)

#####output, plots
# df_salaries <-read_csv('salaries_sept29.csv')
# dept_1 <- df_salaries%>%
#   filter(Department=='POLICE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(500)
# 
# dept_2 <- df_salaries%>%
#   filter(Department=='FIRE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(500)
# 
# bind_df <- rbind(dept_1, dept_2)
# 
# # ggplot(bind_df, aes(annual_salary, colour = Department)) +
# #   geom_freqpoly()
# 
# 
# ui <- fluidPage(
#   plotOutput("plot", width = "400px")
# )
# 
# server <- function(input, output, session) {
#   output$plot <- renderPlot(
#     ggplot(bind_df, aes(annual_salary, colour = Department)) +
#       geom_freqpoly())
# }
# 
# shinyApp(ui, server)


# #####output, and input objects
# 
# ui <- fluidPage(
#   selectInput("department", 
#               "What's your favourite department?", department_vars),
#   textOutput(outputId = "fav_dept")
# )
# 
# server <- function(input, output, session) {
#   # input$department <- 'FIRE'
#   ###cannot assign values to input fields. read only
#   output$fav_dept <- renderPrint(
#     input$department
#   )
# }
# 
# shinyApp(ui, server)


#####output and misspelling's silent error

# ui <- fluidPage(
#   selectInput("department", 
#               "What's your favourite department?", department_vars),
#   textOutput(outputId = "favorite_dept")
# )
# 
# server <- function(input, output, session) {
#   output$fav_dept <- renderPrint(
#     input$department
#   )
# }
# 
# shinyApp(ui, server)



#####reactivity
# 
# df_salaries <-read_csv('salaries_sept29.csv')
# department_vars <- unique(df_salaries$Department)
# 
# ui <- fluidPage(
#   textInput("department", 
#             "What's your favourite department?"),
#   textOutput(outputId = "favorite_dept")
# )
# 
# server <- function(input, output, session) {
#   ###cannot assign values to input fields. read only
#   output$favorite_dept <- renderPrint(input$department)
# }
# 
# shinyApp(ui, server)

######declarative versus imperative, order matters
# df_salaries <-read_csv('salaries_sept29.csv')
# department_vars <- unique(df_salaries$Department)
# print(department_vars)

# department_vars_1 <- unique(df_salaries_1$Department)
# df_salaries_1 <-read.csv('salaries_sept29.csv')
# print(department_vars_1)

# server <- function(input, output, session) {
#   output$greeting <- renderText({
#     paste0("Hello ", input$name, "!")
#   })
# }
# 
# ui <- fluidPage(
#   textInput("name", "What's your name?"),
#   textOutput("greeting")
# )
# 
# shinyApp(ui, server)
# 

# ######reactives, without reactives
# salary_distribution <- function (df_dept_1, df_dept_2) {
#   bind_df <- rbind(df_dept_1, df_dept_2)
#   ggplot(bind_df, aes(annual_salary, colour = Department)) +
#     geom_freqpoly()
# }
# 
# min_max <- function(df_dept_1, df_dept_2) {
#   dept_1_min <- min(df_dept_1$annual_salary)
#   dept_2_min <- min(df_dept_2$annual_salary)
#   dept_1_max <- max(df_dept_1$annual_salary)
#   dept_2_max <- max(df_dept_2$annual_salary)  
#   # use sprintf() to format t.test() results compactly
#   ###REMINDER FOR THE SYNTAX OF sprintf()
#   sprintf(
#     "Department 1, Min: %0.0f, Max: %0.0f\n
#   Department 2, Min: %0.0f, Max: %0.0f",
#     dept_1_min, dept_1_max, dept_2_min, dept_2_max
#   )
# }
# 
# dept_1 <- df_salaries%>%
#   filter(Department=='POLICE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(500)
# 
# dept_2 <- df_salaries%>%
#   filter(Department=='FIRE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(500)
# 
# salary_distribution(dept_1,dept_2)
# 
# min_max(dept_1,dept_2)
# 
# 
# 
# ui <- fluidPage(
#   fluidRow(
#     column(4, 
#            "Department 1",
#            selectInput(inputId = "dept_1_input", 
#                        label = "Select Department", 
#                        choices = department_vars)),
#     column(4, 
#            "Department 2",
#            selectInput(inputId = "dept_2_input", 
#                        label = "Select Department", 
#                        choices = department_vars)),
#     column(4, 
#            "Random Sample Size",
#            numericInput(inputId = "sample_n_input", 
#                         label = "sample n", 
#                         value=10,
#                         min = 1,
#                         max = 2000)) 
#     ###min/max to make sure they don't select more than # of employees
#   ),
#   
#   fluidRow(
#     column(8, plotOutput("plot")),
#     column(4, verbatimTextOutput("min_max"))
#   )
# )
# 
# 
# server <- function(input, output, session) {
#   output$plot <- renderPlot({
#     dept_1 <- df_salaries%>%
#       filter(Department==input$dept_1_input) %>%
#       select(annual_salary, Department) %>%
#       sample_n(input$sample_n_input)
#     
#     dept_2 <- df_salaries%>%
#       filter(Department==input$dept_2_input) %>%
#       select(annual_salary, Department) %>%
#       sample_n(input$sample_n_input)
#     
#     salary_distribution(dept_1, dept_2)
#   }, res = 96)
#   
#   output$min_max <- renderText({
#     dept_1 <- df_salaries%>%
#       filter(Department==input$dept_1_input) %>%
#       select(annual_salary, Department) %>%
#       sample_n(input$sample_n_input)
#     
#     dept_2 <- df_salaries%>%
#       filter(Department==input$dept_2_input) %>%
#       select(annual_salary, Department) %>%
#       sample_n(input$sample_n_input)
#     
#     min_max(dept_1, dept_2)
#   })
# }
# 
# shinyApp(ui, server)



######reactives, w/ reactives
# salary_distribution <- function (df_dept_1, df_dept_2) {
#   bind_df <- rbind(df_dept_1, df_dept_2)
#   ggplot(bind_df, aes(annual_salary, colour = Department)) +
#     geom_freqpoly()
# }
# 
# min_max <- function(df_dept_1, df_dept_2) {
#   dept_1_min <- min(df_dept_1$annual_salary)
#   dept_2_min <- min(df_dept_2$annual_salary)
#   dept_1_max <- max(df_dept_1$annual_salary)
#   dept_2_max <- max(df_dept_2$annual_salary)  
#   # use sprintf() to format t.test() results compactly
#   ###REMINDER FOR THE SYNTAX OF sprintf()
#   sprintf(
#     "Department 1, Min: %0.0f, Max: %0.0f\n
#   Department 2, Min: %0.0f, Max: %0.0f",
#     dept_1_min, dept_1_max, dept_2_min, dept_2_max
#   )
# }
# 
# dept_1 <- df_salaries%>%
#   filter(Department=='POLICE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(500)
# 
# dept_2 <- df_salaries%>%
#   filter(Department=='FIRE') %>%
#   select(annual_salary, Department) %>%
#   sample_n(500)
# 
# salary_distribution(dept_1,dept_2)
# 
# min_max(dept_1,dept_2)
# 
# 
# 
# ui <- fluidPage(
#   fluidRow(
#     column(4, 
#            "Department 1",
#            selectInput(inputId = "dept_1_input", 
#                        label = "Select Department", 
#                        choices = department_vars)),
#     column(4, 
#            "Department 2",
#            selectInput(inputId = "dept_2_input", 
#                        label = "Select Department", 
#                        choices = department_vars)),
#     column(4, 
#            "Random Sample Size",
#            numericInput(inputId = "sample_n_input", 
#                         label = "sample n", 
#                         value=10,
#                         min = 1,
#                         max = 2000)) 
#     ###min/max to make sure they don't select more than # of employees
#   ),
#   
#   fluidRow(
#     column(8, plotOutput("plot")),
#     column(4, verbatimTextOutput("min_max"))
#   )
# )
# 
# 
# server <- function(input, output, session) {
#   dept_1 <- reactive(df_salaries%>%
#       filter(Department==input$dept_1_input) %>%
#       select(annual_salary, Department) %>%
#       sample_n(input$sample_n_input))
#   
#   dept_2 <- reactive(df_salaries%>%
#       filter(Department==input$dept_2_input) %>%
#       select(annual_salary, Department) %>%
#       sample_n(input$sample_n_input))
#   
#   output$plot <- renderPlot({
#     salary_distribution(dept_1(), dept_2())
#   }, res = 96)
# 
#   output$min_max <- renderText({
#     min_max(dept_1(), dept_2())
#   })
# }
# 
# shinyApp(ui, server)

#####reactives, with reactives and layout framework
salary_distribution <- function (df_dept_1, df_dept_2) {
  bind_df <- rbind(df_dept_1, df_dept_2)
  ggplot(bind_df, aes(annual_salary, colour = Department)) +
    geom_freqpoly()
}

min_max <- function(df_dept_1, df_dept_2) {
  dept_1_min <- min(df_dept_1$annual_salary)
  dept_2_min <- min(df_dept_2$annual_salary)
  dept_1_max <- max(df_dept_1$annual_salary)
  dept_2_max <- max(df_dept_2$annual_salary)  
  # use sprintf() to format t.test() results compactly
  ###REMINDER FOR THE SYNTAX OF sprintf()
  sprintf(
    "Department 1, Min: %0.0f, Max: %0.0f\n
  Department 2, Min: %0.0f, Max: %0.0f",
    dept_1_min, dept_1_max, dept_2_min, dept_2_max
  )
}


ui <- fluidPage(
  titlePanel("Department Comparison"),
  sidebarLayout(
    sidebarPanel(
       selectInput(inputId = "dept_1_input", 
                   label = "Select Department 1", 
                   choices = department_vars),
       selectInput(inputId = "dept_2_input", 
                   label = "Select Department 2", 
                   choices = department_vars),
       numericInput(inputId = "sample_n_input", 
                    label = "sample n", 
                    value=10,
                    min = 1,
                    max = 2000)),
    ###min/max to make sure they don't select more than # of employees
  mainPanel(
    plotOutput("plot"),
    verbatimTextOutput("min_max"))
  )
)


server <- function(input, output, session) {
  dept_1 <- reactive(df_salaries%>%
                       filter(Department==input$dept_1_input) %>%
                       select(annual_salary, Department) %>%
                       sample_n(input$sample_n_input))
  
  dept_2 <- reactive(df_salaries%>%
                       filter(Department==input$dept_2_input) %>%
                       select(annual_salary, Department) %>%
                       sample_n(input$sample_n_input))
  
  output$plot <- renderPlot({
    salary_distribution(dept_1(), dept_2())
  }, res = 96)
  
  output$min_max <- renderText({
    min_max(dept_1(), dept_2())
  })
}

shinyApp(ui, server)
