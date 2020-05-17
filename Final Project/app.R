#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(tidyverse)
library(plotly)
library(rsconnect)
library(RCurl)

rsconnect::setAccountInfo(name='samriti', token='AD5A072D471F1F0BC314E33575B7B039', secret='4YPVMrSYo0BJHykYb8yXNcm+oXnhaE7A5ikj6G5T')

data_url <- getURL('https://raw.githubusercontent.com/samriti0202/Data608/master/Final%20Project/state_of_industry_data.csv')

restura_data <- read_csv(data_url);
#tail(restura_data$Name)

restura_data_gather <- gather(restura_data, "dates", "YoY", 3:85)

head(restura_data_gather,row=20)


#setting up the options for the drop-down menues for the user to select data
featureList1 <- restura_data_gather %>% select(Name) %>% filter(restura_data_gather$Type == "state")

#featureList2 <- restura_data_gather$Name %>% select(Name) %>% filter(restura_data_gather$Type == "state")

#featureList3 <- restura_data_gather %>% select(Name) %>% filter(restura_data_gather$Type == "city")

#fix(featureList1)
#fix(featureList2)
#fix(featureList3)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Impact of Covid-19 on Resturant business."),
   headerPanel("year-by-year Opentable reservation comparison"),
   
   # Feature selection
   sidebarPanel(
     selectInput(inputId = "featureInput1", label = "State", choices = featureList1, selected = "Alabama")
     #selectInput(inputId = "featureInput2", label = "State", choices = featureList2, selected = "Alabama")
     ),
   mainPanel(
     plotlyOutput('trendPlot')
   )
) 
   


server <- function(input, output){
  #https://plot.ly/r/shinyapp-explore-diamonds/ used as a template
  # Observes the second feature input for a change
  observeEvent(input$featureInput1,{
    # Create a convenience data.frame which can be used for charting
    dataset <-restura_data_gather[which(restura_data_gather$Name == input$featureInput1),]
    # Do a plotly contour plot to visualize the two featres with
    # the number of malignant cases as size
    # Note the use of 'source' argument
    output$trendPlot <- renderPlotly({
      plot_ly(dataset, x = ~dates, y = ~YoY, type = "scatter",  name = input$featureInput1, mode = "lines+markers", source = "subset") %>%
        layout(title = paste("Decline of Resturant over dates ",input$featureInput1),
               xaxis = list(title = 'Dates'),
               yaxis = list(title = 'Year over Year'),
               dragmode =  "select",
               plot_bgcolor = "white")%>%
        add_trace(y = ~dataset$YoY, name = 'Year over Year',mode = 'lines+markers')
    })
  })
}
# Run the application 
shinyApp(ui = ui, server = server)

