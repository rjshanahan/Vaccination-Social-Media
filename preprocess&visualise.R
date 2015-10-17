#Richard Shanahan  
#https://github.com/rjshanahan  
#17 August 2015

###### INFS 5101 Social Media Data Analytics: Web Scraper Pre-processing

# load required packages
library(Hmisc)
library(psych)
library(ggplot2)
library(reshape2)
library(dplyr)
library(devtools)

# source custom code for plots from GitHub Gist: https://gist.github.com/rjshanahan
source_gist("e47c35277a36dca7189a")       #boxplot
source_gist("7eed7f043c987f884748")       #facet wrap boxplot
source_gist("40f46687d48030d40704")       #cluster plot


###### 1. read in file and inspect data ###### 

vaccination <- read.csv('vaccination_consolidated.csv',
                        header=T,
                        sep=",",
                        quote='"',
                        colClasses=c(
                          'character',   # header
                          'character',   # url
                          'character',   # user
                          'character',   # date
                          'character',   # popularity
                          'character',   # blog_text
                          'numeric',     # like_fave
                          'numeric'      # share_rtwt
                        ),
                        strip.white=T,
                        stringsAsFactors=F,
                        fill=T)

#inspect
str(vaccination)
describe(vaccination)

#check for duplicate records based
nrow(unique(vaccination))
nrow(vaccination)

#check if there are any missing values
colSums(is.na(vaccination)) 


###### 2. recode and feature selection ###### 
# recode Likes and Favorites
vaccination$like_fav_group <- ifelse(vaccination$like_fave >= 10,
                                     "High",
                                     ifelse(vaccination$like_fave > 3 & vaccination$like_fave < 9,
                                            "Medium",
                                            ifelse(vaccination$like_fave >= 1 & vaccination$like_fave <= 3,
                                                   "Low",
                                                   "None")))

vaccination$like_fav_group[is.na(vaccination$like_fav_group)] <- "None"

# recode Shares and Retweets
vaccination$shr_rtwt_group <- ifelse(vaccination$share_rtwt >= 10,
                                     "High",
                                     ifelse(vaccination$share_rtwt > 2  & vaccination$share_rtwt < 9,
                                            "Medium",
                                            ifelse(vaccination$share_rtwt >= 1 & vaccination$share_rtwt <= 2,
                                                   "Low",
                                                   "None")))

vaccination$shr_rtwt_group[is.na(vaccination$shr_rtwt_group)] <- "None"

#like_fave ranges
mR <- median(vaccination$like_fave, na.rm = T)
madR <- mad(vaccination$like_fave, na.rm = T)
iqrR <- IQR(vaccination$like_fave, na.rm = T)


#share_retweet ranges
mR <- median(vaccination$share_rtwt, na.rm = T)
madR <- mad(vaccination$share_rtwt, na.rm = T)
iqrR <- IQR(vaccination$share_rtwt, na.rm = T)


#tag topic-only blogs
sites <- "nocompulsoryvaccination|momswhovax|whirlpool"

vaccination$shr_rtwt_group <- ifelse(grepl(sites, vaccination$url) == T, 'Exclude', vaccination$shr_rtwt_group)
table(vaccination$shr_rtwt_group)

vaccination$like_fav_group <- ifelse(grepl(sites, vaccination$url) == T, 'Exclude', vaccination$like_fav_group)
table(vaccination$like_fav_group)


#write output file
write.csv(vaccination, file = "vaccination_recode.csv", row.names = FALSE)


######additional variable for SOURCE
fb = 'facebook'
tw = 'twitter'

#additional recode - add SOURCE
vaccination$source <- ifelse(grepl(fb, vaccination$header) == T,
                             "facebook",
                             ifelse(grepl(tw, vaccination$header) == T,
                                    "twitter",
                                    "other"))

table(vaccination$source)

######additional variable for SENTIMENT


sentiment <- c('stopavn'  ='Pro',
               'vactruth'='Anti',
               'vaccinetruth'='Anti',
               'avn.living.wisdom'='Anti',
               'RtAVM'='Pro',
               'thetruthaboutvaccines'='Anti',
               'vaccinationinformationnetwork'='Anti',
               'insidevaccines'='Anti',
               'national.vaccine.information.center'='Anti',
               'vaccinationdecisions'='Anti',
               'vaccinationcouncil'='Anti',
               'VaccinationImmunizationCommonSense'='Anti',
               'VaccineIA'='Anti',
               '710858595610414'='Anti',
               'wrongvaccines'='Anti',
               'antivaccination'='Anti',
               'cdcfraud'='Anti',
               'vaccineswork'='Both',
               'sb277'='Both',
               'MeaslesTruth'='Anti',
               'http://forums.whirlpool.net.au/archive/2393025'='Both',
               'nocompulsoryvaccination.com'='Anti',
               'momswhovax.blogspot.com.au'='Pro')


#apply with indexing
vaccination$sentiment <- sapply(vaccination$header, function(x) sentiment[unlist(strsplit(x, "_"))[length(unlist(strsplit(x, "_")))]])

table(vaccination$sentiment)



###### 3. visualisations ###### 


#inspect popularity metrics - LOG TRANSFORMED
ggplot(data = vaccination, 
       aes(x=log(like_fave),
           fill=like_fav_group)) + 
  #fill=ring_group)) + 
  geom_histogram(binwidth=0.1) +
  ggtitle("Vaccination: Histogram of 'Likes' + 'Favorites' (log) and Favorites")

ggplot(data = vaccination, 
       aes(x=log(share_rtwt),
           fill=shr_rtwt_group)) + 
  #fill=ring_group)) + 
  geom_histogram(binwidth=0.1) +
  ggtitle("Vaccination: Histogram of 'Shares' + 'Retweets' (log) and Favorites")


#inspect popularity metrics - GROUPING VARIABLE
ggplot(data = vaccination, 
       aes(x=like_fav_group,
           fill=like_fav_group)) + 
  #fill=ring_group)) + 
  geom_histogram(binwidth=5) +
  ggtitle("Vaccination: Histogram of Likes and Favorites groups")

ggplot(data = vaccination, 
       aes(x=shr_rtwt_group,
           fill=shr_rtwt_group)) + 
  #fill=ring_group)) + 
  geom_histogram(binwidth=5) +
  ggtitle("Vaccination: Histogram of Shares and Retweets")

#tabulate
table(vaccination$like_fav_group)
table(vaccination$shr_rtwt_group)


#reshape
vaccination$id <- 1:nrow(vaccination)

vaccination.m <- melt(vaccination[7:11],
                      id.var="id")

source_GitHubGist_boxplot(vaccination.m, 'Boxplot for Vaccination','','')



#user based visualisations

likefave_10 <-  vaccination %>%
  group_by(user) %>%
  mutate(posts = n()) %>%
  select(user, source, like_fave, sentiment, posts) %>%
  filter(!is.na(like_fave)) %>%
  group_by(user, source, sentiment, posts) %>%
  summarise(like_fave_sum = sum(like_fave)) %>%
  ungroup() %>%
  arrange(desc(like_fave_sum)) 

head(likefave_10, 20)


shrtwt_10 <-  vaccination %>%
  group_by(user) %>%
  mutate(posts = n()) %>%
  select(user, source, share_rtwt, sentiment, posts) %>%
  filter(!is.na(share_rtwt)) %>%
  group_by(user, source, sentiment, posts) %>%
  summarise(shr_rtwt_sum = sum(share_rtwt)) %>%
  ungroup() %>%
  arrange(desc(shr_rtwt_sum))

head(shrtwt_10, 20)

likefave_10_fb <-  vaccination %>%
  group_by(user) %>%
  mutate(posts = n()) %>%
  select(user, source, like_fave, sentiment, posts) %>%
  filter(!is.na(like_fave) & source == 'facebook') %>%
  group_by(user, source, sentiment, posts) %>%
  summarise(like_fave_sum = sum(like_fave)) %>%
  ungroup() %>%
  arrange(desc(like_fave_sum))

head(likefave_10_fb, 20)


shrtwt_10_fb <-  vaccination %>%
  group_by(user) %>%
  mutate(posts = n()) %>%
  select(user, source, share_rtwt, sentiment, posts) %>%
  filter(!is.na(share_rtwt) & source == 'facebook') %>%
  group_by(user, source, sentiment, posts) %>%
  summarise(shr_rtwt_sum = sum(share_rtwt)) %>%
  ungroup() %>%
  arrange(desc(shr_rtwt_sum))

head(shrtwt_10_fb, 20)


likefave_10_tw <-  vaccination %>%
  group_by(user) %>%
  mutate(posts = n()) %>%
  select(user, source, like_fave, sentiment, posts) %>%
  filter(!is.na(like_fave) & source == 'twitter') %>%
  group_by(user, source, sentiment, posts) %>%
  summarise(like_fave_sum = sum(like_fave)) %>%
  ungroup() %>%
  arrange(desc(like_fave_sum))

head(likefave_10_tw, 20)


shrtwt_10_tw <-  vaccination %>%
  group_by(user) %>%
  mutate(posts = n()) %>%
  select(user, source, share_rtwt, sentiment, posts) %>%
  filter(!is.na(share_rtwt) & source == 'twitter') %>%
  group_by(user, source, sentiment, posts) %>%
  summarise(shr_rtwt_sum = sum(share_rtwt)) %>%
  ungroup() %>%
  arrange(desc(shr_rtwt_sum))

head(shrtwt_10_tw, 20)



#visualise posts by users
ggplot(data = arrange(head(likefave_10, 10)), 
       aes(x=substr(user, 0, 30),
           y=like_fave_sum,
           fill=sentiment,
           alpha=posts)) + 
  geom_bar(stat='identity') +
  #facet_grid(~ source) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Top 10 Most Popular Users by Likes & Favorites") +
  xlab("User Name") +
  ylab("Popularity count")


ggplot(data = arrange(head(likefave_10, 10)), 
       aes(x=substr(user, 0, 30),
           y=like_fave_sum,
           fill=source)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Top 10 Most Popular Users by Likes & Favorites") +
  xlab("User Name") +
  ylab("Popularity count")


ggplot(data = arrange(head(shrtwt_10, 10)), 
       aes(x=substr(user, 0, 30),
           y=shr_rtwt_sum,
           fill=source)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Top 10 Most Popular Users by Shares & Retweets") +
  xlab("User Name") +
  ylab("Popularity count")


ggplot(data = arrange(head(likefave_10, 10)), 
       aes(x=substr(user, 0, 30),
           y=like_fave_sum,
           fill=posts)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Top 10 Most Popular Users by Likes & Favorites - weighted by Posts") +
  xlab("User Name") +
  ylab("Popularity count")


ggplot(data = arrange(head(shrtwt_10, 10)), 
       aes(x=substr(user, 0, 30),
           y=shr_rtwt_sum,
           fill=posts)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  ggtitle("Top 10 Most Popular Users by Shares & Retweets - weighted by Posts") +
  xlab("User Name") +
  ylab("Popularity count")


#visualise posts by users + source
ggplot(data = arrange(head(likefave_10_fb, 10)), 
       aes(x=substr(user, 0, 30),
           y=like_fave_sum,
           fill=user)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="none") +
  ggtitle("Top 10 Most Popular Facebook Users by Likes") +
  xlab("User Name") +
  ylab("Popularity count")


ggplot(data = arrange(head(shrtwt_10_fb, 10)), 
       aes(x=substr(user, 0, 30),
           y=shr_rtwt_sum,
           fill=user)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="none") +
  ggtitle("Top 10 Most Popular Facebook Users by Shares") +
  xlab("User Name") +
  ylab("Popularity count")


ggplot(data = arrange(head(likefave_10_tw, 10)), 
       aes(x=substr(user, 0, 30),
           y=like_fave_sum,
           fill=user)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="none") +
  ggtitle("Top 10 Most Popular Twitter Users by Favorites") +
  xlab("User Name") +
  ylab("Popularity count") 


#shrtwt_10_tw <- shrtwt_10_tw[order(shrtwt_10_tw$user, shrtwt_10_tw$shr_rtwt_sum),]

ggplot(data=arrange(head(shrtwt_10_tw, 10)), 
       aes(x=substr(user, 0, 30),
           y=shr_rtwt_sum,
           fill=user)) + 
  geom_bar(stat='identity') +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position="none") +
  ggtitle("Top 10 Most Popular Twitter Users by Retweets") +
  xlab("User Name") +
  ylab("Popularity count")
