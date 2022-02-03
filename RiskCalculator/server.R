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

  output$distPlot <- renderPlot({

    print("Starting render plot")

    geom_list <- lapply(input$variables,
                        function(xx) geom_line(aes_string(y = xx), color = input$colour_lines, size = 1)
                        )

    ggplot(dat1, aes_string(x = "reporting_date")) +
      geom_list +
      ylab("counts")

  })

})
