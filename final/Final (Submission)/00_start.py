#!/usr/bin/env python3

import os
import subprocess
import sys

#Start processes
#Start Hadoop
subprocess.call(["start-all.sh"])

#Start Neo4j
subprocess.call(["sudo", "service", "neo4j", "start"])
subprocess.Popen("centos" , shell=True,stdout=subprocess.PIPE)
subprocess.call(["sudo", "neo4j", "start"])
subprocess.Popen("centos" , shell=True,stdout=subprocess.PIPE)

'''
#Start Jupyter Notebook
subprocess.call(["jupyter", "notebook"])

#Start Drill
#subprocess.call(["drill-embedded"])
#subprocess.call(["drillbit.sh", "start"])
'''

input_all = input("\nDo you want to start all processes (webscrapping, cleaning, database creation)? Y or N\
\nInput: ").upper()

if (input_all == 'Y'):
	print ("You entered " + input_all)
	subprocess.call(["python", "/home/centos/BigData/01_source/01_source.py"])
	subprocess.call(["python", "/home/centos/BigData/02_cleaning/02_cleaning.py"])
	subprocess.call(["python", "/home/centos/BigData/03_database/03_drill.py"])

