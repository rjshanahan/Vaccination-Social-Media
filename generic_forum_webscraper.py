#!/usr/bin/env python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib2
import requests
import codecs
import csv
import pprint as pp
import re
from collections import OrderedDict


url_standard = 'http://nocompulsoryvaccination.com'    
url_next_page = '/page/'


#web request function
def make_request_get(data):

    r = requests.get(data)

    return r.text


#function to build URL list for each blog entry and page
def url_extract(url_standard):
    
    url_list = [url_standard]    
    
    #subsequent blog pages
    warning = 'Apologies, but the page you requested could not be found. Perhaps searching will help.'
    n = 1
    
    while (BeautifulSoup(make_request_get(url_standard+url_next_page+str(n)), "html.parser").p.text == warning) is not True:   
        
        url_list.append(url_standard+url_next_page+str(n))
                             
        n += 1
    
    return blogxtract(url_list)



#build dictionary of desired values
def blogxtract(url_list):
        
    problemchars = re.compile(r'[\[=\+/&<>;:!\\|*^\'"\?%#$@)(_\,\.\t\r\n0-9-—\]]')
    prochar = '[(=\-\+\:/&<>;|\'"\?%#$@\,\._)]'
    
    blog_list = []
    
    for u in url_list:

        soup = BeautifulSoup(make_request_get(u), "html.parser")

        for i in soup.find_all('div', {'id': re.compile("post-")}):
    
            text_list = []
            text_list_final = []
        
            #define key:values for dictionary    
            header = (i.h2.get_text().encode('ascii', 'ignore').strip().lower().translate(None, ''.join(prochar)) if i.h2 is not None else "missing_header")
            date = (i.find('span' , {'class': 'entry-date'}).get_text().encode('ascii', 'ignore').strip().lower().translate(None, ''.join(prochar)) if i.find('span' , {'class': 'entry-date'}) is not None else "missing_date")
            user = (i.strong.text.encode('ascii', 'ignore').strip().lower().translate(None, ''.join(prochar)) if i.strong is not None else "nocompulsoryvaccination")
    
            #if + loop for blog entries with different CSS values
        
            for j in i.find_all('p'):
                text_list.append(j.get_text().lower().replace('\n',' ').replace("'", "").encode('ascii', 'ignore').strip())
        
            
                
            #replace bad characters in blog text
            for ch in prochar:
                for l in text_list:
                    if ch in l:
                        l = problemchars.sub(' ', l).strip()
                        text_list_final.append(l)
            
            #build dictionary
            blog_dict = {
            "header": header,
            "url": u,
            "user": user,
            "date": date,
            #"blog_text": ' '.join(text_list_final)
            "blog_text": ' '.join(list(OrderedDict.fromkeys(text_list_final)))

                }
        
            blog_list.append(blog_dict)
        
     
    #call csv writer function and output file
    writer_csv_3(blog_list)
    
    return pp.pprint(blog_list[0:2])



#function to write CSV
def writer_csv_3(blog_list):
    
    file_out = "nocompulsoryvax_blogs.csv"
    
    with open(file_out, 'w') as csvfile:

        writer = csv.writer(csvfile, lineterminator='\n', delimiter=',', quotechar='"')
    
        for i in blog_list:
            newrow = i['header'], i['url'], i['user'], i['date'], '', i['blog_text']
            writer.writerow(newrow)                     
    
    
#tip the domino    
url_extract(url_standard)

