###### Retrieve ingredients from this
import pandas as pd
import nltk
import matplotlib
import re

#nltk.download()
#add your path for dictionary
nltk.data.path.append("C:\\Users\\nelso\\Documents\\Data Science\\Python")

#### Get lemma from one corpus using only NLTK.
def textcleaner(mytext, stopwords):
    #create my stopword list as set.
    stop_words = set(nltk.corpus.stopwords.words('english'))
    
    #add words if you want to.
    stop_words = stop_words.union(stopwords)
    stop_words.add("abcdefg")

    #tokenise text using regular expressions
    from nltk.tokenize import RegexpTokenizer
    from nltk.tokenize import word_tokenize
    
    #This tokenizer strips punctuation using regexptokenizer
#    mytokenizer = RegexpTokenizer('\w+') 
#    mytext = mytext.lower()
#    mytext_nopunc_tokens = mytokenizer.tokenize(mytext)
    
    #This tokenizer retains punctuation
    mytext = mytext.lower()
    #This tokenizer retains brackets
    mytext=re.sub(u"\\(.*?\\)", "", mytext)
    mytext_nopunc_tokens = word_tokenize(mytext)

    #lemmatize
    from nltk.corpus import wordnet
    def get_wordnet_pos(word):
        """Map POS tag to first character lemmatize() accepts"""
        #returns n as default.
        tag = nltk.pos_tag([word])[0][1][0].upper()
        tag_dict = {"J": wordnet.ADJ,
                    "N": wordnet.NOUN,
                    "V": wordnet.VERB,
                    "R": wordnet.ADV}
    
        return tag_dict.get(tag, wordnet.NOUN)
    
    # Lemmatize the tokenized sentence.
    lemmatizer = nltk.stem.WordNetLemmatizer()
    stems = [lemmatizer.lemmatize(w, get_wordnet_pos(w)) for w in mytext_nopunc_tokens]
    
    #remove stopwords
    stems = [w for w in stems if not w in stop_words]
    
    #print(mytext_nopunc_tokens) 
    return stems
#### End NLTK Lemmas
    
def ingredients_list(mylist, stopwords):
    a = []
    for item in mylist:
        b = textcleaner(item, stopwords)
        if ',' in b:
            comma_index = b.index(',')
            if comma_index <3:
                dummy = 0
            else:
                dummy = comma_index-3
            to_append = b[dummy:comma_index]
            a.append([i for i in to_append if not re.search('[0-9]',i)])
        else:
            to_append = b[-3:]
            a.append([i for i in to_append if not re.search('[0-9]',i)])
    return a

def textcleaner2(mytext, includewords):
    #only dig out specific words.
    #tokenise text using regular expressions
    from nltk.tokenize import RegexpTokenizer
    from nltk.tokenize import word_tokenize
    
    #This tokenizer strips punctuation using regexptokenizer
#    mytokenizer = RegexpTokenizer('\w+') 
#    mytext = mytext.lower()
#    mytext_nopunc_tokens = mytokenizer.tokenize(mytext)
    
     #This tokenizer retains brackets
    mytext=re.sub(u"\\(.*?\\)", "", mytext)
     #This tokenizer retains punctuation
    mytext = mytext.lower()
    mytext_nopunc_tokens = word_tokenize(mytext)

    #lemmatize
    from nltk.corpus import wordnet
    def get_wordnet_pos(word):
        """Map POS tag to first character lemmatize() accepts"""
        #returns n as default.
        tag = nltk.pos_tag([word])[0][1][0].upper()
        tag_dict = {"J": wordnet.ADJ,
                    "N": wordnet.NOUN,
                    "V": wordnet.VERB,
                    "R": wordnet.ADV}
    
        return tag_dict.get(tag, wordnet.NOUN)
    
    # Lemmatize the tokenized sentence.
    lemmatizer = nltk.stem.WordNetLemmatizer()
    stems = [lemmatizer.lemmatize(w, get_wordnet_pos(w)) for w in mytext_nopunc_tokens]
    
    #include stopwords
    stems = [w for w in stems if w in includewords]

    return stems
#### End NLTK Lemmas
    
def methods_list(mylist, includewords):
    a = []
    for item in mylist:
        a.append(textcleaner2(item, includewords))
    return a