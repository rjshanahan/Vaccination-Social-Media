## Vaccination-Social-Media
#### Supporting code for social media vaccination topic analysis and topic-based predictive models
  
This repository contains the 'variation on a theme' webscraper code for social media text analysis. The analyses identified text clusters and text topics for various social media vaccination-related posts from 2015.

Included in this repository is code for the following webscrapers:
- Facebook page and group: *<a href="https://github.com/rjshanahan/facebook_m_scraper" target="_blank">webscraper</a>* 
- Twitter : *<a href="https://github.com/rjshanahan/twitter_scraper" target="_blank">webscraper</a>* 
- *<a href="https://www.blogger.com" target="_blank">Blogspot/Google Blogger</a>* webscraper
- *<a href="http://forums.whirlpool.net.au/" target="_blank">Whirlpool</a>* webscraper
- Other forum type webscraper
- Also included is R code for additional pre-processing, feature selection and visualisations.  
  
Refer to the table below for a full list of sites scraped.  
  
#####**Abstract from Paper**  
*The ‘pro’ and ‘anti’ vaccination debate is highly charged with social media often the battleground. The debate via various social media platforms ranges from conversation to outright campaigning. Social media platforms such as Twitter, Facebook and blogs enable participants from all backgrounds and experiences to express ideas, persuade and dissuade, which are often undertaken using highly emotive content. Popularity metrics such as Facebook ‘likes’ and Twitter ‘retweets’ can be used to represent the content’s effectiveness. The scale of these popularity indicators is dependent on several factors, including the number of followers, presentation and the content theme. Insight into the themes associated with popular content can be identified through the analysis of social media using data mining techniques, in particular text analytics. This paper looks at the methodology and analyses used to understand if ‘a 2015 vaccination post’s popularity can be predicted by its theme alone’.*

The Twitter and Facebook programs use *<a href="http://www.seleniumhq.org/" target="_blank">Selenium</a>* (and ChromeDriver) to automate user behaviour within a browser session to load a specific Twitter page (no login) or login to Facebook mobile site, expand collapsible sections for 2015 or load data from dynamic scrolling. Once the pages are rendered the HTML is extracted and sieved through *<a href="http://www.crummy.com/software/BeautifulSoup/bs4/doc/" target="_blank">BeautifulSoup</a>*. Note: it will continue scraping until 1) end of feed is reached, 2) manual interrupt by killing the connection. The traditional forum sites use the Python 'requests' module and *<a href="http://www.crummy.com/software/BeautifulSoup/bs4/doc/" target="_blank">BeautifulSoup</a>*.
  
These programs will extract the following and output to a CSV file with punctuation and other non-text characters removed:
- full tweet text from each Twitter page
- date
- header
- url
- user name 
- popularity metrics (string containing retweets/favourites)
- like_fave: integer value for number of times 'liked' or 'favorited'
- share_rtwt: integer value for number of times 'shared' or 'retweeted'



|Datasource_URL										| Stance| Popularity Metrics  |
|:---------------------------------------------------|:-------|:---------------------|
|https://facebook.com/stopavn   							| Pro	| Likes & Shares	  |
|https://facebook.com/vaccinetruth 							| Anti	| Likes & Shares	  |
|https://facebook.com/avn.living.wisdom						| Anti	| Likes & Shares	  |
|https://facebook.com/RtAVM									| Pro	| Likes & Shares	  |
|https://facebook.com/thetruthaboutvaccines					| Anti	| Likes & Shares	  |
|https://facebook.com/vaccinationinformationnetwork			| Anti	| Likes & Shares	  |
|https://facebook.com/insidevaccines						| Anti	| Likes & Shares	  |
|https://facebook.com/national.vaccine.information.center	| Anti	| Likes & Shares	  |
|https://facebook.com/vaccinationdecisions					| Anti	| Likes & Shares	  |
|https://facebook.com/vaccinationcouncil					| Anti	| Likes & Shares	  |
|https://facebook.com/groups/VaccinationImmunizationCommonS	| Anti	| Likes & Shares	  |
|https://facebook.com/groups/VaccineIA						| Anti	| Likes & Shares	  |
|https://facebook.com/groups/710858595610414				| Anti	| Likes & Shares	  |
|https://facebook.com/groups/wrongvaccines					| Anti	| Likes & Shares	  |
|https://twitter.com/hashtag/antivaccination				| Anti	| Favorite & Retweet  |
|https://twitter.com/hashtag/cdcfraud						| Anti	| Favorite & Retweet  |
|https://twitter.com/hashtag/vaccineswork					| Both	| Favorite & Retweet  |
|https://twitter.com/hashtag/sb277/					| Both	| Favorite & Retweet  |
|http://forums.whirlpool.net.au/archive/2393025		| Both	| None  			  |
|http://nocompulsoryvaccination.com						| Anti	| None  			  |
|http://momswhovax.blogspot.com.au							| Pro	| None  			  |


![Twitter](https://g.twimg.com/Twitter_logo_blue.png)

![facebook.mobile](https://www.facebook.com/images/fb_icon_325x325.png)

![Selenium Browser Automation](http://www.seleniumhq.org/images/big-logo.png)


