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

  # gt_plot ----



  output$gt_table_data <- render_gt({
    cols      <- c("change_in_7_day_moving_avg", "count_7_day_moving_avg")
    gt(dat1) %>% cols_hide(c("globalid", "objectid")) %>%
      fmt_number(all_of(cols), decimals = 1) %>%
      fmt_missing(columns = everything(), missing_text = "") %>%
      data_color(
        columns = c(total_case_daily_change),
        colors = scales::col_numeric(palette =
                                       c('green', 'red'),
                                     domain = NULL)
      ) %>%
      tab_style(
        style = list(cell_fill(color = "lightcyan"),
                     cell_text(weight = "bold")),
        locations = cells_body(
          columns = c(change_in_7_day_moving_avg),
          rows = change_in_7_day_moving_avg > 0
        )
      ) %>% cols_label(change_in_7_day_moving_avg = "Change 7-day MA",
                       count_7_day_moving_avg = "Count 7-day MA")
  })

  # distPlot ----

  output$distPlot <- renderPlotly({

    print("Starting render plot")
    print(input$variables)

    geom_list <- lapply(input$variables,
                        function(xx)
                          geom_line(
                            aes_string(y = xx),
                            linetype = "dotted",
                            color = input[[paste0(xx, "_color")]],
                            size = 1
                          ))

    plt <- ggplot(dat1, aes_string(x = "reporting_date")) +
      geom_list + ylab("Counts")

    ggplotly(plt) %>% layout(dragmode='select')

  })

})
