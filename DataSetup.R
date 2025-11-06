install.packages("tidymodels")
install.packages("ggplot2")
library(tidymodels)
library(ggplot2)

setwd("/Users/lucasdowlen/Desktop/RProject/CSC-3220-Project") 

adults <- read.csv("./dataset/adult.data")
colnames(adults) <- c("age", "workclass", "fnlwgt", "education", "education-num", "marital-status", "occupation", "relationship", "race", "sex", "capital-gain", "capital-loss", "hours-per-week", "native-country", "class")

adults[adults$class == " <=50K", "class"] <- 0    # sets the class <=50K to 0
adults[adults$class == " >50K", "class"] <- 1     # sets the class >50K to 1

#Education has the highest correlation. Age and hours per week have moderate correlation. Capital-loss has low correlation.
nums <- adults[, sapply(adults, is.numeric)]

corr_matrix <- cor(nums, use = "complete.obs")

corr_with_income <- corr_matrix[, "class"]

print(corr_with_income)