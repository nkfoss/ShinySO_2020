library(shiny)
source("./fnxs/master.r")
require(readr)
require(ggplot2)
devTechTable <- read_csv("./devTechTable.csv")

function(input, output) {
  output$myBarChart <- renderPlot({
    makeBarGraph(devTechTable, input$techSelect, input$devSelect)
  })
}