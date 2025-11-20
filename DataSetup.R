# NOTE: Read the README.md file to ensure you have set up this workspace correctly!!

install.packages("tidymodels")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("randomForest")
install.packages("xgboost")
install.packages("discrim")
install.packages("naivebayes")
library(tidymodels)
library(ggplot2)
library(dplyr)
library(randomForest)
library(xgboost)
library(discrim)
library(naivebayes)


set.seed(200)

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

training$class <- as.factor(training$class)
test$class <- as.factor(test$class)

# Logistic model implementation
logModel <- glm(class ~ ., family="binomial", data = training)
pred_probs <- predict(logModel, newdata = test, type = "response") |> bind_cols(test)
pred_probs$.pred_class <- pred_probs$...1 > 0.5
pred_probs$.pred_class <- as.factor(pred_probs$.pred_class)

#Random forest model implementation
adults_recipe <- recipe(class ~ ., data = training) |> step_dummy(all_nominal_predictors())
adultRFModel <- rand_forest(mode="classification", engine="randomForest", mtry = 9, min_n = 1)
adults_workflow <- workflow() |> add_model(adultRFModel) |> add_recipe(adults_recipe)
adult_RfFit <- adults_workflow |> fit(data = training)
predictions <- predict(adult_RfFit, new_data = test, type = "prob") |> bind_cols(predict(adult_RfFit, new_data = test)) |> bind_cols(test)

# XGBoost model implementation
adult_boost_model <- boost_tree(mode="classification", engine="xgboost", trees=100)
adult_xg_fit <- adult_boost_model |> fit(class ~ ., data = training)
pred_xg <- predict(adult_xg_fit, new_data = test, type="class") |> bind_cols(predict(adult_xg_fit, new_data = test, type="prob")) |> bind_cols(test)

adult_nb_model <- naive_Bayes(mode="classification", engine="naivebayes", smoothness = 1)
adult_nb_wf <- workflow() |> add_model(adult_nb_model) |> add_recipe(adults_recipe)
adult_nb_fit <- fit(adult_nb_wf, data = training)
nb_pred_class <- predict(adult_nb_fit, new_data = test, type = "class") |> bind_cols(test)
nb_pred_probs <- predict(adult_nb_fit, new_data = test, type = "prob") |> bind_cols(test)
nb_f1 <- f_meas(nb_pred_class, truth = class, estimate = .pred_class, beta = 1)
nb_auc <- roc_auc(nb_pred_probs, truth = class, .pred_TRUE, event_level = "second")

log_auc <- roc_auc(pred_probs, truth = class, ...1, event_level = "second")
log_acc <- mean(pred_probs$.pred_class == test$class)
log_prec <- precision(pred_probs, truth = class, estimate = .pred_class)

rf_auc <- roc_auc(predictions, truth = class, .pred_TRUE, event_level = "second")
rf_acc <- mean(predictions$.pred_class == predictions$class)
rf_prec <- precision(predictions, truth = class, estimate = .pred_class)

xg_auc <- roc_auc(pred_xg, truth = class, .pred_TRUE, event_level = "second")
xg_acc <- mean(pred_xg$.pred_class == pred_xg$class)
xg_prec <- precision(pred_xg, truth = class, estimate = .pred_class)
xg_f1 <- f_meas(pred_xg, truth = class, estimate = .pred_class, beta = 1)

# rm(adults_workflow, adultRFModel, adults_recipe, test, training, firstSplit, adult_RfFit, predictions) <- remove all variables for the random forest
# rm(test, training, logModel, pred_probs, firstSplit, predicted) <- To remove all variables for the log model