library(shiny)
source("master.R")
require(readr)
require(ggplot2)
devTechTable <- read_csv("devTechTable.csv")

ui <- fluidPage(
  titlePanel("The 2020 StackOverflow User Survey"),
  sidebarLayout(
    sidebarPanel(
      selectInput("techSelect", label = h3("Select technology category"), 
                  choices = list("Languages" = "LanguageDesireNextYear", 
                                 "Databases" = "DatabaseDesireNextYear", 
                                 "Platforms" = "PlatformDesireNextYear",
                                 "Webframes" = "WebframeDesireNextYear", 
                                 "Collab Tools" = "NEWCollabToolsDesireNextYear", 
                                 "Misc. Tech" = "MiscTechDesireNextYear"), 
                  selected = 1),
      selectInput("devSelect", label = h3("Select a role"),
                  choices = list("all" = "all",
                                 "Developer, Front End" = "DEVfe",
                                 "Developer, Back End" = "DEVba",
                                 "Developer, Full-Stack" = "DEVfs",
                                 "Developer, Mobile" = "DEVmob",
                                 "Developer, Desktop or Enterprise" = "DEVdea",
                                 "Developer, QA or Testing" = "DEVqa",
                                 "Developer, Embedded Applications" = "DEVemb",
                                 "Developer, Games or Graphics" ="DEVgg",
                                 "Academic Researcher" = "DEVacdres",
                                 "Business Analyst" = "DEVbiz",
                                 "Database Admin" = "DEVdba",
                                 "Date Engineer" = "DEVde",
                                 "Data Scientist  / ML Specialist" = "DEVmlds",
                                 "Designer" = "DEVdes",
                                 "DevOps Specialist" = "DEVops",
                                 "Educator" = "DEVedu",
                                 "Engineer, Site Reliability" = "DEVengsr",
                                 "Engineer, Manager" = "DEVmaneng",
                                 "Executive  / VP" = "DEVdbag",
                                 "Product Manager" = "DEVmanprod",
                                 "Sales / Marketing" = "DEVsales",
                                 "Scientist" = "DEVsci",
                                 "Systems Administrator" = "DEVsysadm"),
                  selected = "all")
    ),
    
    mainPanel(
      plotOutput("myBarChart"),
      h4("This plot is a summarization of a subset of data from the 2020 StackOverflow user survey.
         There are two variables of importance here. First is the self-proclaimed professional 'role' of the respondent (front-end dev,
         back-end, database administrator, etc). Respondents could state more than one role, but they had to pick from a list
         in the survey. The second variable consists of technologies that the respondent desired to learn more about in the next
         year."
      )
    
  )
  

)
)



server <- function(input, output) {
  output$myBarChart <- renderPlot({
    makeBarGraph(devTechTable, input$techSelect, input$devSelect)
  })
}

shinyApp(ui, server)
