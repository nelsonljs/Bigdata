# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 20:48:23 2019

@author: chest
"""


from os import chdir
import sys
import re

chdir(r"C:\Users\chest\Desktop\MTech\Big Data\Project\Data\Food Corpus")

def clean_web(text):
    text = re.sub(r"\([^)]*\)", "", text)
    or_check = bool(re.compile(r' or ', re.I).search(text))
    comma_check = ("," in text)
    output_list = []
    if (or_check or comma_check):
        if (or_check and comma_check):    
            text_list = text.split("or")
            for te in text_list:
                if (("," in te)):
                    comma_list = te.split(",")
                    for com in comma_list:
                        com = com.strip()
                        output_list.append(com)
                else:
                    te = te.strip()
                    output_list.append(te)
            return output_list
            sys.exit()
        if (or_check):
            text_list = re.split(r"\sor\s", text)
            for te in text_list:
                te = te.strip()
                output_list.append(te)
            return output_list
        if (comma_check):
            text_list = text.split(",")
            for te in text_list:
                te = te.strip()
                output_list.append(te)
            return output_list
    else:
        return text

#to extract list
def extract_list(lis):
    output = []
    for li in lis:
        li = li.lower()
        trans_li = clean_web(li)
        if (type(trans_li)==list):
            for trans in trans_li:
                output.append(trans)
        else:
            output.append(trans_li)
    return output

text_names = ["cheeses.txt", "common.txt", "fruits.txt",
             "herbs.txt", "meats.txt", "nuts.txt", 
             "seafood.txt", "sugars.txt", "vegetables.txt"]

ingredient_corpus = []

for file_name in text_names:    
    with open(file_name) as file:
        file_list = file.read().splitlines()
        clean_list = extract_list(file_list)
#        ingredient_corpus.append(clean_list)
        for clean in clean_list:
            ingredient_corpus.append(clean)
        del clean_list, clean, file_list, file_name

ingredient_set = list(set(ingredient_corpus))

#with open("Overall.txt", "w") as final_file:
#    for ing in ingredient_set:
#        final_file.write(ing)
#        final_file.write("\n")
        

#testing of the functions
test = ['1/2 cup unsalted red pepper, chilled and cubed', '1 cup chopped onion', '1 3/4 cups cornmeal']

output = []            
for item in test:
    temp_output = []
    for set_tracker in range(len(ingredient_set)):
        check = bool(re.search(ingredient_set[set_tracker], item))
        if (check == True):    
            temp_output.append(ingredient_set[set_tracker])
    if (len(temp_output) != 0):
        output.append(temp_output[[len(i) for i in temp_output].index(max([len(i) for i in temp_output]))])
            
            
def extractIngredient(li, ingredient_set):
    output = []
    for item in li:
        temp_output = []
        for set_tracker in range(len(ingredient_set)):
            check = bool(re.search(ingredient_set[set_tracker], item))
            if (check == True):    
                temp_output.append(ingredient_set[set_tracker])
        if (len(temp_output) != 0):
            temp_counter = 0
            temp_tracker = 0
            for temp in range(len(temp_output)):
                count_temp = len(temp_output[temp])
                if (count_temp > temp_counter):
                    temp_tracker = temp
                    temp_counter = count_temp
            output.append(temp_output[temp_tracker])
#            output.append(temp_output[[len(i) for i in temp_output].index(max([len(i) for i in temp_output]))])
    return output

sample = ['1/2 cup unsalted butter, chilled and cubed', '1 cup chopped onion', '1 3/4 cups cornmeal', '1 1/4 cups all-purpose flour', '1/4 cup white sugar', '1 tablespoon baking powder', '1 1/2 teaspoons salt', '1/2 teaspoon baking soda', '1 1/2 cups buttermilk', '3 eggs', '1 1/2 cups shredded pepperjack cheese', '1 1/3 cups frozen corn kernels, thawed and drained', '2 ounces roasted marinated red pepper, drained and chopped', '1/2 cup chopped fresh basil']
s2 = ["red pepper", "blue lobster"]

test = extractIngredient(sample, ingredient_set)
print(test)

    



