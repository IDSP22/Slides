
library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel("Simple Visualization"),

    sidebarLayout(
        sidebarPanel(
          # choose a data set
          selectInput(inputId = 'data', 
                      label = 'select a dataset', 
                      choices = c('mtcars', 'diamonds')), 
          
          # select a variable from the selected data set
          selectInput(inputId = 'variable', 
                      label = 'choose a variable', 
                      choices = NULL), 
          
          # old code that always has the slider
          # sliderInput(inputId = 'bins', 
          #             label = 'Number of bins:', 
          #             min = 5 ,
          #             max = 50, 
          #             value = 20)
          
          # UI created in the server slider is now conditional on the choosen variable
          uiOutput('slider')
        ), 
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("histogram")
        )
    )
))
