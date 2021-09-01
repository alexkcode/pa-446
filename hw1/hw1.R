# HW1
#your final answers and your final R script can be uploaded via the link below:
#https://forms.gle/qo6XoLamepNuJNcT9

"One of the mayor of Chicago's priority this year is equity in pay for city employees,
especially in some of the city's largest departments. Her office has provided you a dataset
to help figure out where pay inequity might currently exist.
"

#---PROBLEM 1---

"
Pay equity amongst city employees is a large and vague problem.
See if you can build more clarity by asking 4 clarifying questions for
the prompt above.
"

#if you write any code for the problem, please include your code/work here

# What subgroups would be compared for equity?
# Which departments did they mean?
# How would hourly wages and yearly salaries be compared?
# How would part time and full time pay be compared?

#---PROBLEM 2---
"
1. Open the dataset
2. Before you do any analyis on the data, you have to ensure the data is ready for analysis.
Use the R functions you been taught to carefully examine each column - SHOW YOUR WORK. 
Find 3 issues with the data that are either problematic for future analysis you want to do
or just not best practice for tidyverse data analysis.
"

#if you write any code for the problem, please include your code/work here
library(tidyverse)
hw1 = read_csv("pa446_hw1_data_final.csv")

# ISSUE 0
str(hw1)
# data types of the columns don't match what they should be
# e.g. salary should be a numeric data type but it is character

# ISSUE 1
# column names require special care when used with tidyverse selection because
# of the spaces in the names

# ISSUE 2
FALSE %in% is.na(hw1 %>% select(gender))
# the entirety of the gender column is NA

# ISSUE 3
hw1 %>% 
  select(`Yearly Salary`) %>% 
  mutate(`Yearly Salary` = str_remove(`Yearly Salary`, "\\$")) %>% 
  filter(`Yearly Salary` < 0)
# some salaries are in the negatives

# ISSUE 4
unique(hw1 %>% select(`Salary or Hourly`))
# salary and hourly wage is seperated into 2 columns even though there is already
# a column to encode whether or not the payment is hourly based on yearly salary
# based
