from selenium.webdriver import Firefox
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from time import sleep

path = 'C:/Users/nelso/Documents/Data Science/Python/Scripts/Firefox Scraper/geckodriver.exe'
driver = Firefox(executable_path=path)
#driver.get('https://www.enchantedlearning.com/wordlist/measurement.shtml')
driver.get('https://www.enchantedlearning.com/wordlist/cooking.shtml')
#driver.get('https://www.d.umn.edu/~alphanu/cookery/glossary_cooking.html')
sleep(5) #this lets the website load first

mywords = []
webitem = driver.find_elements_by_class_name('wordlist-item')
#webitem = driver.find_elements_by_tag_name('b')

for item in webitem:
    mywords.append(item.text)

driver.quit()

print(mywords)

#with open('cookingmethods2.txt', 'w') as filehandle:
#    for listitem in mywords:
#        filehandle.write('%s\n' % listitem)
