#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  print("Starting Shiny Server")

  output$ycol <- renderUI({

    lapply(seq_along(input$variables), function(vv) {
             colourInput(paste0(input$variables[[vv]], "_color"),
                         "specify color",
                         hcl.colors(20, palette = "Dark2")[[vv]])
           })

  })

  output$distPlot <- renderPlotly({

    print("Starting render plot")
    print(input$variables)

    geom_list <- lapply(input$variables,
                        function(xx) geom_line(aes_string(y = xx),
                                                                linetype = "dotted",
                                                                color = input[[paste0(xx, "_color")]], size = 1))

    plt <- ggplot(dat1, aes_string(x = "reporting_date")) +
      geom_list + ylab("Counts")

    ggplotly(plt) %>% layout(dragmode='select')

  })

})
