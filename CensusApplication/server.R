

server <- function(input, output, session) {
  xg_model <- readRDS("../xgboostModel.rds")
  observeEvent(input$predict, {
    new_adult <- data.frame(input$age, input$workclass, input$fnlwgt, input$education, input$`education-num`, input$`marital-status`, input$occupation, input$relationship, input$race, input$sex, input$`capital-gain`, input$`capital-loss`, input$`hours-per-week`, input$`native-country`)
    colnames(new_adult) <- c("age", "workclass", "fnlwgt", "education", "education-num", "marital-status", "occupation", "relationship", "race", "sex", "capital-gain", "capital-loss", "hours-per-week", "native-country")
    predicted_class <- predict(xg_model, new_data = new_adult) |> bind_cols(new_adult)
    output$prediction_result <- renderText({
      if (as.logical(predicted_class$.pred_class)) {
        paste("Predicted income class: Makes less than or equal to $50K per Year")
      }else{
        paste("Predicted income class: Makes more than $50K per Year")
      }
    })
  })
}