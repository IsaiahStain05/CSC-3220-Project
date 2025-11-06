install.packages("tidymodels")
install.packages("ggplot2")
install.packages("dplyr")
library(tidymodels)
library(ggplot2)
library(dplyr)

adults <- read.csv("./dataset/adult.data")
colnames(adults) <- c("age", "workclass", "fnlwgt", "education", "education-num", "marital-status", "occupation", "relationship", "race", "sex", "capital-gain", "capital-loss", "hours-per-week", "native-country", "class")

adults[adults$class == " <=50K", "class"] <- 0    # sets the class <=50K to 0
adults[adults$class == " >50K", "class"] <- 1     # sets the class >50K to 1


cols <- c("workclass", "education", "marital-status", "occupation", "relationship", "sex", "native-country", "class")
adults[cols] <- lapply(adults[cols], function(x) ifelse(x == " ?", NA, x))
adults <- drop_na(adults)