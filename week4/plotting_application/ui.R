library(shiny)

shinyUI(navbarPage(id = 'App', # id for the navbar
                   title = 'Compare Many Plots:',
                   tabPanel(value = 'pg1', # see server for how this is used to aut-update a page
                            # define the data load page
                            title = 'Load Data and Choose Variables',
                            fileInput(
                              inputId = 'load_file',
                              label = 'Select a .csv file:',
                              accept = ".csv"
                            ),
                            uiOutput('drag_drop'), # drag drop ui
                            
                            # pick a color I used fluidRow so I could move this to a particular spot on the page
                            # see wickham ch 6
                            fluidRow(column(
                              width = 3,
                              offset = 8,
                              selectInput(inputId = 'color', 
                                          label = 'Color by:', 
                                          choices = NULL), 
                              # click to create a plot this is a button
                              actionButton(
                                inputId = 'make_plot',
                                label = "Build Plot",
                                width = '110%'
                              )
                            ))
                            
                   ),
                   
                   # define the results page 
                   tabPanel(value = 'pg2', # see server for how this is used to aut-update a page
                            title = 'View Results', sidebarLayout(
                              # place to flip through created plots 
                              sidebarPanel(selectInput(inputId = 'plots', 
                                                       label = 'Plots:', 
                                                       choices = NULL), 
                                           # button to take user back to the data page
                                           actionButton(inputId = 'new_plot',
                                                        label = 'Build New Plot')
                                           
                                           
                              ),
                              mainPanel(
                              # big pannel to show the results!!
                              plotOutput('show_plot')
                              )))
))




