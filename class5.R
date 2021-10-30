library(tidyverse)

####RACE#####
df_race <- read_csv("census_2010_race.csv")

df_race$pctaian <- as.numeric(df_race$pctaian)
df_race$pctblack <- as.numeric(df_race$pctblack)

final_col <- c('name', 'pctwhite', 'pctblack', 'pctapi','pctaian', 'pcthispanic')
race_col<- c('pctwhite', 'pctblack', 'pctapi','pctaian', 'pcthispanic')

df_race_filter <- df_race %>%
  select(final_col) 

find_first_max_index <- function(row) {
  head(which(row==max(row)),1)[1]
}

find_first_max_index_na <- function(row) {
  head(which(row==max(row, na.rm = TRUE)),1)[1]
}

?mean
df_race_filter$race_final <- colnames(df_race_filter[race_col])[
  apply(
    df_race_filter[race_col],
    MARGIN=1,
    find_first_max_index_na
  )
  ]
view(df_race_filter)

head(df_race_filter)
df_race_final <- df_race_filter %>%
  mutate(last_name = tolower(name)) %>%
  select(last_name,race_final) %>%
  mutate(race_final = str_replace(race_final, '^pct',''))

view(df_race_final)

#GENDER
df_gender<-read_delim("IL.TXT",
                      delim=",",
                      col_names = c('state','gender','born_year','first_name','count'),
                      col_types = list('c','c','i','c','i'))

df_gender_final <- df_gender %>%
  group_by(first_name) %>%
  slice(which.max(count)) %>%
  select(gender, first_name) %>%
  mutate(first_name = tolower(first_name))

view(df_gender_final)


###salary data

df <- read_csv("pa446_chicago_full.csv")

df_sep <- df %>%
  separate(Name, c('last_name','first_mid_name'), sep=",") %>%
  mutate(first_mid_name = str_trim(first_mid_name)) %>%
  separate(first_mid_name, c('first_name','mid_name'), sep=" ") %>%
  mutate(
    hourly_salary = (`Hourly Rate` * `Typical Hours`) * 52,   
    annual_salary = coalesce(`Annual Salary`, hourly_salary),
    last_name = tolower(last_name),
    first_name = tolower(first_name)
  ) %>%
  select("last_name", "first_name","Job Titles","Department",
         "annual_salary")
view(df_sep)


##JOIN
df_race_join <- left_join(df_sep, df_race_final, 
                         by=c('last_name'='last_name'))

df_race_gender_join <- left_join(df_race_join, df_gender_final, 
                             by=c('first_name'='first_name'))

view(df_race_gender_join)

###data quality check

## TO DO
#### IF A SURNAME IS HEAVILY ONE RACE IN %, THEN GO WITH THAT RACE
#### ELSE IF A SURNAME IS NOT HEAVILY ONE RACE IN %, AND THE DIFFERENCE BETWEEN THE MAJORITY RACE AND SECONDARY RACE IS SMALL, COIN FLIP
##########GO WITH THE NON-WHITE RACE

## TO DO
#### IF A SURNAME IS HEAVILY ONE RACE IN %, THEN GO WITH THAT RACE
#### ELSE IF A SURNAME IS NOT HEAVILY ONE RACE IN %, AND THE DIFFERENCE BETWEEN THE MAJORITY RACE AND SECONDARY RACE IS SMALL, ASSIGN RACE AS NA


summary(df_race_gender_join)

df_race_gender_join %>%
  group_by(gender) %>%
  summarise(n_size = n()) %>%
  mutate(propor = n_size/sum(n_size))

df_race_gender_join %>%
  group_by(race_final) %>%
  summarise(n_size = n()) %>%
  mutate(propor = n_size/sum(n_size))










###WITH FIRST NAME

df_race_first <- read_csv("firstnames_race.csv")

first_final_col <- c('firstname', 'pctwhite', 'pctblack', 'pctapi','pctaian', 'pcthispanic')

df_race_first_filter <- df_race_first %>%
  select(first_final_col) 

first_max_value <- function(row) {
  max(row, na.rm = TRUE)
}

df_race_first_filter$first_name_race_perc <- 
  apply(
    df_race_first_filter[race_col],
    MARGIN=1,
    first_max_value
  )

df_race_first_filter$first_name_race <- colnames(df_race_first_filter[race_col])[
  apply(
    df_race_first_filter[race_col],
    MARGIN=1,
    find_first_max_index
  )
  ]

df_race_first_final <- df_race_first_filter %>%
  mutate(first_name = tolower(firstname)) %>%
  select(first_name, first_name_race,first_name_race_perc) %>%
  mutate(first_name_race = str_replace(first_name_race, '^pct',''))

view(df_race_first_final)


###LAST NAME
df_race_filter$last_name_race_perc <- 
  apply(
    df_race_filter[race_col],
    MARGIN=1,
    first_max_value
  )

df_race_filter$last_name_race <- colnames(df_race_filter[race_col])[
  apply(
    df_race_filter[race_col],
    MARGIN=1,
    find_first_max_index
  )
  ]


df_race_last <- df_race_filter %>%
  mutate(last_name = tolower(name)) %>%
  select(last_name,last_name_race, last_name_race_perc) %>%
  mutate(last_name_race = str_replace(last_name_race, '^pct',''))

view(df_race_last)


df_race_last=left_join(df_sep, df_race_last, 
                       by=c('last_name'='last_name'))

df_race_last_first=left_join(df_race_last, df_race_first_final, 
                             by=c('first_name'='first_name'))

df_race_last_first=left_join(df_race_last_first, df_gender_final, 
                             by=c('first_name'='first_name'))

view(df_race_last_first)



## TO DO
#1. IF LAST NAME % >= 80%, THEN USE LAST NAME RACE
#2. IF LAST NAME % <80% OR =NA, LOOK AT FIRST NAME
#2B. IF FIRST NAME % IS >=90%, USE FIRST NAME RACE
#2C. ELSE, ASSIGN NA

colnames(df_race_last_first)
df_race_last_first <- df_race_last_first %>%
  mutate(final_race = case_when(
    (last_name_race_perc >= 80 & !is.na(last_name_race)) ~ last_name_race,
    (last_name_race_perc < 80 & !is.na(last_name_race) & first_name_race_perc>90) ~ first_name_race,
    TRUE ~ NA_character_
  ))
    
    
view(df_race_last_first)

df_race_gender_join %>%
  group_by(race_final) %>%
  summarise(n_size = n()) %>%
  mutate(propor = n_size/sum(n_size))

df_race_last_first %>%
  group_by(final_race) %>%
  summarise(n_size = n()) %>%
  mutate(propor = n_size/sum(n_size))

df_race_last_first <- df_race_last_first %>% 
  mutate(final_race_two = case_when(
    (last_name_race!='white' & !is.na(last_name_race)) ~ last_name_race,
    (last_name_race_perc >= 80 & !is.na(last_name_race)) ~ last_name_race,
    (last_name_race_perc < 80 & !is.na(last_name_race) &
       first_name_race_perc >= 90) ~ first_name_race,
    TRUE ~ NA_character_))


df_race_last_first %>%
  group_by(final_race_two) %>%
  summarise(n_size = n()) %>%
  mutate(propor = n_size/sum(n_size))


####ANALYSIS

##LARGEST DEPARTMENTS
largest_dept <- df_race_last_first %>%
  group_by(Department) %>%
  summarise(n_size = n()) %>%
  arrange(desc(n_size))
head(largest_dept)

largest_dept_vector <- head(largest_dept$Department,5)

df_race_last_first %>%
  filter(Department %in% largest_dept_vector) %>%
  group_by(Department, gender) %>%
  summarise(
    avg_pay = mean(annual_salary, na.rm =TRUE),
    n_size = n())

race_df <- df_race_last_first %>%
  filter(Department %in% largest_dept_vector) %>%
  group_by(Department, final_race) %>%
  summarise(
    avg_pay = mean(annual_salary, na.rm =TRUE),
    n_size = n())
?t.test
write.csv(race_df, 'race_df.csv')



df_aviation <- df_race_last_first %>%
  filter(Department == 'AVIATION')

female_salary <- df_aviation %>%
  filter(gender == 'F') %>%
  select(annual_salary)

male_salary <- df_aviation %>%
  filter(gender == 'M') %>%
  select(annual_salary)

head(male_salary)

t.test(df_aviation$annual_salary ~ df_aviation$gender)

for (departm in largest_dept_vector)
{
  df_loop <- df_race_last_first %>%
    filter(Department == departm)
  print("#########################")
  print(departm)
  print("#########################")
  results<- t.test(df_loop$annual_salary ~ df_loop$gender,
                   var.equal=FALSE)
  print(results)
}

print(results)

library(broom)
library(purrr)

ttest_df <- map_df(list(results), tidy)
view(ttest_df)

results_df<-tibble()
for (departm in largest_dept_vector)
{
  df_loop <- df_race_last_first %>%
    filter(Department == departm)
  results<- t.test(df_loop$annual_salary ~ df_loop$gender,
                   var.equal=TRUE)
  ttest_df <- map_df(list(results), tidy)
  ttest_df$dept <- departm
  results_df<- results_df %>%
    rbind(ttest_df)
}

view(results_df)