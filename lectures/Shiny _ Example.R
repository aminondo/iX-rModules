library(dplyr)
library(plotly)
library(Quandl)

# ---------------------------------------------------------------------------------------------------------------------
# SERVER
# ---------------------------------------------------------------------------------------------------------------------

cache = list()

server <- function(input, output) {
  observe({
    input$smooth
    message("Keeping track of smoothing...")
  })
  stock.data <- reactive({
    ticker <- input$ticker
    if (!(ticker %in% names(cache))) {
      message("Data not in cache. Retrieving now.")
      cache[[ticker]] <<- stocks <- Quandl(paste0("WIKI/", ticker), collapse = "weekly") %>%
        dplyr::rename(date = Date, adj_close = `Adj. Close`) %>%
        dplyr::select(date, adj_close)
      print(head(cache[[ticker]]))
    }
    cache[[ticker]]
  })
  output$stockPlot <- renderPlotly({
    stocks <- stock.data()
    print(head(stocks))
    p <- plot_ly(stocks, x = ~date, y = ~adj_close, name = "raw") %>%
      layout(
        showlegend = F,
        xaxis = list(title = NA),
        yaxis = list(title = "Adjusted Close")
      )
    if (input$smooth) {
      p <- add_trace(p, y = ~fitted(loess(adj_close ~ as.numeric(date), span = max(input$span, 0.01))), x = ~date, name = "smoothed")
    }
    p
  })
  output$recentQuote <- renderText({
    recent <- head(stock.data(), 1)
    #
    sprintf("Adjusted close price on %s was %.2f.", recent$date, recent$adj_close)
  })
}
# ---------------------------------------------------------------------------------------------------------------------
# INTERFACE
# ---------------------------------------------------------------------------------------------------------------------

ui <- fluidPage(
  titlePanel("Ticker Data"),
  sidebarPanel(
    selectInput("ticker", "Stock", width = NULL,
                choices = c("AAPL", "AMD", "RDEN", "REV", "CYTK", "REXI", "CMA")
    ),
    checkboxInput("smooth", "Smooth", value = TRUE),
    # Display this only if smoothing is activated.
    conditionalPanel(
      condition = "input.smooth == true",
      sliderInput("span", "Smoother Span", min = 0, max = 1, value = 0.5)
    )
  ),
  mainPanel(
    plotlyOutput("stockPlot"),
    textOutput("recentQuote")
  )
)

# ---------------------------------------------------------------------------------------------------------------------

shinyApp(ui = ui, server = server)