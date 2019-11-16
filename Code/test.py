import re

def find_letters(x):
    first_cap = re.search('[a-z]',x).group(0)
    return first_cap

