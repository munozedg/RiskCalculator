#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(colourpicker)
library(shinyBS)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  # Application title
  titlePanel("Risk Calculator"),

  # Sidebar with a slider input for number of bins
  tabsetPanel(
    tabPanel("Risk Panel",
             sidebarLayout(
               sidebarPanel(
                 selectInput(
                   "variables",
                   "Select variable",
                   colnames(dat1)[-(1:3)],
                   multiple = TRUE,
                   selectize = TRUE,
                   selected = colnames(dat1)[15]
                 ),
                 uiOutput("ycol")
               ),

               # Show a plot of the generated distribution
               mainPanel(fluidRow(column(
                 10, plotlyOutput("distPlot")
               )))
             )),

    tabPanel("Data 2", gt_output("gt_table_data")),

    tabPanel("Data 3", gt_output("sparktable")),

    tabPanel("Data 4", gt_output(""))



  )
))
