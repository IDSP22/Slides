library(shiny)
library(ggplot2)
shinyServer(function(input, output) {
  
  # create a data loading reactive function to call in data
  dat <- reactive({
    if(input$data == 'mtcars'){dat <- mtcars}else{dat <- diamonds}
    
    return(dat)
  })
  
  observeEvent(input$data, {
    updateSelectInput(inputId = 'variable', 
                      choices = names(dat()))
  })
  
  # create the histograms 
  output$histogram <- renderPlot({
    
    # normal R function to get variable type note it is INSIDE of a reactive function
    get_type <- function(x){
      # if the variable is not numeric return discrete 
      if(is.numeric(x) == FALSE){type <- 'discrete'} 
      
      # if the variable is numeric but has less than 5 unique values return discrete
      else if(length(unique(x))<5){type <- 'discrete'}
      
      # everything else mark continuous
      else{type <- 'continuous'}
      
      # output the type
      return(type)
    }
    
    # get the type of a selected variable
    type <- get_type(dat()[[input$variable]])
    
    if(type == 'continuous'){
      # if the variable selected is continuous make this plot: 
    ggplot(data = dat(), aes_string(input$variable)) + 
      geom_histogram(bins = input$bins) +
      theme_bw()
      
    }else if(type == 'discrete'){
      # if the selected variable is discrete make this plot:
      ggplot(data = dat(), aes_string(input$variable)) + 
        geom_histogram(stat = 'count') +
        theme_bw()
      
    }
    })
  
  
  output$slider <- renderUI({
    get_type <- function(x){
      # if the variable is not numeric return discrete 
      if(is.numeric(x) == FALSE){type <- 'discrete'} 
      
      # if the variable is numeric but has less than 5 unique values return discrete
      else if(length(unique(x))<5){type <- 'discrete'}
      
      # everything else mark continuous
      else{type <- 'continuous'}
      
      
      return(type)
    }
    
    # get the type of the selected variable
    type <- get_type(dat()[[input$variable]]) # I used [[]] indexing but dat()[, input$variable] would also work!
    
    # if the type is continuous add a slider to the UI
    if(type == 'continuous'){
    sliderInput(inputId = 'bins', 
                label = 'Number of bins:', 
                min = 5 ,
                max = 50, 
                value = 20)
    }else{NULL} # if not dont return any UI objects
    
  })
  
})



