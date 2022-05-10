#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

conflict_prefer("layout", "plotly")

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

  # sparktable ----

  output$sparktable <- render_gt({

    print("Starting sparklines...")

    gt_spark_table <- dat1 %>%
      arrange(reporting_date) %>%
      pivot_longer(any_of(colnames(dat1)[-(1:3)])) %>%
      group_by(name) %>%
      summarize(Median = median(value, na.rm = T),
                SD = sd(value, na.rm = T),
                across(.fns = ~list(na.omit(.x)))) %>%
      mutate(histogram = value, density = value) %>%
      rename(sparkline = value) %>%
      gt() %>%
      cols_hide((c("globalid", "objectid","reporting_date"))) %>%
      gt_sparkline(sparkline, type = "sparkline", same_limit = F) %>%
      gt_sparkline(histogram, type = "histogram", same_limit = F) %>%
      gt_sparkline(density,   type = "density",   same_limit = F)

    gt_spark_table

  })

  # mobility ----
  # bx_plot
  output$bx_plot <- renderPlotly({
    bx_plot
  })

})
