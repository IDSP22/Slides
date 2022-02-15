library(shiny)
library(tidyverse)
library(sortable)
library(shinyWidgets)
library(GGally)


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # begin by creating a 'store' object
  # store is a reactive container that can hold information across the app
  store <- reactiveValues()
  # add an empty list to stroe that will be used to save results
  store$results <- list()
  # create an iterator within store, this will count how many plots /models have been fit
  store$number_of_plots <- 0
  
  # reactive function to load my data, I use read_csv from tidyverse/readr
  # see Wickham for details
  load_data <- reactive({
    dat <- read_csv(input$load_file$datapath)
    return(dat)
    
  })
  
  # update color options
  # this will allow us to color by any variable we are plotting
  observeEvent(input$X,{
    updateSelectInput(inputId = 'color', 
                      choices = c('None', input$X))
  })
  
  
  # this will be the function that build plots when it is called
  build_plot <- reactive({
    # when ever the function is used we update 'number_of_plots'
    # this will keep track of how many plots we have created
    store$number_of_plots <- store$number_of_plots + 1
    # we will create a title for each plot with Plot and a number
    # ex Plot1, Plot2 etc. 
    plot_title <- paste0('Plot', store$number_of_plots)
    # now lets create a unique id so we dont recreate the same plot over and over again
    # REMEMBER to sort!!
    # I used + for collapse but you can use anything '' , ',' would both work but the collpse is important
    unique_id  <- paste0(sort(input$X), input$color, collapse = '+')
    ## for ggplot save a hard copy of the data.frame and color variable 
    # this is done wiht dat and .color variables 
    
    # if there is no color make a pairs plot with no colro
    if(input$color == 'None'){
      dat <- load_data()
      p <- ggpairs(data = dat, columns = input$X) + theme_bw()
      print(p)
    }else{
      # if we picked a color lets add the color
      dat <- load_data()
      .color <- input$color
      p <- ggpairs(data = dat,columns = input$X, 
                   aes(color = as.factor(get(.color)),
                       alpha = .7)) + 
        theme_bw() + 
        print(p)
   

    }
    
    # we will need our function to output the unique id the plot_title and the plot
    # we can do this with a list!
    # I create a new list called out and return it as output form the function
    # I use the assign to dynamically creaate names for each plot
    # each plot will be assigned p_1, p_2 etc. 
    out <- list(unique_id,plot_title,assign(paste0('p_', store$number_of_plots), p))
    return(out)
    
  })

  # make_plot is an action button defined in the UI
  # check an see if plot is valid 
  # if the user does not pass at least two variables to the ploting function throw then a warning and stop the funciton
  observeEvent(input$make_plot, {
    if(length(input$X) <2){
      show_alert(title = 'Plotting Error', 
                 text = 'You must select a minimum of 2 variables to be ploted', 
                 type = 'error')
    }
  })
  

  observeEvent(input$make_plot,{
    req(length(input$X) > 1) # will not execute unless this is met
    # lets record the propossed new plot
    proposal <- paste0(sort(input$X), input$color, collapse = '+')
    # this if statement will check and see if the propossal has already been created
    # if it is a new proposal we will run out plot function
    if(isFALSE(proposal %in% lapply(store$results, '[[', 1))){
      store$results[[store$number_of_plots]] <- build_plot()

    }else{
      # if the propossal already exists as a unique_id (stored in the 1st element of the results list)
      # throw an warning and let them now which plot it is
      # notive if the proposal already exists we DO NOT re-run the make_plot function 
    
      replicate <- which(proposal %in% lapply(store$results, '[[', 1))
      show_alert(
        title = 'Replicated Plot!',
        text = paste(
          'You have already made this plot! See',
          store$results[[replicate]][[2]],
          'for results'
        ),
        type = 'success'
      )
    }
    
    # this will update the plot options on the result page as we create more and more plots
    updateSelectInput(inputId = 'plots',
                      # update the titles for as more plots come in 
                      choices = lapply(store$results, '[[', 2), 
                      # we want to show a new plot whenever it is created
                      selected = lapply(store$results, '[[', 2)[[store$number_of_plots]])
    
    # this will take us to the result page whenever the build plot button is hit
    # App is the id of my namvbar pg2 is the id of the results page
    # see the ui for examples
    updateNavbarPage(inputId = 'App', 
                     selected = 'pg2')
  })
  
  # when user clicks new plot lets take them back to the build page
  observeEvent(input$new_plot,{
    updateNavbarPage(inputId = 'App', 
                     selected = 'pg1')
  })
  
  
  # this will search our results list and return the plot a user has selectd
  # input 
  output$show_plot <- renderPlot({
    pull <- which(lapply(store$results, '[[', 2) == input$plots)
     store$results[[pull]][3]
    
    
  })

 
  
  # this is the code for how to build the drag drop
  # the whole think is a bucket_list, each of the two rectangles are add_rank_list
  output$drag_drop <- renderUI({
    bucket_list(
      header = 'Specify a Linear Regression:',
      add_rank_list(
        input_id = 'variables',
        text = strong("Avalable Variables"),
        labels = names(load_data()),
        options = sortable_options(multiDrag = TRUE)
      ), 
      add_rank_list(
        input_id = 'X', 
        text = strong("Plot Variables"), 
        labels = NULL, 
        options = sortable_options(multiDrag = TRUE)
      )
    )
  })
  
})
