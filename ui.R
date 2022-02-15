library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("HW1 Answer Key"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            radioButtons(inputId = "data",
                        label = 'Select a dataset:',
                        choices = c('mtcars', 'penguins')),

            selectInput("variable",
                        label = 'Select a variable:',
                        choices = NULL),

          
            uiOutput('slider')

        ),

        # Show a plot of the generated distribution
        mainPanel(
            uiOutput('groups'), 
            plotOutput("myPlot")
        )
    )
))

