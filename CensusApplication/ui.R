# install packages below prior to running
library(shiny)
library(tidymodels)
library(xgboost)
library(tidyverse)

ui <- fluidPage(
  titlePanel("Income Class Predictor"),
  sidebarLayout(
    sidebarPanel(
      numericInput("age", "Age", value=25, min=0, max=100),
      selectInput("workclass", "Working Class", c(" Self-emp-not-inc", " Private", " State-gov", " Federal-gov", " Local-gov", " Self-emp-inc", " Without-pay", " Never-worked")),
      numericInput("fnlwgt", "How many people are represented by this data?", value=0),
      selectInput("education", "Level of Education", c(" Bachelors", " HS-grad", " 11th", " Masters", " 9th", " Some-college", " Assoc-acdm", " Assoc-voc", " 7th-8th", " Doctorate", " Prof-school", " 5th-6th", " 10th", " 1st-4th", " Preschool", " 12th")),
      numericInput("education-num", "Numeric Representation of Education Level", value=12, min=0, max=16),
      selectInput("marital-status", "Marital Status", c(" Married-civ-spouse", " Divorced", " Married-spouse-absent", " Never-married", " Separated", " Married-AF-spouse", " Widowed")),
      selectInput("occupation", "Job", c(" Exec-managerial", " Handlers-cleaners", " Prof-specialty", " Other-service", " Adm-clerical", " Sales", " Craft-repair", " Transport-moving", " Farming-fishing", " Machine-op-inspct", " Tech-support", " Protective-serv", " Armed-Forces", " Priv-house-serv")),
      selectInput("relationship", "Relationship to Head of Household", c(" Husband", " Not-in-family", " Wife", " Own-child", " Unmarried", " Other-relative")),
      selectInput("race", "Race", c(" White", " Black", " Asian-Pac-Islander", " Amer-Indian-Eskimo", " Other")),
      selectInput("sex", "Sex", c(" Male", " Female")),
      numericInput("capital-gain", "Capital Gain (Monetary Gain by sale of assets)", value=0, min=0, max=99999),
      numericInput("capital-loss", "Capital Loss (Monetary Loss by sale of assets)", value=0, min=0, max=99999),
      numericInput("hours-per-week", "Hours Worked per Week", value=40, min=0, max=168),
      selectInput("native-country", "Native Country", c(" United-States", " Cuba", " Jamaica", " India", " Mexico", " South", " Puerto-Rico", " Honduras", " England", " Canada", " Germany", " Iran", " Philippines", " Italy", " Poland", " Columbia", " Cambodia", " Thailand", " Ecuador", " Laos", " Taiwan", " Haiti", " Portugal", " Dominican-Republic", " El-Salvador", " France", " Guatemala", " China", " Japan", " Yugoslavia", " Peru", " Outlying-US(Guam-USVI-etc)", " Scotland", " Trinadad&Tobago", " Greece", " Nicaragua", " Vietnam", " Hong", " Ireland", " Hungary", " Holand-Netherlands")),
      actionButton("predict", "Predict Income Class")
    ),
    mainPanel(
      textOutput("prediction_result")
    )
  )
)