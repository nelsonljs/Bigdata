setwd('/Users/zhoujingyu/Desktop/')
library(pacman)
p_load(tidyverse,tm,stringr,proxy,plyr,slam)

#load data
Graph=read.csv('sampledf.csv')
head(Graph)

Graph_sub=Graph[ , c("ingredient_0",'ingredient_1','ingredient_2','ingredient_3',
           'ingredient_4','ingredient_5','ingredient_6','ingredient_7',
           'ingredient_8','ingredient_9','ingredient_10',
           'ingredient_11','ingredient_12','ingredient_13')]
head(Graph_sub)

#delete the space
str_replace_all(Graph_sub$ingredient_0, " ","")
str_replace_all(Graph_sub$ingredient_1, " ","")
str_replace_all(Graph_sub$ingredient_2, " ","")
str_replace_all(Graph_sub$ingredient_3, " ","")
str_replace_all(Graph_sub$ingredient_4, " ","")
str_replace_all(Graph_sub$ingredient_5, " ","")
str_replace_all(Graph_sub$ingredient_6, " ","")
str_replace_all(Graph_sub$ingredient_7, " ","")
str_replace_all(Graph_sub$ingredient_8, " ","")
str_replace_all(Graph_sub$ingredient_9, " ","")
str_replace_all(Graph_sub$ingredient_10, " ","")
str_replace_all(Graph_sub$ingredient_11, " ","")
str_replace_all(Graph_sub$ingredient_12, " ","")
str_replace_all(Graph_sub$ingredient_13, " ","")

Graph_sub_backup = map(Graph_sub, str_replace_all, pattern=" ", replacement="")


#check the data type
# str(Graph_sub)
# str(Graph_sub_backup)

#merge ingredient in one column
uni=unite(data=Graph_sub,'ingredient',sep=' ',"ingredient_0",'ingredient_1','ingredient_2','ingredient_3',
      'ingredient_4','ingredient_5','ingredient_6','ingredient_7',
      'ingredient_8','ingredient_9','ingredient_10',
      'ingredient_11','ingredient_12','ingredient_13')

# create corpus
vector = VectorSource(uni$ingredient) 
corpus = VCorpus(vector)

dtm <- DocumentTermMatrix(corpus)
dtm_ti <- weightTfIdf(dtm)
dtm_ti

mat_ti <- as.matrix(dtm_ti)

#simlarity matrix
dist_mat_pearson <- as.matrix(dist(mat_ti, method = "pearson"))

#for efficient computation on sparse matrix
sim_mat_cos <- crossprod_simple_triplet_matrix(t(dtm_ti))/(sqrt(col_sums(t(dtm_ti)^2) %*% t(col_sums(t(dtm_ti)^2))))

#select the middle point

sim_mat_cos

#binary the data once (more than 0.1) apply 1
#(less than 0.1) apply 0
data = as.matrix(sim_mat_cos)
data = as.vector(sim_mat_cos)

voting = function(value)
{
  if (value > 0.1)
    return(1)
  else
    return(0)
  
}

data = sapply(data,voting)
data = matrix(data, nrow = 50, ncol = 50)

#match the recipe
colnames(data)<-Graph$Recipe
rownames(data)<-Graph$Recipe


write.csv(data,'sim_mat.csv')

