# NOTE: Read the README.md file to ensure you have set up this workspace correctly!!

install.packages("tidymodels")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("randomForest")
install.packages("xgboost")
install.packages("discrim")
install.packages("naivebayes")
install.packages("caret")
install.packages("cvms")
install.packages("pdp")
install.packages("vip")
install.packages("patchwork")
library(patchwork)
library(vip)
library(pdp)
library(tidymodels)
library(ggplot2)
library(dplyr)
library(randomForest)
library(xgboost)
library(discrim)
library(naivebayes)
library(caret)
library(cvms)


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
# logModel <- glm(class ~ ., family="binomial", data = training)
# pred_probs <- predict(logModel, newdata = test, type = "response") |> bind_cols(test)
# pred_probs$.pred_class <- pred_probs$...1 > 0.5
# pred_probs$.pred_class <- as.factor(pred_probs$.pred_class)

#Random forest model implementation
adults_recipe <- recipe(class ~ ., data = training) |> step_dummy(all_nominal_predictors())
# adultRFModel <- rand_forest(mode="classification", engine="randomForest", mtry = 9, min_n = 1)
# adults_workflow <- workflow() |> add_model(adultRFModel) |> add_recipe(adults_recipe)
# adult_RfFit <- adults_workflow |> fit(data = training)
# predictions <- predict(adult_RfFit, new_data = test, type = "prob") |> bind_cols(predict(adult_RfFit, new_data = test)) |> bind_cols(test)

# XGBoost model implementation
adult_boost_model <- boost_tree(mode="classification", engine="xgboost", trees=100)
adult_xg_fit <- adult_boost_model |> fit(class ~ ., data = training)
pred_xg <- predict(adult_xg_fit, new_data = test, type="class") |> bind_cols(predict(adult_xg_fit, new_data = test, type="prob")) |> bind_cols(test)

# Naive Bayes Implementation and Testing
adult_nb_model <- naive_Bayes(mode="classification", engine="naivebayes", smoothness = 1)
adult_nb_wf <- workflow() |> add_model(adult_nb_model) |> add_recipe(adults_recipe)
adult_nb_fit <- fit(adult_nb_wf, data = training)
nb_pred_class <- predict(adult_nb_fit, new_data = test, type = "class") |> bind_cols(test)
nb_pred_probs <- predict(adult_nb_fit, new_data = test, type = "prob") |> bind_cols(test)
nb_f1 <- f_meas(nb_pred_class, truth = class, estimate = .pred_class, beta = 1)
nb_auc <- roc_auc(nb_pred_probs, truth = class, .pred_TRUE, event_level = "second")
nb_conf_matrix <- confusionMatrix(data=nb_pred_class$.pred_class, reference = nb_pred_class$class)

# log_auc <- roc_auc(pred_probs, truth = class, ...1, event_level = "second")
# log_acc <- mean(pred_probs$.pred_class == test$class)
# log_prec <- yardstick::precision(pred_probs, truth = class, estimate = .pred_class)
# 
# rf_auc <- roc_auc(predictions, truth = class, .pred_TRUE, event_level = "second")
# rf_acc <- mean(predictions$.pred_class == predictions$class)
# rf_prec <- yardstick::precision(predictions, truth = class, estimate = .pred_class)
  
xg_auc <- roc_auc(pred_xg, truth = class, .pred_TRUE, event_level = "second")
xg_acc <- mean(pred_xg$.pred_class == pred_xg$class)
xg_prec <- yardstick::precision(pred_xg, truth = class, estimate = .pred_class)
xg_f1 <- f_meas(pred_xg, truth = class, estimate = .pred_class, beta = 1)
xg_conf_matrix <- confusionMatrix(data=pred_xg$.pred_class, reference = pred_xg$class)

xg_conf_matrix <- as.data.frame(xg_conf_matrix$table)
xg_conf_matrix$Target <- xg_conf_matrix$Reference
xg_conf_matrix$N <- xg_conf_matrix$Freq

nb_conf_matrix <- as.data.frame(nb_conf_matrix$table)
nb_conf_matrix$Target <- nb_conf_matrix$Reference
nb_conf_matrix$N <- nb_conf_matrix$Freq

plot_confusion_matrix(xg_conf_matrix) + ggtitle("XGBoost Confusion Matrix")
plot_confusion_matrix(nb_conf_matrix) + ggtitle("Naive Bayes Confusion Matrix")

xg_pr_curve <- pr_curve(pred_xg, truth = class, .pred_TRUE, event_level = "second")
autoplot(xg_pr_curve) + ggtitle("Precision/Recall Curve for XGBoost")

ggplot(pred_xg, aes(x=.pred_TRUE, fill=class)) + geom_density(alpha=0.4) + labs(title = "Predicted Probability Distribution", x = "Predicted Probability Income >$50K", y = "Density")

# rm(adults_workflow, adultRFModel, adults_recipe, test, training, firstSplit, adult_RfFit, predictions) <- remove all variables for the random forest
# rm(test, training, logModel, pred_probs, firstSplit, predicted) <- To remove all variables for the log model

xg_probs  <- pred_xg  %>% select(class, .pred_TRUE) %>% mutate(model = "XGBoost")
nb_probs  <- nb_pred_probs %>% select(class, .pred_TRUE) %>% mutate(model = "Naive Bayes")
all_probs <- bind_rows(xg_probs, nb_probs)
ggplot(all_probs, aes(x = .pred_TRUE, fill = class)) +
geom_density(alpha = 0.3) +
facet_wrap(~ model) +
scale_fill_manual(values = c("FALSE" = "gray60", "TRUE" = "darkred")) +
labs(
title = "Predicted Probability Distributions (XGBoost vs Naive Bayes)",
x = "Predicted P(Income >50K)",
y = "Density",
fill = "True Class"
) +
theme_minimal()
summary(pred_xg$.pred_TRUE)
unique(pred_xg$.pred_TRUE)
table(pred_xg$.pred_TRUE)
summary(nb_pred_probs$.pred_TRUE)
unique(nb_pred_probs$.pred_TRUE)
table(nb_pred_probs$.pred_TRUE)
ggplot(nb_pred_probs, aes(x = .pred_TRUE, fill = class)) +
geom_histogram(binwidth = 0.05, alpha = 0.5, position = "identity") +
scale_fill_manual(values = c("FALSE" = "gray60", "TRUE" = "darkred"),
labels = c("<=50K", ">50K")) +
labs(
title = "Predicted Probability Histogram – Naive Bayes",
x = "Predicted P(Income >50K)",
y = "Count"
) +
theme_minimal()
table(nb_pred_probs$.pred_TRUE)
# Cross-tab with the true class:
table(PredProb = nb_pred_probs$.pred_TRUE, TrueClass = nb_pred_probs$class)
# Prepare probability columns for each model
xg_probs <- pred_xg %>%
select(class, .pred_TRUE) %>%
mutate(model = "XGBoost")

nb_probs <- nb_pred_probs %>%
select(class, .pred_TRUE) %>%
mutate(model = "Naive Bayes")
# Combine into one dataset
all_probs <- bind_rows(xg_probs, nb_probs)
# Side-by-side comparison
ggplot(all_probs, aes(x = .pred_TRUE, fill = class)) +
geom_histogram(binwidth = 0.05, alpha = 0.5, position = "identity") +
facet_wrap(~ model, ncol = 2) +
scale_fill_manual(
values = c("FALSE" = "gray70", "TRUE" = "darkred"),
labels = c("<=50K", ">50K")
) +
labs(
title = "Predicted Probability Distributions (XGBoost vs Naive Bayes)",
x = "Predicted P(Income >50K)",
y = "Count",
fill = "True Class"
) +
theme_minimal()
# ROC data for each model
xg_roc <- roc_curve(pred_xg,
truth = class,
.pred_TRUE,
event_level = "second") %>%
mutate(model = "XGBoost")
nb_roc <- roc_curve(nb_pred_probs,
truth = class,
.pred_TRUE,
event_level = "second") %>%
mutate(model = "Naive Bayes")
# Combine for plotting
both_roc <- bind_rows(xg_roc, nb_roc)
ggplot(both_roc,
aes(x = 1 - specificity, y = sensitivity, color = model)) +
geom_path(linewidth = 1) +
geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
coord_equal() +
labs(
title = "ROC Curves – XGBoost vs Naive Bayes",
x = "False Positive Rate (1 - Specificity)",
y = "True Positive Rate (Sensitivity)",
color = "Model"
) +
theme_minimal()
xg_conf <- conf_mat(
pred_xg,
truth = class,
estimate = .pred_class
)
autoplot(xg_conf, type = "heatmap") +
scale_fill_gradient(low = "white", high = "steelblue") +
ggtitle("Confusion Matrix – XGBoost") +
theme_minimal()
nb_conf <- conf_mat(
nb_pred_class,
truth = class,
estimate = .pred_class
)
autoplot(nb_conf, type = "heatmap") +
scale_fill_gradient(low = "white", high = "darkred") +
ggtitle("Confusion Matrix – Naive Bayes") +
theme_minimal()
p_xg <- autoplot(xg_conf, type = "heatmap") +
scale_fill_gradient(low = "white", high = "steelblue") +
ggtitle("XGBoost") +
theme_minimal()
p_nb <- autoplot(nb_conf, type = "heatmap") +
scale_fill_gradient(low = "white", high = "darkred") +
ggtitle("Naive Bayes") +
theme_minimal()
p_xg + p_nb   # <-- side-by-side output
xg_metrics <- metrics(pred_xg, truth = class, estimate = .pred_class)
nb_metrics <- metrics(nb_pred_class, truth = class, estimate = .pred_class)
xg_metrics
nb_metrics
# XGBoost confusion matrix
xg_conf <- conf_mat(pred_xg, truth = class, estimate = .pred_class)
# Naive Bayes confusion matrix
nb_conf <- conf_mat(nb_pred_class, truth = class, estimate = .pred_class)
# Define the metrics you want
my_metrics <- metric_set(accuracy, sens, spec, yardstick::precision, f_meas)
# Compute metrics for each model
xg_metrics <- my_metrics(pred_xg, truth = class, estimate = .pred_class)
nb_metrics <- my_metrics(nb_pred_class, truth = class, estimate = .pred_class)
xg_metrics
nb_metrics
## ---- XGBOOST ----
xg_mat <- as.matrix(xg_conf$table)
nb_mat <- as.matrix(nb_conf$table)
xg_mat
nb_mat
rownames(xg_mat)
colnames(xg_mat)


# extract native xgboost model from parsnip fit
xgb_model <- adult_xg_fit$fit
# compute importance
xgb_imp <- xgb.importance(model = xgb_model)

# plot top 20 features
xgb.plot.importance(xgb_imp, top_n = 20, measure = "Gain")
# plot top 10 features
vip(xgb_model, num_features = 10, geom = "point")
