library(tidyverse)


df_race <- read_csv("census_2010_race.csv")
head(df_race)

df_race$pctaian[
  which(
    is.na(
      as.numeric(df_race$pctaian)
    )
  )
]


df_race$pctaian <- as.numeric(df_race$pctaian)
df_race$pctblack <- as.numeric(df_race$pctblack)

final_col <- c('name', 'pctwhite', 'pctblack', 'pctapi','pctaian', 'pcthispanic')
race_col<- c('pctwhite', 'pctblack', 'pctapi','pctaian', 'pcthispanic')

df_race_filter <- df_race %>%
  select(final_col)

head(df_race_filter)

df_long <- df_race_filter %>%
  pivot_longer(
    col=race_col,
    names_to = 'race_col',
    values_to= 'percent'
  )

df_long_2 <- df_race_filter %>%
  pivot_longer(
    col=!name,
    names_to = 'race_col',
    values_to= 'percent'
  )

head(df_long_2)


df_long_slice <- df_long %>%
  group_by(name) %>%
  slice(which.max(percent))



df_long_slice$race_col <- str_replace(df_long_slice$race_col,
                                      '^pct',
                                      ''
                                      )

head(df_long_slice)

#TO DO
#FOR EACH ROW, FIND THE MAXIMUM VALUE, IGNORE name
#FIND THE CORRESOPNDING INDEX TO THE MAXIMUM VALUE
#FIND THE COLUMN HEADER, THAT CORRESPOND TO THE CORRESOPNDING INDEX

find_max_index <- function(row) {
  which(row==max(row))[1]
}

test_vec<-c(11,13,15,14)
test_vec==max(test_vec)
which(test_vec==max(test_vec))

head(df_race_filter)

colnames(df_race_filter)

colnames(df_race_filter[race_col])

head(df_race_filter[race_col])

colnames(df_race_filter[race_col])[
  apply(
    df_race_filter[race_col],
    MARGIN=1,
    find_max_index
  )
  ]
df_race_filter$race_final <- colnames(df_race_filter[race_col])[
  apply(
    df_race_filter[race_col],
    MARGIN=1,
    find_max_index
  )
  ]

View(df_race_filter)

test_vec_2<-c(11,13,15,14,15)

find_max_index(test_vec_2)

find_first_max_index <- function(row) {
  head(which(row==max(row)),1)[1]
}

find_last_max_index <- function(row) {
  tail(which(row==max(row)),1)[1]
}

find_last_max_index(test_vec_2)


