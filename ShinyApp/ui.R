#Richard Shanahan  
#https://github.com/rjshanahan  
#rjshanahan@gmail.com
#5 December 2015

## load packages
library(shiny)
library(ggplot2)
library(devtools)
library(data.table)
library(DT)
library(dplyr)
#library(shinydashboard)



#GitHub URL
rjs <- as.character(tags$html(
  tags$body(
    a("my GitHub repository", href="https://github.com/rjshanahan/Vaccination-Social-Media/wiki", target="_blank"))))

selections_fill <- c('polarity',             
                     'subjectivity')

selections_x <- c('user', 
                  'hashtag')

selections_y <- c('like_fave',
                  'share_rtwt',
                  'posts')

selections_yD <- c('like_fave',
                   'share_rtwt')

selections_source <- c('twitter',
                       'facebook')

selections_allN <- c("yes - show me all records",
                     "no - i'll just use the slider")

############################################################
## shiny user interface function
############################################################

ui <- fluidPage(
  titlePanel('Vaccination Debate Social Media Data Interactive Visualisations', windowTitle='Vax Visualisation'),
  fluidRow(
    sidebarPanel(
      #mainPanel(img(src="RNMlogo.png", height = 77, width = 300)),
      radioButtons(inputId="mySource", "Select your social media source", selections_source, selected = selections_source[1], inline = T),
      sliderInput(inputId="topN","How many records do you want to view?",value=50,min=10,max=100,step=1),
      radioButtons(inputId="myFill", "Shade the distribution visualisations across by post/tweet 'polarity' or 'subjectivity'", selections_fill, selected = selections_fill[1], inline = T),
      radioButtons(inputId="myYdist", "... then select the popularity metric", selections_yD, selected = selections_yD[1], inline = T),
      conditionalPanel(
        condition = "input.mySource != 'facebook'",
        radioButtons(inputId="myX", "For the visualisations below select your x-axis", selections_x, selected = selections_x[1], inline = T)),
      conditionalPanel(
        condition = "input.mySource == 'facebook'",
        radioButtons(inputId="myX", "For the visualisations below select your x-axis", selections_x[1], selected = selections_x[1], inline = T)),
      radioButtons(inputId="myY", "... then select your y-axis", selections_y, selected = selections_y[1], inline = T),
      
      helpText("For definitions, background information on this dataset and related code please refer to ",rjs)
      , width=6),
    column(width=6,
           tabsetPanel(type="tabs",
                       tabPanel("scatter", icon = icon("spinner"), plotOutput("scatter_man")),
                       tabPanel("density", icon = icon("area-chart"), plotOutput("density_man")),
                       tabPanel("contour", icon = icon("line-chart"), plotOutput("contour_man")),
                       tabPanel("histogram", icon = icon("bar-chart-o"), plotOutput("histo_man")),
                       tabPanel("view all records?", 
                                icon = icon("question-circle"),
                                br(),
                                valueBoxOutput("numberRecords"),
                                br(),
                                br(),
                                radioButtons(inputId="allN", "Would you like to see the distribution of all records?", selections_allN, selected = selections_allN[2], inline = T),
                                br(),
                                br(),
                                helpText("This will display all records in the distribution visualisation tabs. Note: only entries that are 'popular' are displayed. If a post/tweet doesn't have any likes/faves or shares/retweets it will be excluded."))
           ))
  ),
  
  fluidRow(
    column(width=6, plotOutput("sentiment_plot")),
    column(width=6, plotOutput("subjectivity_plot"))),
  fluidRow(
    column(width=6,
           div(DT::dataTableOutput("sent_top"),
               style = "font-size:75%")),
    column(width=6,
           div(DT::dataTableOutput("subj_top"),
               style = "font-size:75%"))
  )
)
