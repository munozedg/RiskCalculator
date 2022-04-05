# sandbox_gt_and_gtExtras.R

cols      <- c("change_in_7_day_moving_avg", "count_7_day_moving_avg")
cols_lbls <- list(change_in_7_day_moving_avg = "Change 7-day MA",
               count_7_day_moving_avg = "Count 7-day MA")

gt_preview(dat1) %>% cols_hide(c("globalid", "objectid")) %>%
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

# gt_sparkline()

# first -- pivot longer?

pivot_longer(dat1, any_of(colnames(dat1)[-(1:3)])) %>%
  arrange(reporting_date) %>%
  group_by(name) %>%
summarize(across(.fns = ~list(.x))) %>%  View()
