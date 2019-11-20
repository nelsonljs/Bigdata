library(tidyverse)
#Load csv
path = 'C:/Users/KE/Desktop/RI.csv'
df = read.csv(path, stringsAsFactors = FALSE)
# df_Ing = df %>%
#   select(Ingredients) %>%
#   distinct() %>%
#   arrange(Ingredients)


#Display list all ingredients
query = c('salt','sugar')
df1 = df
a <- df %>%
  unique() %>%
  filter(Ingredients %in% query) %>%
  group_by(Recipe) %>%
  right_join(df1) %>%
  arrange(Ingredients) %>%
  summarise(toString(Ingredients)) %>%
  ungroup()

a<-data.frame(a)
#%>%
  dplyr::count(Recipe, name = 'num') %>%
  filter(num == length(query))
