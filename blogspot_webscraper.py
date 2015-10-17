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

#BlogID = '4403374015204970152'           #this is the unique ID required for all Google Blogger/Blogspot site 
                                          #this is found in (<meta content="4403374015204970152" itemprop="blogId">)
                                          #under ('div', {'class': "post hentry"})
        
#note: Google Blogger/BlogSpot also has an API: https://developers.google.com/apis-explorer

url_standard = 'http://momswhovax.blogspot.com.au/'


#web request function
def make_request_get(data):

    r = requests.get(data)

    return r.text


#extract next page URL - blogspot uses dynamic search terms in the 'older blogs' link
def url_extract_single(url):
    
    #global url_next
    url_next = ""

    global soup
    soup = BeautifulSoup(make_request_get(url), "html.parser")
    
    for i in soup.find_all('span', {'id':'blog-pager-older-link'}):

        if len(i.a["href"]) > 1:
            url_next = i.a["href"].encode('ascii', 'ignore')
        else:
            pass

    return url_next
    

#function to build URL list for each blog entry and page
def url_extract(url_standard):
    
    #global url_list
    
    #initial list build
    url_list = [url_standard] 
    url_list.append(url_extract_single(url_standard))
            
    #while ((soup.find_all('span', {'id':'blog-pager-older-link'})[0].a['href']).encode('ascii', 'ignore') != "") is True:
    while True:   
        if len(url_list[-1]) > 0:
            new_url = url_extract_single(url_list[-1])
            url_list.append(new_url)
        else:
            break
               
    #remove last list item - empty
    return blogxtract(url_list[0:(len(url_list)-1)])

#url_extract(url_standard)


#function to parse html content from web, extract and clean desired elements
def blogxtract(url_list):
    
    problemchars = re.compile(r'[\[=\+/&<>;:!\\|*^\'"\?%#$@)(_\,\.\t\r\n0-9-—\]]')
    prochar = '[(=\-\+\:/&<>;|\'"\?%#$@\,\._)]'
    
    blog_list = []
    
    for u in url_list:
        global soup
        soup = BeautifulSoup(make_request_get(u), "html.parser")

        for i in soup.find_all('div', {'class': "post hentry"}):
    
            text_list = []
            text_list_final = []
        
            #define key:values for dictionary    
            header = (i.h3.get_text().encode('ascii', 'ignore').strip().lower().translate(None, ''.join(prochar)) if i.h3 is not None else u)
            date = (i.parent.parent.parent.find('h2' , {'class': 'date-header'}).get_text().encode('ascii', 'ignore').strip().lower().translate(None, ''.join(prochar)) if i.parent.parent.parent.find('h2' , {'class': 'date-header'}) is not None else "missing_date")    
            url = (i.h3.a['href'].encode('ascii', 'ignore').strip() if i.h3 is not None else u)
            
            for j in i.find_all('span'):
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
            "url": url,
            "user": "momswhovax",
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
    
    file_out = "momswhovax2_blogs.csv"
    
    with open(file_out, 'w') as csvfile:

        writer = csv.writer(csvfile, lineterminator='\n', delimiter=',', quotechar='"')
    
        for i in blog_list:
            newrow = i['header'], i['url'], i['user'], i['date'], '' ,i['blog_text']

            writer.writerow(newrow)                     
    
    
#tip the domino    
url_extract(url_standard)    
    
