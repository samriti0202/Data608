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

data_url <- getURL('https://raw.githubusercontent.com/charleyferrari/CUNY_DATA608/master/lecture3/data/cleaned-cdc-mortality-1999-2010-2.csv')
mortality_data <- read_csv(data_url)
mortality_data <- mortality_data %>% group_by(ICD.Chapter, Year) %>% mutate(National.Ave = sum(Deaths)*1e5/sum(Population))
mortality_data_wide <- mortality_data %>% spread(State,ICD.Chapter)

#setting up the options for the drop-down menues for the user to select data
featureList1 <- mortality_data$State
featureList2 <- mortality_data$ICD.Chapter
ui <- fluidPage(
    # Set theme
    # Some help text
    headerPanel("Mortality Rate per Year by State"),
    # Feature selection
    sidebarPanel(
        selectInput(inputId = "featureInput1", label = "Select State(s)", choices = featureList1, selected = "AL"),
        selectInput(inputId = "featureInput2", label = "Select Disease Catagory", choices = featureList2, selected = "Neoplasms")),
    mainPanel(
        plotlyOutput('trendPlot')
    )
)


server <- function(input, output){
    #https://plot.ly/r/shinyapp-explore-diamonds/ used as a template
    # Observes the second feature input for a change
    observeEvent(input$featureInput2,{
        # Create a convenience data.frame which can be used for charting
        dataset <-mortality_data[which(mortality_data$State == input$featureInput1 & mortality_data$ICD.Chapter == input$featureInput2),]
        # Do a plotly contour plot to visualize the two featres with
        # the number of malignant cases as size
        # Note the use of 'source' argument
        output$trendPlot <- renderPlotly({
            plot_ly(dataset, x = ~Year, y = ~Crude.Rate, type = "scatter",  name = input$featureInput1, mode = "lines+markers", source = "subset") %>%
                layout(title = paste("Mortailty vs Year for ",input$featureInput1, "and ", input$featureInput2),
                       xaxis = list(title = 'Year'),
                       yaxis = list(title = 'Deaths per 100,000'),
                       dragmode =  "select",
                       plot_bgcolor = "white")%>%
                add_trace(y = ~dataset$National.Ave, name = 'National Average',mode = 'lines+markers')
        })
    })
}

shinyApp(ui, server, options = list(height = 720, width = 1080))#I tried to make the graph bigger with little success

# Run the application 
shinyApp(ui = ui, server = server)
