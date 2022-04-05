# sandbox_gt_and_gtExtras.R

cols      <- c("change_in_7_day_moving_avg", "count_7_day_moving_avg")

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


gt_spark_table <- dat1 %>%
  arrange(reporting_date) %>%
  pivot_longer(any_of(colnames(dat1)[-(1:3)])) %>%
  group_by(name) %>%
  summarize(across(.fns = ~list(na.omit(.x)))) %>%
  mutate(histogram = value, density = value) %>%
  rename(sparkline = value) %>%
  gt() %>%
  cols_hide((c("globalid", "objectid","reporting_date"))) %>%
  gt_sparkline(sparkline, same_limit = F) %>%
  gt_sparkline(histogram, type = "histogram", same_limit = F) %>%
  gt_sparkline(density, type = "density", same_limit = F)
gt_spark_table

### MArco - code

  dat2_pvt <- dat1 %>%
  arrange(reporting_date) %>%
  pivot_longer(any_of(colnames(dat1)[-(1:3)])) %>%
  group_by(name) %>%
  summarize(across(.fns = ~list(na.omit(.x)))) %>%
  mutate(hist = value, dense = value) %>%
  rename(spark = value) %>%
  gt() %>%
  cols_hide(c("globalid", "objectid", "reporting_date")) %>%
  gt_sparkline (spark, same_limit = F) %>%
  gt_sparkline (hist, type = "histogram", same_limit = F) %>%
  gt_sparkline (dense, type = "density", same_limit = F)
dat2_pvt


### more functions - most recent version

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

