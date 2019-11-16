import json
import my_functions
import pandas as pd

N = 100 #read first 50 lines to sandbox
with open('data/allrecipes_small.json') as json_file:
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
totaltimelist= []

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
    totaltimelist.append(item['cook_time_minutes']+item['prep_time_minutes'])

ingredientsdf = pd.DataFrame(ingredientslist)
ingredientsdf = ingredientsdf.rename(columns = lambda x : 'ingredient_' + str(x))

methodsdf = pd.DataFrame(methodslist)
methodsdf = methodsdf.rename(columns = lambda x : 'method_' + str(x))

#Assemble a data frame with for each item
mydf = pd.DataFrame({'Recipe':recipelist,
                     'Average Review': reviewslist,
                     'Review Count': reviewscountlist,
                     'Prep Time': totaltimelist})
    
mydf = pd.concat([mydf, ingredientsdf, methodsdf], axis=1)
mydf1 = mydf[['Recipe','Average Review','Review Count','Prep Time']]
mydf1.to_csv('Recipe_identifier.csv')

mydf2 = mydf.iloc[:,[0]+list(range(4,4+len(ingredientsdf.columns)-1))]
mydf2 = mydf2.melt(id_vars=['Recipe'], value_name = 'Ingredients')
mydf2 = mydf2.iloc[:,[0,2]]
mydf2 = mydf2[mydf2['Ingredients'].notnull()]
mydf2.to_csv('Recipe_Ingredients_Graph.csv')

mydf3 = mydf.iloc[:,[0]+list(range(4+len(ingredientsdf.columns),4+len(ingredientsdf.columns)+len(methodsdf.columns)-1))]
mydf3 = mydf3.melt(id_vars=['Recipe'], value_name = 'Methods')
mydf3 = mydf3.iloc[:,[0,2]]
mydf3 = mydf3[mydf3['Methods'].notnull()]
mydf3.to_csv('Recipe_Methods_Graph.csv')


#mydf.to_csv('sampledf.csv')    
#writing into multiple lines
######Creating smaller jsons for github.
#with open('allrecipes_small.json', 'w') as outfile:
#    for item in mydata:
#        json.dump(item, outfile)
#        outfile.write('\n')

###(update by zhou)

#pick only nouns
#word_tokenize
from nltk.tokenize import word_tokenize
words=[]
for i in mydf2['Ingredients']:
        words.extend(word_tokenize(i))
# pick the noun
nltk.download('averaged_perceptron_tagger')
nltk.download('universal_tagset')
from nltk.tag import pos_tag
pos_tag(words,tagset='universal')
AN=[]
for a,b in pos_tag(words,tagset='universal'):
    if b=="NOUN":
        AN.append(a)
#match the words
text_new_df = mydf2['Ingredients'].apply(lambda x: " ".join(x for x in x.split() if x in AN))
mydf2['Ingredients']=text_new_df

mydf2.to_csv('Recipe_Ingredients_Graph_new.csv')