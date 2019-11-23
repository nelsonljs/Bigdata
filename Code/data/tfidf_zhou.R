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
nrow_u=nrow(uni)
# create corpus
vector = VectorSource(uni$ingredient) 
corpus = VCorpus(vector)

dtm <- DocumentTermMatrix(corpus)
dtm_ti <- weightTfIdf(dtm)
dtm_ti

mat_ti <- as.matrix(dtm_ti)

#simlarity matrix
dist_mat_jaccard <- as.matrix(dist(mat_ti, method = "jaccard"))
hist(dist_mat_pearson)
#Barry Code
# jacardsim = function(x,y) { validx= !is.na(x); validy= !is.na(y);
# sum(as.integer(validx&validy))/sum(as.integer(validx|validy))}

#for efficient computation on sparse matrix
sim_mat_cos <- crossprod_simple_triplet_matrix(t(dtm_ti))/(sqrt(col_sums(t(dtm_ti)^2) %*% t(col_sums(t(dtm_ti)^2))))

#select the middle point
sim_mat_cos

#binary the data once (more than 0.1) apply 1
#(less than 0.1) apply 0
data = as.matrix(sim_mat_cos)
data = as.vector(sim_mat_cos)

hist(data)

voting = function(value)
{
  if (value < 0.1)
    return(0)
  else
    return(1)
  
}

data = sapply(data,voting)
data = matrix(data, nrow = nrow_u, ncol = nrow_u)

#match the recipe
colnames(data)<-Graph$Recipe
rownames(data)<-Graph$Recipe

#create function to save relationship
mtrx2cols = function(m1,m2,val1,val2){
  lt = lower.tri(m1)  #获取下半角为TRUE，上半角为FALSE的同维度矩阵；
  res = data.frame(row = row(m1,as.factor = T)[lt],  #返回矩阵m1的下半角元素对应的行名
                   col = col(m1,as.factor = T)[lt],  #返回矩阵m1的下半角对应的列名
                   val1 = m1[lt], val2= m2[lt]) #按列依次获取矩阵下半角的元素
  names(res)[3:4] = c(val1,val2) #对后两列重命名，支持多个矩阵合并
  return(res)
}
#result
res = mtrx2cols(data,data,'relation1','relation2')
res2=res[which(rowSums(res==0)==0),]
view(res2)
res3=res2[,c(1:2)]

view(res3)


write.csv(res3,'res3.csv')

