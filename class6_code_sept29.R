library(broom)
library(purrr)
library(tidyverse)


df_race_last_first <-read_csv('salaries_sept29.csv')
view(df_race_last_first)

df_aviation <- df_race_last_first %>%
  filter(Department == 'AVIATION')

?aov
?oneway.test


oneway.test(df_aviation$annual_salary ~
           df_aviation$final_race_two)

largest_dept_df <- df_race_last_first %>%
  group_by(Department) %>%
  mutate(
    n_size = summarise(n())
    ) %>%
  arrange(n_size)

?arrange
head(largest_dept_df)

anova_results_df<-tibble()
for (departm in largest_dept_vector)
{
  df_loop <- df_race_last_first %>%
    filter(Department == departm)
  results<- oneway.test(df_loop$annual_salary ~ 
                          df_loop$final_race_two,
                        var.equal=FALSE)
  anova_df <- map_df(list(results), tidy)
  anova_df$dept <- departm
  anova_results_df<- anova_results_df %>%
    rbind(anova_df)
}



####linear regression
dim(df_aviation)
?lm
lm_a <- lm(annual_salary ~ final_race_two,
           data = df_aviation)
summary(lm_a)
lm_a_df <- map_df(list(summary(lm_a)), tidy)
view(lm_a_df)
write.csv(lm_a_df, 'lm_results.csv')

install.packages('fastDummies')
library('fastDummies')

df_aviation_nona<-df_aviation %>%
  filter(!is.na(final_race_two))

df_race_dummied <- dummy_cols(df_aviation_nona, 
                    select_columns = 'final_race_two')
view(df_race_dummied)
head(df_race_dummied)

lm_b <- lm(annual_salary ~ final_race_two_hispanic +
             final_race_two_black + final_race_two_api,
           data = df_race_dummied)
summary(lm_b)

lm_b_df <- map_df(list(summary(lm_b)), tidy)
view(lm_b_df)
write.csv(lm_b_df, 'lm_b_results.csv')

lm_c <- lm(annual_salary ~ final_race_two_hispanic +
             final_race_two_black + final_race_two_api + gender,
           data = df_race_dummied)
summary(lm_c)
lm_c_df <- map_df(list(summary(lm_c)), tidy)
view(lm_c_df)
write.csv(lm_c_df, 'lm_c_results.csv')

df_race_dummied$random_num <- sample(100, 
                          size=nrow(df_race_dummied),
                          replace=TRUE)

df_race_dummied <- df_race_dummied %>%
  mutate(imput_gender = case_when(
    !is.na(gender) ~ gender,
    (is.na(gender) & random_num<=75) ~ 'M',
    TRUE ~ 'F'))

lm_d <- lm(annual_salary ~ final_race_two_hispanic +
             final_race_two_black + final_race_two_api + imput_gender,
           data = df_race_dummied)

summary(lm_d)
lm_d_df <- map_df(list(summary(lm_d)), tidy)
write.csv(lm_d_df, 'lm_d_results.csv')


predict_df <- read_csv('predict_sept29.csv')
head(predict_df)
predict_df$predicted_salary <- predict(lm_d, predict_df)
?predict

view(predict_df)