library(shiny)
library(DT)

shinyUI(fluidPage(
    titlePanel("TREC Run Explorer"),
    fluidRow(
        column(
            width = 3,
            "Run 1",
            selectizeInput(
                "run1",
                "Select a run:",
                "base"
            ),
            dataTableOutput("run1_table")
        ),
        column(
            width = 6,
            "Data stuff",
            selectInput("topic","Topic in focus:","none"),
            dataTableOutput("topic_table"),
            plotOutput('topic_lines'),
            "Best docs available:",
            plotOutput("qrels_dist", height = "200px"),
            dataTableOutput("best_qrels_table")
        ),
        column(
            width = 3,
            "Run 2",
            selectizeInput(
                "run2",
                "Select a run:",
                "tune"
            ),
            dataTableOutput("run2_table")
        )
    )
))
