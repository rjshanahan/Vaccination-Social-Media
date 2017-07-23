
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import requests
import codecs
import csv
import pprint as pp
import re
from collections import OrderedDict


#fora of interest
# page1 = "http://forums.whirlpool.net.au/archive/2642710"
# page2 = "http://forums.whirlpool.net.au/archive/2603328"

# Home > Real estate: http://forums.whirlpool.net.au/forum/138?g=226
# Finance > Loans: http://forums.whirlpool.net.au/forum/150?g=368
# Finance thread: http://forums.whirlpool.net.au/forum/150 (for finance savvy blog ideas)
# Lifestyle > Lifestyle: http://forums.whirlpool.net.au/forum/71?g=208

# pages = [page1, page2]
pages = ["http://forums.whirlpool.net.au/archive/2642710",
        "http://forums.whirlpool.net.au/archive/2603328"
        'http://forums.whirlpool.net.au/archive/2200448',
        'http://forums.whirlpool.net.au/archive/2605632',
        'http://forums.whirlpool.net.au/archive/2389965',
        'http://forums.whirlpool.net.au/archive/2635472',
        'http://forums.whirlpool.net.au/archive/2356207',
        'http://forums.whirlpool.net.au/archive/2626820']


def clean_str(string):
    """
    text cleaning
    """
    string = re.sub(r"[^A-Za-z0-9(),!?\'\`]", " ", string)
    string = re.sub(r"\'s", " \'s", string)
    string = re.sub(r"\'ve", " \'ve", string)
    string = re.sub(r"n\'t", " n\'t", string)
    string = re.sub(r"\'re", " \'re", string)
    string = re.sub(r"\'d", " \'d", string)
    string = re.sub(r"\'ll", " \'ll", string)
    string = re.sub(r",", " , ", string)
    string = re.sub(r"!", " ! ", string)
    string = re.sub(r"\(", " \( ", string)
    string = re.sub(r"\)", " \) ", string)
    string = re.sub(r"\?", " \? ", string)
    string = re.sub(r"\s{2,}", " ", string)
    string = re.sub(r"[(=\-\+/&<>;|\'\?%#$@\,\._0-9)]", '', string)
    string = re.sub(r"[']", '', string)
    return string.strip().lower()


#function to call web page
def make_request(data):

    r = requests.post(data)

    return r.text



#function to parse html content from web, extract and clean desired elements
def blogxtract(page):
    

    soup = BeautifulSoup(make_request(page), "html.parser")
    
    blog_list = []
    
    problemchars = re.compile(r'[\[=\+/&<>;:!\\|*^\'"\?%#$@)(_\,\.\t\r\n0-9-—\]]')
    prochar = '[(=\-\+/&<>;|\'"\?%#$@\,\._)]'
    replacewords = ['www','https','http',' com ', ' au ']

    #parse HTML and build dict of desired elements
    for i in soup.find_all( 'div', {'class': 'replytext bodytext'}):
        
        text_list_final = []
        
        text_list_final.append(str(i.get_text()).lower().replace('\n',' ').replace("'", "").strip())

        #if i is not None or i.p is not None or i.div is not None:
        if i.get("data-uname") != None:

            blog_dict = {
                "header": "whirlpool forum" + url[-7:],
                "url": url,
                "user": i.get("data-uname").lower().encode('ascii', 'ignore'),
                "date": i.parent.find('div', {"class":"date"}).get_text().strip().lower(),
                #"blog_text": i.get_text().lower().encode('ascii', 'ignore').replace('\n',' ').replace("'", "").strip()
                "blog_text": ' '.join(list(OrderedDict.fromkeys(text_list_final)))

                }
             
            #cleanse text for problem characters
#             for ch in prochar:
#                 if ch in blog_dict['blog_text']:
#                     blog_dict['blog_text'] = problemchars.sub(' ', blog_dict['blog_text']).strip()
            for t in blog_dict['blog_text']:      
                blog_dict['blog_text'] = clean_str(blog_dict['blog_text'])
            #cleanse text for unncesssary date text
            for dt in blog_dict['date']:
                blog_dict['date'] = blog_dict['date'].replace('posted ','').split(',')[0]
            #cleanse text for unnecessary words
            for wd in replacewords:
                if wd in blog_dict['blog_text']:
                    blog_dict['blog_text'] = blog_dict['blog_text'].replace(wd,'')
                
                
            blog_list.append(blog_dict)
            
        else:
            pass
     
    #call csv writer function and output file
    writer_csv(blog_list, url)
    
    return pp.pprint(blog_list[0:2])

    
#function to write CSV - uses part of URL as file name    
def writer_csv(blog_list, url):
    
    file_out = "whirlpool_{page}.csv".format(page = url[-7:])
    
    with open(file_out, 'w') as csvfile:
        
        writer = csv.writer(csvfile, lineterminator='\n', delimiter=',', quotechar='"')
        
        writer.writerow(["header", "url", "user", "date", "blog_text"])
    
        for i in blog_list:
            newrow = i['header'], i['url'], i['user'], i['date'], i['blog_text']

            writer.writerow(newrow)
                         
                        

#loop through each URL and process
for url in pages:
    blogxtract(url)
