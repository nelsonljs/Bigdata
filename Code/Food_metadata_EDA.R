pacman::p_load(tidyverse, neo4r, igraph, visNetwork)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

mydf = read.csv("user_filtered.csv", header = TRUE)
recipe_id = read.csv("Recipe_identifier.csv", header = TRUE)

TF = c(TRUE, FALSE)
recipe_id$isVegan = TF[runif(100, min=1, max =3)]
recipe_id$isNuts = TF[runif(100, min=1, max =3)]

serves = c("2-3 pax", "4-6 pax", ">7 pax")
recipe_id$serves = serves[runif(100, min=1, max =4)]

cookingmethods = c("bake","deep-fry","grill")
recipe_id$cooking_methods = cookingmethods[runif(100, min=1, max =4)]

recipe_id$calories = floor(runif(100, min=1, max=16)) * 100

write.csv(recipe_id,"filtered_list.csv")
