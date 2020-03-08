#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RCurl)
library(plotly)
library(tidyverse)

rsconnect::setAccountInfo(name='samriti', token='AD5A072D471F1F0BC314E33575B7B039', secret='4YPVMrSYo0BJHykYb8yXNcm+oXnhaE7A5ikj6G5T')


data_url <- getURL('https://raw.githubusercontent.com/charleyferrari/CUNY_DATA608/master/lecture3/data/cleaned-cdc-mortality-1999-2010-2.csv')
mortality_data <- read_csv(data_url)

mental_data_2010 <- filter(mortality_data, Year == 2010 & ICD.Chapter == 'Mental and behavioural disorders')
mental_data_2010 <-  mental_data_2010 %>% arrange(Crude.Rate)

p <- plot_ly(x = mental_data_2010$Crude.Rate, y = mental_data_2010$State, type = 'bar', text = mental_data_2010$Crude.Rate, textposition = 'auto',  color = I("grey"), orientation = 'h')

# Define UI for application that draws a histogram
ui <- fluidPage(    
        plotlyOutput("plot"),
        verbatimTextOutput("event")
    )


# Define server logic required to draw a histogram
server <- function(input, output) {
    output$plot <- renderPlotly({
        p #used the above plotly object instead of redoing here
    })
    output$event <- renderPrint({
        d <- event_data("plotly_hover")
        if (is.null(d)) "Hover on a bar to see State Data!" else d
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

