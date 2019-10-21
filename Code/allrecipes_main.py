import json
import my_functions
import pandas as pd

N = 50 #read first 50 lines to sandbox
with open('allrecipes-recipes.json') as json_file:
    head = [next(json_file) for x in range(N)]

with open('measurements.txt') as file:
    measurement_corpus = set(file.read().splitlines())
    
with open('cookingmethods.txt') as file:
    cookingmethods_corpus = set(file.read().splitlines())

mydata = []
for item in head:
    mydata.append(json.loads(item))
del head

#To create a dataframe, it's better to append your own list first before combining.
ingredientslist = []
methodslist = []
recipelist = []
reviewslist = []
reviewscountlist = []

for item in mydata:
    firstlist = my_functions.ingredients_list(item['ingredients'],measurement_corpus)
    ingredients = []
    #take only the first 15 ingredients.
    for ing in firstlist[0:14]:
        ingredients.append(' '.join(ing))
    
    ingredientslist.append(ingredients)
    
    #Working on methods
    firstmethods = my_functions.methods_list(item['instructions'],cookingmethods_corpus)
    firstmethods = set(x for lst in firstmethods for x in lst) #convert firstmethods into a set to get rid of duplicates
    methodslist.append(list(firstmethods)[0:9])
    
    recipelist.append(item['title'])
    reviewslist.append(item['rating_stars'])
    reviewscountlist.append(item['review_count'])   

ingredientsdf = pd.DataFrame(ingredientslist)
ingredientsdf = ingredientsdf.rename(columns = lambda x : 'ingredient_' + str(x))

methodsdf = pd.DataFrame(methodslist)
methodsdf = methodsdf.rename(columns = lambda x : 'method_' + str(x))

#Assemble a data frame with for each item
mydf = pd.DataFrame({'Recipe':recipelist,
                     'Average Review': reviewslist,
                     'Review Count': reviewscountlist})
    
mydf = pd.concat([mydf, ingredientsdf, methodsdf], axis=1)
mydf.to_csv('sampledf.csv')    
#writing into multiple lines
######Creating smaller jsons for github.
#with open('allrecipes_small.json', 'w') as outfile:
#    for item in mydata:
#        json.dump(item, outfile)
#        outfile.write('\n')

