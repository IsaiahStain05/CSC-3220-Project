# NOTE: Read the README.md file to ensure you have set up this workspace correctly!!

install.packages("tidymodels")
install.packages("ggplot2")
install.packages("dplyr")
library(tidymodels)
library(ggplot2)
library(dplyr)

adults <- read.csv("./dataset/adult.data")
colnames(adults) <- c("age", "workclass", "fnlwgt", "education", "education-num", "marital-status", "occupation", "relationship", "race", "sex", "capital-gain", "capital-loss", "hours-per-week", "native-country", "class")

adults[adults$class == " <=50K", "class"] <- FALSE    # sets the class <=50K to FALSE
adults[adults$class == " >50K", "class"] <- TRUE     # sets the class >50K to TRUE
adults$class <- as.logical(adults$class)


cols <- c("workclass", "education", "marital-status", "occupation", "relationship", "sex", "native-country", "class")
adults[cols] <- lapply(adults[cols], function(x) ifelse(x == " ?", NA, x))
adults <- drop_na(adults)


#Education has the highest correlation. Age and hours per week have moderate correlation. Capital-loss has low correlation.
nums <- adults[, sapply(adults, is.numeric)]
nums$class <- as.numeric(adults$class)
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

clean_cat_correlations_sorted <- cat_correlations_sorted[3:93]
sample_corr_list <- c(head(clean_cat_correlations_sorted, 10), tail(clean_cat_correlations_sorted, 10))

par(mar = c(4, 8, 4, 2))
barplot(clean_cat_correlations_sorted, las=1, horiz=TRUE, cex.names = 0.2)
barplot(sample_corr_list, las=2, horiz=TRUE, cex.names = 0.5, cex.axis = 0.8)

firstSplit <- initial_split(adults, prop=3/4)
training <- training(firstSplit)
test <- testing(firstSplit)

logModel <- glm(class ~ ., family="binomial", data = training)
pred_probs <- predict(logModel, newdata = test, type = "response")
predicted <- pred_probs > 0.5
mean(predicted == test$class)

# rm(test, training, logModel, pred_probs, firstSplit, predicted) <- To remove all variables