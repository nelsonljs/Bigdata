#!/usr/bin/env python
# coding: utf-8

# In[1]:


####----Check correct working directory----####

import os
wd = os.getcwd()
if(wd != '/home/centos/BigData/02_cleaning/'):
    from os import chdir
    chdir("/home/centos/BigData/02_cleaning/")
    print("Directory changed to: " + wd)
else:
    print("Correct current directory: " + wd)


# In[2]:


####----Import dictionary----####
with open('dict/Overall_Master.txt', encoding = 'ISO-8859-1') as file:
    ingredient_set = file.read().splitlines()

print("List length: " +str(len(ingredient_set)))
#print(ingredient_set)
#ingredient_set = ingredient_set[1:10]


# In[3]:


####----Connect to Spark via PySpark----####
get_ipython().run_line_magic('pip', 'install PyArrow')
get_ipython().run_line_magic('pip', 'install pyspark')
from pyspark import SparkContext
from pyspark.sql import SparkSession, SQLContext
from pyspark.sql.functions import udf, explode, col, lit, monotonically_increasing_id, unix_timestamp
from pyspark.sql.types import *
from pyspark.ml.feature import HashingTF, IDF, Tokenizer, Normalizer, CountVectorizer
from pyspark.mllib.linalg.distributed import IndexedRow, IndexedRowMatrix
import pandas as pd
import time
import datetime
import json
import re
import findspark
print("Connecting Spark")

#sc.close()
#sqlContext.stop()


#Settings necessary for sandboxing otherwise Pyspark too slow on standalone
SparkContext.setSystemProperty('spark.executor.memory', '2g')
sc = SparkContext("local", "App Name")
sqlContext = SQLContext(sc)
sqlContext.setConf("spark.sql.shuffle.partitions", "50")
sqlContext.setConf("spark.sql.inMemoryColumnarStorage.batchSize", "12000")
#improve toPandas() 
sqlContext.setConf("spark.sql.execution.arrow.enabled", "true")
print("\nSpark Context Created")


# In[4]:


# spark = SparkSession \
#     .builder \
#     .appName("Python Spark SQL basic example") \
#     .config("spark.some.config.option", "some-value") \
#     .getOrCreate()
# spark.conf.set("spark.executor.memory", "2g")
# print("Spark Session Created")
#Python Java issues: a drawback in using pyspark instead of Scala


# In[5]:


#Creation of filtering words
with open("dict/Overall_Master.txt") as file:
    ingredient_set = file.read().splitlines()
print("List length: " + str(len(ingredient_set)))


# In[6]:


####----Load json into Spark for data cleaning----####

recipe_src = 'allrecipes'

read_path = "/home/centos/BigData/01_source/" + recipe_src + "*.json"
#read_path = "hdfs://localhost:9000/01_raw/allrecipes*.json"

recipes_df = sqlContext.read.json(read_path)
recipes_df.printSchema()


# In[7]:


####----Create Spark DataFrame----####
recipes_df.createOrReplaceTempView("allrecipes")

#overall table
recipes_table = sqlContext.sql("SELECT title, ingredients, description, instructions, photo_url, url, rating_stars, review_count, total_time_minutes  FROM allrecipes ORDER BY RAND() LIMIT 2000")
recipes_table.show(5)

# recipes_pandas = recipes_table.toPandas()
# recipes_pandas.to_csv("recipes_sample.csv")


# In[8]:


####----Extract ingredient----####
import re

##User-defined Functions
def removeParenthesis(li):
    output = []
    for text in li:
        text = re.sub(r"\([^)]*\)", "", text)
        text = text.strip()
        output.append(text)
    return output

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
#             output.append(temp_output[[len(i) for i in temp_output].index(max([len(i) for i in temp_output]))])
    return output

sample = ['1/2 cup unsalted butter, chilled and cubed', '1 cup chopped onion', '1 3/4 cups cornmeal', '1 1/4 cups all-purpose flour', '1/4 cup white sugar', '1 tablespoon baking powder', '1 1/2 teaspoons salt', '1/2 teaspoon baking soda', '1 1/2 cups buttermilk', '3 eggs', '1 1/2 cups shredded pepperjack cheese', '1 1/3 cups frozen corn kernels, thawed and drained', '2 ounces roasted marinated red bell peppers, drained and chopped', '1/2 cup chopped fresh basil']

test = extractIngredient(sample, ingredient_set)
print(test)
print(len(ingredient_set))

##Create user defined function
udf_removeParen = udf(removeParenthesis, ArrayType(StringType()))
udf_extractIngredient = udf(lambda x: extractIngredient(x,ingredient_set), ArrayType(StringType()))
udf_countList = udf(lambda x: len(x), IntegerType())

print("UDF Successful.")


# In[9]:


#User Defined Function - Feature Engineering 
#Labels: Vegetarian, Lactose, Nut, Seafood

#Safer to start off as non-vegetarian
def detectVege(li, vegDetect_list):
    label = 0
    detect_list = []
    for text in li:
        if text in vegDetect_list:
            detect_list.append(text)
    if (len(detect_list) == 0):
        label = 1
    return label

#Safer to start off as positive allergy
def detectNut(li):
    label = 1
    detect_list = []
    for text in li:
        if ("nut" in text):
            detect_list.append(text)
    if (len(detect_list) == 0):
        label = 0
    return label

def detectDairy(li):
    label = 1
    dairy_list = ["cheese", "milk", "yoghurt", "cream"]
    detect_list = []
    for text in li:
        if (text in dairy_list):
            detect_list.append(text)
    if (len(detect_list) == 0):
        label = 0
    return label

def detectSeafood(li, seaDetect_list):
    label = 1
    detect_list = []
    for text in li:
        if text in seaDetect_list:
            detect_list.append(text)
    if (len(detect_list) == 0):
        label = 0
    return label


with open("dict/vegDetect.txt") as veg_file:
    vegDetect_list = veg_file.read().splitlines()

with open("dict/seafoodDetect.txt") as seafood_file:
    seaDetect_list = seafood_file.read().splitlines()
    
#create user defined function
udf_detectVege = udf(lambda x: detectVege(x, vegDetect_list), IntegerType())
udf_detectNut = udf(detectNut, IntegerType())
udf_detectDairy = udf(detectDairy, IntegerType())
udf_detectSeafood = udf(lambda x: detectSeafood(x, seaDetect_list), IntegerType())

#to stabilise schema with empty column
# udf_empty = udf(lambda x: None, StringType())

#create variable for time stamp
timestamp = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')


# In[10]:


import time
print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

####----Create ingredient table----####
##Create ingredient table
extracted_df = recipes_table.withColumn('rm_paren', udf_removeParen('ingredients'))                            .withColumn('ingredient_extract', udf_extractIngredient('rm_paren'))

extracted_df.show(5)
extracted_df.cache()

extracted_df.storageLevel
# extracted_df.unpersist()

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time


# In[11]:


print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

extracted_df.count()

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time


# In[13]:


#Create recipe ingredient graph to store in HDFS
print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

ingredient_extract = extracted_df.select("title", "ingredient_extract")

ingredient_list = ingredient_extract.withColumn('exploded',explode('ingredient_extract'))                                    .select(col('title').alias('Recipe'),col('exploded').alias('Ingredient'))
ingredient_list = ingredient_list.filter(ingredient_list.Ingredient != "")
#                       .withColumn("Frequency", lit(1))

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time
ingredient_list.show(5)

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time



export_filename_Ing = 'Ing_' + recipe_src + '_' + (time.strftime('%Y%m%d-%H%M%S')) + '.csv'

time.strftime('%Y%m%d-%H%M%S') #Track processing time

ingredient_list_pandas = ingredient_list.toPandas()

ingredient_list_pandas.to_csv(export_filename_Ing)


####----Upload file into HDFS----####
import os 
from subprocess import PIPE, Popen

##Create path to HDFS
hdfs_path = os.path.join(os.sep, 'user', 'centos', '/02_store/' + export_filename_Ing)

##Put files into HDFS
put_file = Popen(["hdfs", "dfs", "-put", "-f", export_filename_Ing, hdfs_path], stdin = PIPE, bufsize=-1)
put_file.communicate()

print('\nUpload completed and file stored in hdfs://localhost:9000' + hdfs_path)


# In[14]:


####----User Defined Function - Feature Engineering----####
print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

##Labels: Vegetarian, Lactose, Nut, Seafood
labelled_df = extracted_df.withColumn("vegetarian_label", udf_detectVege("ingredient_extract"))                           .withColumn("nut_label", udf_detectNut("ingredient_extract"))                           .withColumn("lactose", udf_detectDairy("ingredient_extract"))                           .withColumn("seafood", udf_detectSeafood("ingredient_extract"))                           .withColumn('extract_count', udf_countList('ingredient_extract'))
labelled_df = labelled_df.withColumn('timestamp', unix_timestamp(lit(timestamp),'yyyy-MM-dd HH:mm:ss').cast("timestamp"))

# labelled_df = labelled_df.withColumn("rating_stars", udf_empty("ingredient_extract")) \
#                          .withColumn("review_count", udf_empty("ingredient_extract"))

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

labelled_df.show(5)

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time


# In[15]:


columns_to_drop = ['rm_paren', 'ingredient_extract']
labelled_df = labelled_df.drop(*columns_to_drop)
labelled_df.printSchema()


# In[ ]:





# In[17]:


####----Export Spark Data Frame----####
export_Recipe = 'Recipe_' + recipe_src + '_' + (time.strftime('%Y%m%d-%H%M%S')) + '.csv'

#let's make our toPandas() faster
print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

labelled_pandas = labelled_df.toPandas()

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time

labelled_pandas.to_csv(export_Recipe)

print(time.strftime('%Y%m%d-%H%M%S')) #Track processing time


# graph_pandas = ingredient_graph.toPandas()
# graph_pandas.to_csv("ingredient_graph.csv")

#write json
# labelled_json = labelled_df.toJSON()
# json_output = labelled_json.collect()

# with open("label_table.json", "w") as file:
#     for j in json_output:
#         json.dump(j, file)


####----Upload file into HDFS----####
import os 
from subprocess import PIPE, Popen

##Create path to HDFS
hdfs_path = os.path.join(os.sep, 'user', 'centos', '/02_store/' + export_Recipe)

##Put files into HDFS
put_file = Popen(["hdfs", "dfs", "-put", "-f", export_Recipe, hdfs_path], stdin = PIPE, bufsize=-1)
put_file.communicate()

print('\nUpload completed and file stored in hdfs://localhost:9000' + hdfs_path)

print(json_output[2])
with open("all_label.json", "w") as file:
    json.dump(j, file)
# In[19]:


#Create recipe-recipe graph
time.strftime('%Y%m%d-%H%M%S') #Track processing time

recipeGraph_json = ingredient_extract.toJSON()
recipeGraph_json = recipeGraph_json.collect()

recipeGraph_list = []
for js in recipeGraph_json:
    js_output = json.loads(js)
    recipeGraph_list.append(js_output)

recipeA = []
recipeB = []
commonIng = []
for first in range(len(recipeGraph_list)):
    counter = 1
    recipe_a = recipeGraph_list[first]["title"]
    ing_a = recipeGraph_list[first]["ingredient_extract"]
    for second in range(counter, len(recipeGraph_list)): 
        recipe_b = recipeGraph_list[second]["title"]
        ing_b = recipeGraph_list[second]["ingredient_extract"]
        common = len(set(ing_a).intersection(ing_b))
        recipeA.append(recipe_a)
        recipeB.append(recipe_b)
        commonIng.append(common)
    counter = counter + 1

recipeGraph_dict = {"recipeA":recipeA, "recipeB":recipeB, "common_ing":commonIng}
sharedRecipe_pandas = pd.DataFrame(recipeGraph_dict)
export_Graph = 'Graph_' + recipe_src + '_' + (time.strftime('%Y%m%d-%H%M%S')) + '.csv'

time.strftime('%Y%m%d-%H%M%S') #Track processing time

sharedRecipe_pandas.to_csv(export_Graph)


####----Upload file into HDFS----####
import os 
from subprocess import PIPE, Popen

##Create path to HDFS
hdfs_path = os.path.join(os.sep, 'user', 'centos', '/02_store/' + export_Graph)

##Put files into HDFS
put_file = Popen(["hdfs", "dfs", "-put", "-f", export_Graph, hdfs_path], stdin = PIPE, bufsize=-1)
put_file.communicate()

print('\nUpload completed and file stored in hdfs://localhost:9000' + hdfs_path)

#Similarity matrix (Too expensive)
# tokenizer = Tokenizer(inputCol="Ingredient", outputCol="Component")
# componentData = tokenizer.transform(cleanIngredient_table)
# hashingTF = HashingTF(inputCol="Component", outputCol="Ing_Component")
# featurizedData = hashingTF.transform(componentData)
# idf = IDF(inputCol="Ing_Component", outputCol="Ing_Feature")
# idfModel = idf.fit(featurizedData)
# rescaledData = idfModel.transform(featurizedData)

# normalizer = Normalizer(inputCol="Ing_Feature", outputCol="norm")
# similarity = normalizer.transform(rescaledData)
# sim_matrix = similarity.select("ID", "title", "norm")
# sim_matrix.show()
# sim_test = sim_matrix.rdd.map(lambda row:IndexedRow(row.ID, row.norm.toArray()))
# type(sim_test)

# mat = IndexedRowMatrix(similarity.select("title", "norm")\
#                      .rdd.map(lambda row: IndexedRow(row.title, row.norm.toArray()))).toBlockMatrix()
# dot = mat.multiply(mat.transpose())
# dot.toLocalMatrix().toArray()

# dot_udf = udf(lambda x,y: float(x.dot(y)), DoubleType())
# data.alias("i").join(data.alias("j"), col("i.title") < col("j.title"))\
#     .select(
#         col("i.title").alias("i"), 
#         col("j.title").alias("j"), 
#         dot_udf("i.norm", "j.norm").alias("dot"))\
#     .sort("i", "j")\
#     .show()

# sim_mat = IndexedRowMatrix(sim_test).toBlockMatrix()
# dot = sim_mat.multiply(sim_mat.transpose())
# dot.toLocalMatrix().toArray()
# dot_udf = udf(lambda x,y: float(x.dot(y)), DoubleType())

# similarity.alias("i").join(similarity.alias("j"), col("i.ID") < col("j.ID"))\
#     .select(
#         col("i.ID").alias("i"), 
#         col("j.ID").alias("j"), 
#         dot_udf("i.ID", "j.ID").alias("cosine"))\
#     .sort("i", "j")\
#     .show()

# cv = CountVectorizer(inputCol="Ing_Str", outputCol="Ing_Feature", vocabSize=3, minDF=2.0)
# model = cv.fit(cleanIngredient_table)
# result = model.transform(cleanIngredient_table)
# result.show(5)
# test = result.toPandas()
# test.to_csv("test.csv")
# In[ ]:





# In[ ]:




