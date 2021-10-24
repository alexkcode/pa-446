library(tidyverse)

df_csv_tidy <- read_csv("test_csv_simple.csv")
head(df_csv_tidy)

df_csv_test_tidy <- read_csv("test_csv.csv")
df_csv_test_base <- read.csv("test_csv.csv")
head(df_csv_test_tidy)
head(df_csv_test_base)

df_csv_test_tidy_2 <- read_csv("test_csv_2.csv")
head(df_csv_test_tidy_2)

test<- read_delim()
df_gender<-read_delim("IL.TXT",
                      delim=",",
                      col_names = c('state','gender','born_year','fist_name','count'),
                      col_types = list('c','c','i','c','i'))
head(df_gender)

df <- read_csv("pa446_chicago_salaries.csv")

head(df$Name)

df_sep <- df %>%
  separate(Name, c('last_name','first_mid_name'), sep=",")

head(df_sep)
df_sep_2 <- df_sep %>%
  mutate(first_mid_name = str_trim(first_mid_name)) %>%
  separate(first_mid_name, c('first_name','mid_name'), sep=" ")

head(df_gender)

#earlier, i misspelled "first_name" "fist_name", so we are going with that now
df_joined=left_join(df_sep_2, df_gender, by=c('first_name'='fist_name'))
write.csv(df_joined,"joined.csv")

df_sep_2$first_name<-tolower(df_sep_2$first_name)
df_gender$fist_name<-tolower(df_gender$fist_name)

head(df_sep_2)
head(df_gender)

df_joined_2=left_join(df_sep_2, df_gender, by=c('first_name'='fist_name'))
write.csv(df_joined_2,"joined_2.csv")

dim(df_sep_2)
View(df_gender)
dim(df_joined_2)

View(df_joined_2)

df_gender_distinct <- df_gender %>%
  distinct(gender, fist_name)

View(df_gender_distinct)
dim(df_gender_distinct)


df_joined_3=left_join(df_sep_2, df_gender_distinct, 
                      by=c('first_name'='fist_name'))
write.csv(df_joined_3,"joined_3.csv")

dim(df_sep_2)

dim(df_joined_3)

test<-arrange(df_gender_distinct,fist_name)
View(test)


head(df_gender)

df_gender_slice <- df_gender %>%
  group_by(fist_name) %>%
  slice(which.max(count))

View(df_gender_slice)
dim(df_gender_slice)

df_joined_4=left_join(df_sep_2, df_gender_slice, 
                      by=c('first_name'='fist_name'))
write.csv(df_joined_4,"joined_4.csv")   


dim(df_joined_4)
sum(is.na(df_joined_4$gender))