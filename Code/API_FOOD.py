from edamam import Edamam
import json
import pandas as pd

e = Edamam(nutrition_appid='',
           nutrition_appkey='',
           recipes_appid='',
           recipes_appkey='',
           food_appid='',
           food_appkey='')

#nutrient = e.search_nutrient("1 large apple")
#food = e.search_food("coke")

########## USE THE CODE HERE TO DO AN API PULL. BE CAREFUL
#recipe = e.search_recipe("onion and chicken")
##########


test = json.dumps(recipe)

##For specific usage
#for recipe in e.search_recipe("onion and chicken"):
#    print(recipe)
#    print(recipe.calories)
#    print(recipe.cautions, recipe.dietLabels, recipe.healthLabels)
#    print(recipe.url)
#    print(recipe.ingredient_quantities)
#    break

#for nutrient_data in e.search_nutrient("2 egg whites"):
#    print(nutrient_data)
#    print(nutrient_data.calories)
#    print(nutrient_data.cautions, nutrient_data.dietLabels,
#          nutrient_data.healthLabels)
#    print(nutrient_data.totalNutrients)
#    print(nutrient_data.totalDaily)
#
#for food in e.search_food("coffee and pizza"):
#    print(food)
#    print(food.category)

with open('data1.txt', 'w') as outfile:
    json.dump(recipe['hits'][1], outfile)

#hits is the full json pull that we want. The following reads one to see.
a = recipe['hits'][1]

#writing to multiple lines
#with open('allrecipes_small.json', 'w') as outfile:
#    for item in mydata:
#        json.dump(item, outfile)
#        outfile.write('\n')