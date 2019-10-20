import json
import my_functions

N = 50 #read first 50 lines to sandbox
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

firstlist = my_functions.ingredients_list(mydata[0]['ingredients'],measurement_corpus)
print(firstlist)

firstmethods = my_functions.methods_list(mydata[0]['instructions'],cookingmethods_corpus)
print(firstmethods)

#writing to multiple lines
#with open('allrecipes_small.json', 'w') as outfile:
#    for item in mydata:
#        json.dump(item, outfile)
#        outfile.write('\n')