# PA 446
# Alexis Kwan
# kwan1
# HW3
# your final answers and your final R script can be uploaded via the link below:
# 
# FROM HERE ON OUT, MAKE SURE YOU USE THE FULL SALARIES DATASET, DETAILS BELOW
# Blackboard > PA 446 > Data files > salary_data_full
#

library(tidyverse)

#---PROBLEM 1---
"Now that you are done with data wrangling, it is time to
synthesize everything you learned. Use the original data files: 
IL.TXT, census_2010_race.csv, and pa446_chicago_full.csv.
Clean all of them and create 1 master table.
The master table need to have the following columns:
last_name, first_name, job_titles, department, 
annual_salary (for both salaried and hourly employees),
race, gender.
SHOW YOUR WORK.
"
#if you write any code for the problem, please include your code/work here

salary_full = read_csv("pa446_chicago_full.csv") %>% 
  separate(Name, c('last_name','first_mid_name'), sep = ",", extra = "merge") %>%
  # replace mutated columns, merge salary and hourly wage columns into one
  transmute(annual_salary = case_when(`Salary or Hourly` == "Salary" ~ `Annual Salary`,
                                      `Salary or Hourly` == "Hourly" ~ `Hourly Rate`),
            first_mid_name = str_to_lower(str_trim(first_mid_name)),
            last_name = str_to_lower(last_name),
            job_titles = `Job Titles`,
            department = Department) %>%
  separate(first_mid_name, c('first_name','mid_name'), sep = " ", extra = "merge")

# column names not specified so we must specify
gender_il = read_csv("IL.TXT", 
                     col_names = c("state","gender","year","first_name","count"),
                     col_types = list('c','c','i','c','i')) %>%
  group_by(first_name) %>%
  # leave only the name with the highest count in the dataframe
  slice(which.max(count)) %>%
  mutate(first_name = str_to_lower(first_name))

census_race = read_csv("census_2010_race.csv") %>%
  mutate(across(starts_with("pct"), as.numeric)) %>%
  # bring the pct* columns representing percentage of population with 
  # a particular race, down into separate rows
  pivot_longer(
    col=starts_with("pct"),
    names_to = 'race',
    values_to= 'percent'
  )

top_race = census_race %>%
  group_by(name) %>%
  # leave only the name with the highest percent of the race in the dataframe
  slice(which.max(percent)) %>%
  mutate(race = str_replace(race, '^pct', ''),
         first_name = str_to_lower(name))

length(unique(top_race$first_name)) == nrow(top_race)

master = left_join(salary_full, gender_il %>% select(first_name, gender)) %>%
  left_join(top_race %>% select(first_name, race)) %>%
  select(last_name, first_name, job_titles, department, annual_salary, race, gender)
  

#---PROBLEM 2---
"
As you already know, one of the mayor of Chicago's priority this year is equity in pay for city employees,
especially in some of the city's largest departments. 

Furthermore, equity is defined as pay equality between 
1) different genders and 
2) different races

Use your master table and see if there are general pay differences
between genders in the city's 5 largest departments.
Please also calculate the n-size for males and females in each department.
"
#if you write any code for the problem, please include your code/work here

gender_comp = master %>% 
  group_by(department) %>%
  mutate(department_n = n()) %>%
  group_by(department, department_n, gender) %>%
  summarise(mean_salary = mean(annual_salary),
            n = n()) %>%
  arrange(desc(department_n))
  
view(gender_comp)

gender_diff = gender_comp %>% 
  pivot_wider(names_from = gender,
              values_from = c(mean_salary,n)) %>%
  transmute(salary_diff = mean_salary_F - mean_salary_M)

nrow(gender_diff %>% filter(salary_diff < 0))/nrow(gender_diff)

"
As we can see many of the departments have a negative difference in salary
between the male and female employees of the departments, meaning that there appears
to be pay gap bias towards the men. It looks like about 56% of the departments
exhibit this gap.
"

#---PROBLEM 3---

"
Is the difference you observed in problem 2 statistically significant?
"

#if you write any code for the problem, please include your code/work here

aov_salary = aov(annual_salary ~ gender + department, data = master)
summary(aov_salary)

"
Based on the ANOVA test above and accounting for department, the differences
should be statistically significant.
"

#---PROBLEM 4---
"
Use your master table and see if there are general pay differences
between races in the city's 5 largest departments.
Please also calculate the n-size for each race subgroup in each department.
"

#if you write any code for the problem, please include your code/work here

race_comp = master %>% 
  group_by(department) %>%
  mutate(department_n = n()) %>%
  group_by(department, department_n, race) %>%
  summarise(mean_salary = mean(annual_salary),
            n = n()) %>%
  arrange(desc(department_n))

view(race_comp)

"
We can again see differences between salaries of different racial groups within
departments.
"

#---PROBLEM 5---
"
Is the differences statistically significant?
"

#if you write any code for the problem, please include your code/work here

aov2_salary = aov(annual_salary ~ race + department, data = master)
summary(aov2_salary)

"
We see that again there are statistically different means in salaris across
races controlling for the department.
"