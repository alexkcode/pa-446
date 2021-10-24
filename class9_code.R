library(broom)
library(purrr)
library(tidyverse)

df_311 <-read_csv('boston_311_2020.csv')
head(df_311)
view(head(df_311,10))

first_pass <- df_311 %>%
  filter(case_status=='Closed') %>%
  mutate(close_time = difftime(closed_dt, open_dt,
                               units='hours')) %>%
  group_by(department) %>%
  summarise(avg_close_time = mean(close_time),
            med_close_time = median(close_time),
            n_size=n()) %>%
  arrange(med_close_time)

first_pass

subject_reason_type <- df_311 %>%
  group_by(subject, reason, type) %>%
  summarise(n_size = n()) %>%
  arrange(desc(n_size))
subject_reason_type


dept_reason_type_group <- df_311 %>%
  filter(case_status=='Closed') %>%
  mutate(close_time = difftime(closed_dt, open_dt,
                               units='hours')) %>%
  group_by(subject, reason, type) %>%
  summarise(n_size = n(),
            median_close_time=median(close_time),
            avg_close_time=mean(close_time)) %>%
  filter(n_size > 100) %>%
  arrange(desc(median_close_time))

view(dept_reason_type_group)


###both department level and ticket level information
department_group <- df_311 %>%
  filter(case_status=='Closed') %>%
  mutate(close_time = difftime(closed_dt, open_dt,
                               units='hours')) %>%
  group_by(subject) %>%
  summarise(n_size = n(),
            dept_median_close_time=median(close_time),
            avg_close_time=mean(close_time)) %>%
  arrange(dept_median_close_time)


department_group_select <- arrange(department_group, 
                                   dept_median_close_time) %>%
  mutate(department_rank = 1:nrow(department_group)) %>%
  select(subject, department_rank, 
         dept_median_close_time)

department_group_select


joined_df <- dept_reason_type_group %>%
  left_join(department_group_select,
            by = 'subject') %>%
  mutate(
    diff_dept_queue = 
      abs(dept_median_close_time - median_close_time)
  ) %>%
  arrange(desc(diff_dept_queue))

view()
view(joined_df)

write.csv(joined_df, 'joined_df_b.csv')

###confounding factors
source_closetime <- df_311 %>%
  filter(case_status=='Closed') %>%
  mutate(close_time = difftime(closed_dt, open_dt,
                               units='hours')) %>%
  group_by(source) %>%
  summarise(n_size = n(),
            med_close_time=median(close_time)) %>%
  arrange(med_close_time)

source_closetime



#####linear reg

lm_df <- df_311 %>%
  filter(case_status=='Closed') %>%
  mutate(close_time = difftime(closed_dt, open_dt,
                               units='hours')) %>%
  mutate(close_time_int = as.numeric(close_time))  %>% 
  unite(dept_concat, subject:type,remove = FALSE)

view(head(lm_df,10))
lm_explore <- lm(close_time_int ~ 
                   dept_concat + source + neighborhood,
                 data = lm_df)

lm_explore_df <- map_df(list(summary(lm_explore)), tidy)
view(lm_explore_df)

significant_coef <- lm_explore_df %>%
  filter(p.value < 0.05)  %>%
  arrange(desc(estimate))
view(significant_coef)
# lm_explore_b <- lm(close_time_int ~ 
#                      subject + reason + type + source,
#                    data = lm_df)

summary(lm_explore_b)