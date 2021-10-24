library(broom)
library(purrr)
library(tidyverse)


df_race_last_first <-read_csv('salaries_sept29.csv')
view(df_race_last_first)

largest_dept_df <- df_race_last_first %>%
  group_by(Department) %>%
  summarise(n_size=n()) %>%
  arrange(desc(n_size))

?arrange
head(largest_dept_df)

largest_dept <- head(largest_dept_df$Department)
largest_dept
df_largest_dept <- df_race_last_first %>%
  filter(Department %in% largest_dept)

lm_orig <- lm(annual_salary ~ final_race_two + gender + Department,
           data = df_largest_dept)

summary(lm_orig)
lm_orig_df <- map_df(list(summary(lm_orig)), tidy)
view(lm_orig_df)

######department level
df_police <- df_race_last_first %>%
  filter(Department == 'POLICE')

lm_police <- lm(annual_salary ~ final_race_two + gender,
              data = df_police)

summary(lm_police)
lm_police_df <- map_df(list(summary(lm_police)), tidy)
view(lm_police_df)


df_fire <- df_race_last_first %>%
  filter(Department == 'FIRE')

lm_fire <- lm(annual_salary ~ final_race_two + gender,
                data = df_fire)

summary(lm_fire)
lm_fire_df <- map_df(list(summary(lm_fire)), tidy)
view(lm_fire_df)


#####after reviewing audience and goals, controlling for jobs
lm_police_jobs <- lm(annual_salary ~ final_race_two + gender 
                + `Job Titles`,
                data = df_police)

summary(lm_police_jobs)
lm_police_jobs_df <- map_df(list(summary(lm_police_jobs)), tidy)
view(lm_police_jobs_df)

#####after avoiding sparse matrix

largest_jobs_df <- df_race_last_first %>%
  group_by(`Job Titles`, Department) %>%
  summarise(n_size=n(),
            avg_salary=mean(annual_salary)) %>%
  arrange(desc(n_size))

common_jobs <- head(largest_jobs_df$`Job Titles`)
common_jobs
df_common_jobs_police <- df_race_last_first %>%
  filter(`Job Titles` %in% common_jobs) %>%
  filter(Department == 'POLICE')

view(df_common_jobs_police)
###########NA CHECK

na_check_police <- df_common_jobs_police %>%
  group_by(final_race_two) %>%
  summarise(n_size=n())
head(na_check_police)

na_check_fire <- df_fire_dummied %>%
  group_by(final_race_two) %>%
  summarise(n_size=n())
head(na_check_fire)

###########lm for top jobs

lm_police_b <- lm(annual_salary ~ final_race_two +
          `Job Titles` + gender,
          data = df_common_jobs_police)

summary(lm_police_b)
lm_police_b_df <- map_df(list(summary(lm_police_b)), tidy)
view(lm_police_b_df)
write_csv(lm_police_b_df, 'police_b.csv')


lm_fire_b <- lm(annual_salary ~ final_race_two +
             `Job Titles` + gender,
           data = df_common_jobs_fire)
summary(lm_fire_b)

lm_fire_b_df <- map_df(list(summary(lm_fire_b)), tidy)
view(lm_fire_b_df)
write_csv(lm_fire_b_df, 'fire_b.csv')

###########plotting coefficients
library(ggplot2)
library(forcats) 

lm_police_b_df$term<-factor(lm_police_b_df$term)

term_include<-c('final_race_twoblack','final_race_twohispanic',
               'final_race_twowhite','genderM')

lm_police_b_df %>%
  filter(term %in% term_include) %>%
  ggplot(aes(x=term, y=estimate)) + 
  geom_bar(stat='identity', width=.5)  + 
  labs(subtitle="Difference in Annual Salary by Race and Gender", 
       title= "Police Department Equity") + 
  coord_flip()

####COLUMN LABELS ALWAYS OVERLAP


#DOES ANYONE REMEMBER WHAT THIS DOES?
lm_police_b_df %>%
  filter(term %in% term_include) %>%
  mutate(term = fct_reorder(term, estimate)) %>%
  # arrange(estimate) %>%
  ggplot(aes(x=term, y=estimate)) + 
  geom_bar(stat='identity', width=.5)  + 
  labs(subtitle="Difference in Annual Salary by Race and Gender", 
       title= "Police Department Equity") + 
  coord_flip()



####HOW - FINAL STORY TELLING DATA CLEANING
# install.packages('fastDummies')
library('fastDummies')

df_common_jobs_police <- df_common_jobs_police %>%
  rename(job_titles=`Job Titles`) %>%
  mutate(random_num = sample(100, 
                        size=nrow(df_common_jobs_police),
                        replace=TRUE)) %>%
  mutate(imput_gender = case_when(
    !is.na(gender) ~ gender,
    (is.na(gender) & random_num<75) ~ 'M',
    TRUE ~ 'F'))

df_police_dummied <- df_common_jobs_police %>%
  drop_na(c('final_race_two','imput_gender')) %>%
  dummy_cols(select_columns = c('final_race_two','imput_gender'))


lm_police_final <- lm(annual_salary ~ final_race_two_hispanic +
                        final_race_two_black + final_race_two_api +
                        job_titles + imput_gender_F,
                      data = df_police_dummied)

summary(lm_police_final)
lm_police_final_df <- map_df(list(summary(lm_police_final)), tidy)
view(lm_police_final_df)
write_csv(lm_police_final_df, 'police_model.csv')


term_final<-c('final_race_two_hispanic',
              'final_race_two_black',
                'final_race_two_api','imput_gender_F')

lm_police_final_df <- lm_police_final_df %>% 
    mutate(
      significant_95_ci = case_when(
      p.value<0.05 ~ 'SIGNIFICANT',
      TRUE ~ 'INSIGNIFICANT'))

lm_police_final_df <- lm_police_final_df %>% 
  mutate(
    race_or_gender = case_when(
      str_detect(term, 'gender') ~ 'gender',
      TRUE ~ 'race'))

view(lm_police_final_df)
?facet_grid
lm_police_final_df %>%
  filter(term %in% term_final) %>%
  mutate(term = fct_reorder(term, estimate, .desc = TRUE)) %>%
  ggplot(aes(x=term, y=estimate)) + 
  geom_bar(stat='identity', aes(fill=significant_95_ci), width=.5) + 
  facet_grid(rows = vars(race_or_gender),
             scales = "free", space = 'free') +
  labs(subtitle="Salaries Compared with White Male Officer", 
       title= "Police Department Equity") + coord_flip()


?labs
####personal stories
df_common_jobs_police

job_count <- df_common_jobs_police %>%
  group_by(job_titles) %>%
  summarise(n_size=n()) %>%
  arrange(desc(n_size))

head(job_count)

job_count <- df_common_jobs_police %>%
  filter(job_titles=='POLICE OFFICER') %>%
  group_by(gender, final_race_two) %>%
  summarise(n_size=n()) %>%
  arrange(desc(n_size))

view(job_count)

personal_df<-read_csv('personal_data.csv')
personal_df$modeled_salary <- predict(
  lm_police_final, personal_df)
view(personal_df)
#####check accuracy of prediction

avg_salaries <- df_common_jobs_police %>%
  filter(job_titles=='POLICE OFFICER') %>%
  group_by(gender, final_race_two) %>%
  summarise(
    avg_salary=mean(annual_salary),
    n_size=n()) %>%
  arrange(desc(n_size))
view(avg_salaries)

write_csv(avg_salaries,'avg_salaries.csv')
write_csv(personal_df,'modeled_salaries.csv')


####FINAL PLOTTING
personal_final <- left_join(personal_df, job_count,
                            by = c('gender', 'final_race_two')
                            )
view(personal_final)

personal_final %>%
  mutate(final_race_two = fct_reorder(final_race_two, 
        modeled_salary, .desc = TRUE)) %>%
  ggplot(
    aes(x=final_race_two, y=modeled_salary)) + 
    geom_point(aes(col=gender, size=n_size)) 


avg_salaries %>%
  filter(final_race_two!='NA') %>%
  filter(gender!='NA') %>%
  mutate(final_race_two = 
      fct_reorder(final_race_two, 
      avg_salary, .desc = TRUE)) %>%
  ggplot(
    aes(x=final_race_two, y=avg_salary)) + 
  geom_point(aes(col=gender, size=n_size)) 

