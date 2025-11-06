install.packages("tidymodels")
install.packages("ggplot2")
install.packages("dplyr")
library(tidymodels)
library(ggplot2)

setwd("/Users/lucasdowlen/Desktop/RProject/CSC-3220-Project") 
library(dplyr)

adults <- read.csv("./dataset/adult.data")
colnames(adults) <- c("age", "workclass", "fnlwgt", "education", "education-num", "marital-status", "occupation", "relationship", "race", "sex", "capital-gain", "capital-loss", "hours-per-week", "native-country", "class")

adults[adults$class == " <=50K", "class"] <- 0    # sets the class <=50K to 0
adults[adults$class == " >50K", "class"] <- 1     # sets the class >50K to 1

cols <- c("workclass", "education", "marital-status", "occupation", "relationship", "sex", "native-country", "class")
adults[cols] <- lapply(adults[cols], function(x) ifelse(x == " ?", NA, x))
adults <- drop_na(adults)

#Education has the highest correlation. Age and hours per week have moderate correlation. Capital-loss has low correlation.
nums <- adults[, sapply(adults, is.numeric)]
corr_matrix <- cor(nums, use = "complete.obs")
corr_with_income <- corr_matrix[, "class"]

print(corr_with_income)

#Display non-numeric correlations between income (>50k) and other census data
non_numeric <- adults[, !sapply(adults, is.numeric)]
dummy_vars <- model.matrix(~ . - 1, data = non_numeric)  # one-hot encode without intercept

encoded_data <- cbind(dummy_vars, class = as.numeric(adults$class))

cat_correlations <- cor(encoded_data, use = "complete.obs")[, "class"]

cat_correlations_sorted <- sort(cat_correlations, decreasing = TRUE)

cat("Correlations with income:\n")
print(head(cat_correlations_sorted, 100))