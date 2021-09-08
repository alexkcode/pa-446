# HW2
# your final answers and your final R script can be uploaded via the link below:
# https://forms.gle/pJLZUkj8zpHvqUDi6
# FROM HERE ON OUT, MAKE SURE YOU USE THE FULL SALARIES DATASET, DETAILS BELOW
# Blackboard > PA 446 > Data files > salary_data_full
#

"Now that you have a more complete dataset, 
aligned on broad goals with the client - 
pay equity WITHIN departments, across race and gender - 
and have a basic understanding of the data wrangling needed, 
you are ready to begin data wrangling.
"

#---PROBLEM 1---

"
Break out first, middle and last name into their distinct columns.
Name your new columns first_name, middle_name, last_name.
SHOW YOUR WORK
"

#if you write any code for the problem, please include your code/work here


#---PROBLEM 2---
"
We need one salary data point regardless of whether somoene is a hourly or salaried employee.
Figure out how to coalesce hourly and annual salary together
for these 2 types of workers. 
The end result should be a new column that represents everyone's annual salaries.
Call this column annual_salary in your dataframe.
"

#if you write any code for the problem, please include your code/work here


#---PROBLEM 3---
"
You have noticed that you are missing gender data. 
Your task is to impute gender data for as many people in 
the Chicago salaries data as possible.
You are very scrappy and found the Social Service Administration's data (https://www.ssa.gov/OACT/babynames/limits.html)
which maps first names to genders for Illinois residents.
The file is called IL.TXT and is available on Blackboard.
Use this data to identify the gender of as many individuals
in the Chicago salaries dataset as possible. 
REMINDER: USE THE NEWEST CHICAGO SALARY DATA AVAILABLE ON BLACKBOARD.
The end product should be a new column in the Chicago salaries dataset.
Name this column new_gender.
While new_gender will have non-NA values than the old gender column,
some rows can still be NA.
I PLAN ON GRADING STUDENTS MORE BASED ON WHAT THEY ATTEMPTED IN R.
REMEMBER TO SHOW YOUR WORK
"


#if you write any code for the problem, please include your code/work here



#---PROBLEM 4---
"
A large part of equity also has to do with race. Find two data
sources that can help you create a race column in the Chicago data.
YOU DO NOT NEED TO ACTUALLY WRANGLE A RACE COLUMN, 
JUST FIND THE DATA SOURCES ONLINE AND SHARE THE URL.
"

#if you write any code for the problem, please include your code/work here
