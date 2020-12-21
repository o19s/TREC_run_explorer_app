library(shiny)
library(glue)
library(tidyverse)

theme_set(
    ggthemes::theme_fivethirtyeight(base_size = 16) +
        theme(legend.position = "top",
              legend.direction = "horizontal",
              axis.title = element_text())
)

topics <- readRDS("data/topics2020.RDS")

evals <- readRDS("data/osc_run_explorer_data.RDS")
qrels <- readRDS("data/qrels2.RDS")
available_runs <- unique(evals$run)

subs <- readRDS("data/submissions.RDS")

datertable <- function(x, ...) {
    datatable(x, escape = F, rownames = F, options = list(dom = 't'))
}

shinyServer(function(input, output, session) {
    rvs <- reactiveValues()
    observeEvent(
        input[['run1']],
        {
            cur <- isolate(input$run1) %||% available_runs[1]
            rvs[['run2_choices']] <- available_runs[!available_runs %in% input[['run1']]]
            updateSelectizeInput(
                session,
                "run1",
                choices = available_runs,
                selected = cur
                )
            updateSelectizeInput(
                session,
                "run2",
                choices = rvs[['run2_choices']]
            )
            updateSelectInput(session, "topic", choices = topics$topic)
        }
    )
    observeEvent(
        c(input$run1, input$run2, input$topic), {
            
            x <- c(input$run1, input$run2)
            rvs$evals <- filter(evals, run %in% x)
            
            rvs$run1_subs <- filter(subs, run == input$run1, topic == input$topic)
            rvs$run2_subs <- filter(subs, run == input$run2, topic == input$topic)
            
            rvs$best_qrels <- filter(qrels, topic == input$topic) %>% 
                arrange(desc(grade))
        }
    )
    
    output$run1_table <- renderDT({
        rvs$run1_subs %>% 
            slice(1:5) %>% 
            select(rank, title_html, grade) %>% 
            datertable()
    })
    
    output$run2_table <- renderDT({
        rvs$run2_subs %>% 
            slice(1:5) %>% 
            select(rank, title_html, grade) %>% 
            datertable()
    })
    
    output$best_qrels_table <- renderDT({
        rvs$best_qrels %>% 
            slice(1:5) %>% 
            select(grade, title_html) %>% 
            datertable()
    })
    
    output$topic_table <- renderDT({
        topics %>% 
            filter(topic == input$topic) %>%
            select(title_html) %>% 
            datertable()
    })
    
    output$qrels_dist <- renderPlot({
        rvs$best_qrels %>% 
            filter(grade != 0) %>% 
            ggplot(aes(as.factor(grade))) +
            geom_bar() +
            labs(x = "Grade", y = "# Docs")
    })
    
    output$topic_lines <- renderPlot({
        ggplot(rvs$evals, aes(topic, val)) +
            geom_rect(xmin = as.numeric(input$topic) - .5, xmax = as.numeric(input$topic) + .5, ymin = -Inf, ymax = Inf, fill = "grey", aes(y=NULL)) +
            geom_line(aes(color = run)) +
            scale_y_continuous(breaks = c(0, .5, 1)) +
            scale_x_continuous(breaks = seq(890, 930, by = 5)) +
            labs(x = "Topic", y = "nDCG@5")
    }, height = 300)
})
