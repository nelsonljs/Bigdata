# -*- coding: utf-8 -*-
"""
Created on Thu Oct 10 17:34:12 2019

@author: chest
"""

from os import chdir
from itertools import compress
import json
import re

#Removal Functions
#1. Get that measurement stopword list (intersection between measurement & food)
#2. Cut off comma and brackets
#3. remove numbers

def removalRules(text):
    text = removeParanthesis(text)
#    text = removeMeasure(text)
    text = removeNumbers(text)
    text = removePunctuation(text)
    text = text.strip()
    return text

def removeParanthesis(text):
    text = re.sub(r"\([^)]*\)", "", text)
    return text
#def removeMeasure(text):
#    text = re.sub(r"\d+\s+\w+", "", text)
#    return text    
def removeNumbers(text):
    text = re.sub(r"\d+", "", text)
    return text
def removePunctuation(text):
    text = re.sub(r"[//]", " ", text)
    return text

#Get list of related food:
def wn_build(term):
    from nltk.corpus import wordnet as wn
    synsets = wn.synsets(term)
    master_list = []
    for synset in synsets:
        food = list(set([w for s in synset.closure(lambda s:s.hyponyms()) for w in s.lemma_names()]))
        master_list.append(food)
    set_list = [item.replace("_", " ") for master in master_list for item in master]
    set_list = list(set(set_list))
    return set_list
    
#Extract Measurement 
def extractMeasurement(text):
    text = removeParanthesis(text)
    matched = re.search(r"(\d+\s+[a-zA-Z]+)", text, re.IGNORECASE)
    if matched != None:
        matched = matched.group(0)
        matched = re.search(r"\d+\s+(\w+)", matched, re.IGNORECASE)
        measurement = matched.group(1).lower()
        return measurement
    else:
        return None

chdir("C:\\Users\\chest\\Desktop\\MTech\\Big Data\\Project\\Data")

with open("allrecipes-recipes.json") as json_file:
#    head = [next(json_file) for x in range(N)]
    json_master = json_file.readlines()

for ind, item in enumerate(json_master):
    json_master[ind] = json.loads(json_master[ind])
del ind, item

#extraction of information 
#ingredient_book = {}
#for ind, item in enumerate(json_master):
#    title = json_master[ind]["title"]
#    ingredients = json_master[ind]["ingredients"]
#    ingredient_book[ind] = {"name":title, "ing":ingredients}
ingredient_book = {}
for ind, item in enumerate(json_master):
    title = json_master[ind]["title"]
    ingredients = json_master[ind]["ingredients"]
    if title in ingredient_book.keys():
        for ing in ingredients:
            ingredient_book[title].append(ing)
            del ing
        
    else:
        ingredient_book[title] = ingredients
    del ind, item, title, ingredients

measurement_list = []
for recipe in ingredient_book.keys():
    for item in ingredient_book[recipe]:
        measurement = extractMeasurement(item)
    if measurement != None:
        measurement = measurement.lower()
        measurement_list.append(measurement)
del measurement, item, recipe

measurement_set = list(set(measurement_list))
food = wn_build("food")
intersect_food = [m not in food for m in measurement_set]
measurement_filter = list(compress(measurement_set, intersect_food))


measurement_list=["packages", "ounces", "sheets", "sprig", "jars",\
                  "dashes", "ball", "jell", "tri", "grams", "shot",\
                  "cubes", "plastic", "jarred", "bunches", "prebaked",\
                  "can", "heads", "snickers", "bibb", "stemmed", "finely",\
                  "bunches", "trays", "spears", "free", "boston", "tablespoons",\
                  "pinches", "processed", "oz", "reynolds", "pouch", "bar", "carton",\
                  "solid", "inch", "inches", "cup", "cups", "gala", "thinly", "straight",\
                  "marinated", "drops", "one", "day", "buttery", "bing", "cube", "squeezes",\
                  "reduced", "double", "tubs", "bulbs", "sparkler", "scoop", "pint", "pouches",\
                  "long", "scoops", "shells", "comet", "shucked", "bars", "lean", "head", "hershey",\
                  "minature", "to", "hank", "cornish", "ear", "frilled", "curl", "frilled", "piece",\
                  "servings", "piece", "kaiser", "tenderflake", "dark", "servings", "quarts", "plain",\
                  "serving", "spiral", "skewers", "skewer", "navel", "quartered", "liter", "belgian", "bowl",\
                  "jigger", "o", "bottle", "portugese", "key", "foil", "thick", "roma", "birthday", "won", "slightly",\
                  "tablets", "raw", "bittersweet", "packages", "jars", "weight", "teaspoons", "stalk", "unbaked", "feet",\
                  "mcintosh", "twist", "roasting", "canned", "tall", "recipes", "square", "sprigs", "slow", "envelopes",\
                  "warmed", "untreated", "ready", "archer", "inner", "packaged", "cans", "warm", "toothpick", "fresh", "fun", "bag",\
                  "hierloom", "bunch", "pkg", "strip", "unopened", "gallon", "ball", "skinned", "quart", "bouquet", "tubes", "vine", "sheet",\
                  "pieces", "splash", "container", "sliver", "purchased", "sliced", "racks", "half", "cubed", "wraps", "refrigerated", "sleeve", "london",\
                  "slices", "naval", "cleaned", "whisked", "pinch", "full", "sleeves", "pot", "metal", "sturdy", "muddled", "packets", "stalks", "prepared", "thin",\
                  "summer", "m", "large", "ring", "rolls", "box", "oven", "splashes", "plastic", "well", "loaves", "tiny", "sterilized", "market", "no", "sheets", "halves", "slice",\
                  "slabs", "bricks", "pods", "gallons", "balls", "pre", "spot", "tub", "grilled", "torn", "canning", "slider", "brie", "cups", "or", "cubes", "pounds", "crumpets", "wedges", "crushed",\
                  "individually", "sticks", "twists", "ears", "toothpicks", "links", "t", "cloves", "grinds", "trimmed", "drizzle", "tube", "shots", "organic", "boxes", "strips", "dash", "squirts", "diced", "beaten", "containers", "boneless",\
                  "skirt", "ounce", "hot", "unwrapped", "straw"] 
#dried, stale, jet, worm, fillets, multi
measurement_list = list(set(measurement_list))