#Richard Shanahan  
#https://github.com/rjshanahan  
#rjshanahan@gmail.com
#5 Dec 2015

## load packages

library(shiny)
library(ggplot2)
library(devtools)
library(data.table)
library(DT)
library(dplyr)


######1. IMPORT from server ######


vaccination_sentiment_final <- read.csv('vaccination_sentiment_final.csv',
                                        header=T,
                                        sep=",",
                                        quote='"',
                                        colClasses=c(                                      
                        'character',                             #"blog_text",             
                        'character',                             #"header",             
                        'character',                             #"url",                
                        'character',                             #"user",                   
                        'character',                             #"date",
                        'character',                             #"popularity",     
                        'numeric',                               #"like_fave",                      
                        'numeric',                               #"share_rtwt",                      
                        'character',                             #"id",  
                        'character',                             #"like_fav_group",  
                        'character',                             #"shr_rtwt_group",  
                        'character',                             #"source",                        
                        'character',                             #"hashtag",           
                        'character',                             #"polarity",
                        'numeric',                               #"polarity_confidence",
                        'character',                             #"subjectivity",
                        'numeric'                                #"subjectivity_confidence",
                                        ),
                                        strip.white=T,
                                        stringsAsFactors=F,
                                        fill=T)


#set theme for 'minimal' appearance in plots
theme = theme_set(theme_minimal())
theme = theme_update(legend.position="top")


server <- function(input, output) {
  
  
  dataGraphic1 <- reactive({
    
    vaccination_sentiment_final %>%
      mutate(paste0(input$myX," = substr(",input$myX,", 0, 30)")) %>%      
      group_by_(input$myX, quote(source), quote(polarity), quote(subjectivity)) %>%
      mutate(posts = n()) %>%
      select_(input$myX, quote(source), input$myY, quote(polarity), quote(subjectivity)) %>%
      filter(!is.na(input$myY) & !is.na(polarity) & source == input$mySource) %>%
      group_by_(input$myX, quote(source), quote(polarity), quote(subjectivity), input$myY) %>%
      summarise_(paste0("sum(",input$myY,")")) %>%
      ungroup() %>%
      arrange_(paste0("desc(",input$myY,")"))
  })
  
  
  dataGraphic2 <- reactive({
    
    ###### 3. reactive dataframe for SUBJECTIVITY barcharts ######  
    
    vaccination_sentiment_final %>%
      mutate(paste0(input$myX," = substr(",input$myX,", 0, 30)")) %>%      
      group_by_(input$myX, quote(source), quote(polarity), quote(subjectivity)) %>%
      mutate(posts = n()) %>%
      select_(input$myX, quote(source), input$myY, quote(polarity), quote(subjectivity)) %>%
      filter(!is.na(input$myY) & !is.na(polarity) & source == input$mySource) %>%
      group_by_(input$myX, quote(source), quote(polarity), quote(subjectivity), input$myY) %>%
      summarise_(paste0("sum(",input$myY,")")) %>%
      ungroup() %>%
      arrange_(paste0("desc(",input$myY,")"))
    
  })
  
  
  dataGraphic3 <- reactive({
    
    ###### 4.1 reactive dataframe for TABSET panel TAB 1 ######
    
    vaccination_sentiment_final %>%
      select_(quote(like_fave), quote(share_rtwt), quote(source), quote(polarity), quote(subjectivity)) %>%
      filter(!is.na(like_fave) & !is.na(share_rtwt) & !is.na(polarity) & !is.na(subjectivity) & source == input$mySource) %>%
      arrange_(paste0("desc(", quote(like_fave),")"))
  })
  
  
  dataGraphic4 <- reactive({
    
    ###### 4.2 reactive dataframe for TABSET panel TAB 4 (histogram) ######
    
    vaccination_sentiment_final %>%
      select_(quote(like_fave), quote(share_rtwt), quote(source), quote(polarity), quote(subjectivity)) %>%
      filter(!is.na(polarity) & !is.na(subjectivity) & source == input$mySource) %>%
      arrange_(paste0("desc(", quote(like_fave),")"))
  })
  
  
  ###### 5.1 PLOT for TABSET TAB 1 - SCATTER ######
  
  output$scatter_man <- renderPlot({
    
    myDF <- dataGraphic3()
    
    myN <- ifelse(input$allN == 'yes - show me all records',
                  nrow(myDF),
                  input$topN)
    
    headmyDF <- arrange(head(myDF, n=myN))
    #headmyDF <- myDF
    
    title_main <- paste0("Scatterplot of ", input$mySource, " popularity metrics")
    title_sub <- paste0("Linear Smoothing - Top ", myN, " records by likes/faves by ", input$myFill)
    
    y_axis <- ifelse(input$myYdist == "like_fave",
                     "share_rtwt",
                     "like_fave")
    
    p <-  ggplot(data = headmyDF, 
                 aes_string(x=input$myYdist,
                            y=y_axis,
                            color=input$myFill)) +
      geom_point(position=position_jitter(width=2,height=0.5)) +
      geom_smooth(method="lm", aes_string(fill=(paste0("factor(", input$myFill, ")"))), show.legend=F) +
      ggtitle(bquote(atop(.(title_main),
                          atop(bold(.(title_sub)))))) +
      xlab(input$myYdist) +
      ylab(y_axis)
    
    print(p)
    
  })
  
  
  ###### 5.2 PLOT for TABSET TAB 2 - DENSITY ######
  
  output$density_man <- renderPlot({
    
    myDF <- dataGraphic3()
    
    myN <- ifelse(input$allN == 'yes - show me all records',
                  nrow(myDF),
                  input$topN)
    
    headmyDF <- arrange(head(myDF, n=myN)) %>%
      mutate(posts=n()) 
    #headmyDF <- myDF
    
    title_main <- paste0("Density for ", input$mySource, " showing ", input$myYdist)
    title_sub <- paste0("Kernel Density Estimation - Top ", myN, " records by ", input$myFill)
    
    p <-  ggplot(data = headmyDF, 
                 aes_string(x=input$myYdist,
                            color=input$myFill)) +
      geom_density() +
      ggtitle(bquote(atop(.(title_main),
                          atop(bold(.(title_sub)))))) +
      xlab(input$myYdist) +
      ylab("density estimate")
    
    print(p)
    
  })
  
  
  ###### 5.3 PLOT for TABSET TAB 3 - CONTOUR DENSITY ######
  
  output$contour_man <- renderPlot({
    
    myDF <- dataGraphic3()
    
    myN <- ifelse(input$allN == 'yes - show me all records',
                  nrow(myDF),
                  input$topN)
    
    headmyDF <- arrange(head(myDF, n=myN)) %>%
      mutate(posts=n()) 
    #headmyDF <- myDF
    
    title_main <- paste0("Contour Density for ", input$mySource, " popularity metrics")
    title_sub <- paste0("Contour Kernel Density Estimation - Top ", myN, " records by ", input$myFill)
    
    y_axis <- ifelse(input$myYdist == "like_fave",
                     "share_rtwt",
                     "like_fave")
    
    p <-  ggplot(data = headmyDF, 
                 aes_string(x=input$myYdist,
                            y=y_axis,
                            color=input$myFill)) +
      geom_density2d() +
      ggtitle(bquote(atop(.(title_main),
                          atop(bold(.(title_sub)))))) +
      xlab(input$myYdist) +
      ylab(y_axis)
    
    print(p)
    
  })
  
  
  ###### 5.4 PLOT for TABSET TAB 4 - HISTOGRAM ######
  
  output$histo_man <- renderPlot({
    
    myDF <- dataGraphic4()
    #headmyDF <- arrange(head(myDF, n=input$topN)) %>%
    #  mutate(posts=n()) 
    headmyDF <- myDF
    
    title_main <- paste0("Histogram for ", input$mySource, " showing log scaled ", input$myYdist)
    title_sub <- paste0("Bin width = 0.1 - all records by ", input$myFill)
    
    
    p <-  ggplot(data = headmyDF, 
                 aes_string(x=input$myYdist,
                            fill=input$myFill)) +
      geom_histogram(binwidth=0.1) +
      scale_x_log10() +
      ggtitle(bquote(atop(.(title_main),
                          atop(bold(.(title_sub)))))) +
      xlab(input$myYdist) +
      ylab("count")
    
    print(p)
    
  })
  
  
  ###### 5.5 PLOT for TABSET TAB 5 - valueBox ######
  
  output$numberRecords <- renderValueBox({
    
    myDF <- dataGraphic3()
    
    myN <- ifelse(input$allN == 'yes - show me all records',
                  nrow(myDF),
                  input$topN)
    
    valueBox(
      myN, "Records Shown", icon = icon("sort-numeric-asc"),
      color = "orange"
    )
  })
  
  
  ###### 6.1 PLOT for BARCHART - POLARITY ######
  
  output$sentiment_plot <- renderPlot({
    
    myDF <- dataGraphic1()
    headmyDF <- arrange(head(myDF, n=input$topN))
    
    p <- ggplot(data = arrange(headmyDF, desc(polarity)), 
                #ordered x axis by popularity count.
                aes_string(x=paste0("factor(", input$myX, ", levels=unique(", headmyDF,"))"),
                           y=input$myY,
                           fill=quote('polarity'))) + 
      geom_bar(stat='identity') +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            title = element_text(size = 13, colour = "black"),
            axis.title = element_text(size = 13, colour = "black")) +
      ggtitle(paste("Sentiment by", input$myX,  "- top", input$topN, "records for", input$mySource)) +
      xlab(paste(input$myX)) +
      ylab(paste("Measure:", input$myY))
    
    print(p)
    
  })
  
  
  ###### 6.2 PLOT for BARCHART - SUBJECTIVITY ######
  
  output$subjectivity_plot <- renderPlot({
    
    myDF <- dataGraphic2()
    headmyDF <- arrange(head(myDF, n=input$topN))
    
    p <- ggplot(data = arrange(headmyDF, desc(subjectivity)), 
                #ordered x axis by popularity count
                aes_string(x=paste0("factor(", input$myX, ", levels=unique(", headmyDF,"))"),
                           y=input$myY,
                           fill=quote('subjectivity'))) + 
      geom_bar(stat='identity') +
      theme(axis.text.x = element_text(angle = 45, hjust = 1),
            title = element_text(size = 13, colour = "black"),
            axis.title = element_text(size = 13, colour = "black")) +
      ggtitle(paste("Subjectivity by", input$myX,  "- top", input$topN, "records for", input$mySource)) +
      xlab(paste(input$myX)) +
      ylab(paste("Measure:", input$myY))
    
    print(p)
    
  })
  
  ###### 7.1 Output Table for POLARITY ######
  
  output$sent_top <- renderDataTable(
    arrange(head(dataGraphic2()[,1:(ncol(dataGraphic2())-1)], n=input$topN))
  )
  
  ###### 7.2 Output Table for SUBJECTIVITY ######
  
  output$subj_top <- renderDataTable(
    arrange(head(dataGraphic2()[,1:(ncol(dataGraphic2())-1)], n=input$topN))
  )
  
}
