library(shiny)
library(tidyverse)
library(palmerpenguins)

get_type <- function(x){
  # if the variable is not numeric return discrete
  if(is.numeric(x) == FALSE){type <- 'discrete'}

  # if the variable is numeric but has less than 5 unique values return discrete
  else if(length(unique(x))<5){type <- 'discrete'}

  # everything else mark continuous
  else{type <- 'continuous'}


  return(type)
}




# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  dat <- reactive({
    if(input$data == 'mtcars'){dat <- mtcars}else{dat <- penguins}

    return(dat)
  })

  observeEvent(input$data, {
    updateSelectInput(inputId = 'variable',
                      choices = names(dat()))
  })

    renderUI({
      
    })
  output$groups <- renderUI({
    if(get_type(dat()[[input$variable]]) == 'continuous'){
      index <- which(unlist(lapply(dat(), get_type)) == 'discrete')
      selectInput(inputId = 'group_by',
                  label = paste('group', input$variable, 'by:'),
                  choices = c('None', names(dat()[, index])))
    }else{NULL}
  })

  output$slider <- renderUI({
    if(get_type(dat()[[input$variable]]) == 'continuous'){
      sliderInput("slider",
                  "Choose number of bins:",
                  min = 1,
                  max = 50,
                  value = 20)
    }else{NULL}
  })

  output$facet <- renderPlot({
    p <- ggplot(data = dat(), aes(get(input$variable))) +
      geom_histogram(bins = input$slider, position = 'identity') +
      labs(x = input$variable) +
      facet_wrap(~ get(input$group_by)) +
      theme_bw()
    return(p)
  })
  output$myPlot <- renderPlot({
    req(input$variable)
    req(input$group_by)
    if (get_type(dat()[[input$variable]]) == 'continuous') {
      p <- ggplot(data = dat(), aes(get(input$variable))) +
        geom_histogram(bins = input$slider, position = 'identity') +
        labs(x = input$variable) +
        theme_bw()
      
      
      if (input$group_by != 'None') {
        req(input$group_by)# %in% names(dat()))
        
        p <-
          ggplot(data = dat(), 
                 aes(get(input$variable), 
                     fill = as.factor(get(input$group_by)))) +
          geom_histogram(bins = input$slider, position = 'identity') +
          labs(x = input$variable) +
          theme_bw() + 
          theme(legend.position = "top") +
          guides(fill = guide_legend(title = input$group_by))
          
      }
    } else{
      req(input$variable %in% names(dat()))
    
      p <- ggplot(data = dat(), aes(get(input$variable))) +
        geom_histogram(position = 'identity', stat = 'count') +
        labs(x = input$variable) +
        theme_bw()
    }
    
    return(p)
    
  })
  
 


})



