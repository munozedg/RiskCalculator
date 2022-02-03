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

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("RiskCalculator"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(

            colourInput("col", "Select colour", "blue"),

            selectInput("variable", "Select variable", colnames(dat1)[-(1:3)])
        ),

        # Show a plot of the generated distribution
        mainPanel(plotOutput("distPlot"))

    )
))
