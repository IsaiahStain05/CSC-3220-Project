# Predicting Income Class from Census Data

## Authors  

*Isaiah Chastain, Derek Nelson, Lucas Dowlen, Ryan Naleway, and Dylan Smith*

## Report  

### **1. Problem Statement and Background**  

In this project, we will be analyzing census data from the 1994 United States Census found online in the UCI Machine Learning Repository.  The purpose of this analysis is to determine if a person’s income class may be predicted based off other factors shown in the dataset. The models built from our analysis will be tested on pre-partitioned test data and evaluated by their AUC and F1 scores (more on this in the “Results” section).  This question is important to banks, Congress, or the IRS.  Banks could use this model to predict if somebody is a good candidate for a credit line.  Congress could use this model to consider changes to the tax brackets based on predicted population income class percentages. The IRS could use this model to help conduct audits.  
*Authors: Isaiah Chastain (50%), Dylan Smith (50%)*  

### **2. Data and Exploratory Analysis**  

The dataset we have been given has the following columns:  
| Column Name    | Description |
| -----------    | ----------- |
| age            | Age of the people described in this row |
| workclass      | Their employment status/employer|
| fnlwgt         | The sampling weight – how many people are represented by the other statistics described in this row |
| education      | Education level of the people described in this row |
| education-num  | A numerical representation of this row’s education level |
| marital-status | Marital status and if their spouse is in the military |
| occupation     | What they do for work |
| relationship   | What are they in their family (in relation to the head of the household) |
| race           | What race are they |
| sex            | What is their sex |
| capital-gain   | Monetary gain through sale of assets |
| capital-loss   | Monetary loss through sale of assets |
| hours-per-week | How many hours worked in a week |
| native-country | What country are they from |
| class          | Whether the people described by this row make less than or equal to $50K annually, or more than $50K annually |  

One important thing to note is that in the original dataset, the NA values were not filled with NA, they were filled with “ ?”. Our first step was to convert these question marks into NA’s using lapply and an ifelse branch. Secondly, we realized that all of our NA values were in columns that contained categorical values, not numerical. For this reason, and the fact that our dataset is very large, we chose to simply drop the rows containing NA values instead of imputing data into them. This left us with 30,161 of our original 32,560 entries.  The only data that we generated was our class column - instead of having the char datatype categories “<= $50K” and “>$50K”, we converted these values to FALSE and TRUE logical values respectively. This dataset has many outliers, however, for the most part these outliers are not errors – they are valid entries in which the people genuinely just made far more than the general population.  We cannot get rid of these entries, as it would skew the data incorrectly.  This dataset does seem to max out at $99,999 for values that may possibly be greater than $99,999 in the “capital-gain” column. After cleaning our data, we created a correlation matrix to see which factors tended to affect the probability an instance being “class = TRUE” (the person represented by the data makes more than $50K a year). We found that the three most impactful coefficient correlations were: marital-status = Married-civ-spouse (+0.445), marital-status = Never-married (-0.32), and relationship = Own-child (-0.226).
Here is the full correlation graph:  
  
<img src="Graphs/hard_to_read.png" width="800" height="800">  
  
As these legends are too small to read, here is a graph of the 10 most positive and 10 most negative correlations:   
  
<img src="Graphs/top_correlations.png" width="800" height="800">  
  
*Authors: Isaiah Chastain (25%), Dylan Smith (25%), Lucas Dowlen (25%), Ryan Naleway (25%)*   

### **3. Methods**  

Our initial step in tackling this problem is data cleaning – as mentioned before, we had to convert the “ ?” entries to NA’s and then drop the rows containing those NA’s. After cleaning our data, we converted our “class” column from a char datatype to a logical datatype. We also created correlation coefficients that determined the weight and direction of a variable’s influence on whether the person described by that variable would make over $50K.  As our machine learning model needs to do a classification task, we considered using a logistic model, a random forest model, a naïve bayes model, or an XGBoost model. All of these models did work, however, by evaluating accuracy, precision, and AUC, we discovered that some were more proficient than others at predicting the income class. Individual model performance will be discussed in the Results section.  
*Authors: Isaiah Chastain (20%), Derek Nelson (20%), Dylan Smith (20%), Lucas Dowlen (20%), Ryan Naleway (20%)*  

### **4. Tools**  
For our project, since this is a classification issue, we must use a machine learning model.  We used the following libraries: ggplot2 for visualization and tidymodels, dplyr, randomForest, xgboost, discrim, naivebayes for machine learning model integration and experimentation. The general process we used for integrating a model is as such:  
1.	Split training and testing data with initial_split()
2.	Define the model with its parameters
3.	Define a recipe (recipe <- recipe(class ~ ., adults) for all models)
4.	Define a workflow and add the recipe and model (workflow() |> add_recipe() |> add_model)
5.	Fit the model to our training data
6.	Predict the outcome of the model on our testing data  
  
Once we predicted the outcomes, we bound the columns of our testing data to our predicted outcome data frame for easier metric calculations (predict(fitted_model, new_data = test) |> bind_cols(test)). From this point, we began testing our individual models to see which one performed the best.  
*Authors: Isaiah Chastain (20%), Derek Nelson (20%), Dylan Smith (20%), Lucas Dowlen (20%), Ryan Naleway (20%)*  
### **5. Results**  
### **6. Summary and Conclusions**  
### **7. Appendix**  

Dataset: [UCI Adults Dataset](https://archive.ics.uci.edu/dataset/2/adult)  
Github Repo: [Project Repo](https://github.com/IsaiahStain05/CSC-3220-Project.git)  
Documentation:  
•	Ggplot2: [ggplot2 Documentation](https://cran.r-project.org/web/packages/ggplot2/ggplot2.pdf)  
•	Tidymodels: [tidymodels Documentation](https://cran.r-project.org/web/packages/tidymodels/tidymodels.pdf)  
•	Dplyr: [dplyr Documentation](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html)  
•	randomForest: [randomForest Documentation](https://cran.r-project.org/web/packages/randomForest/randomForest.pdf)  
•	xgboost: [xgboost Documentation](https://cran.r-project.org/web/packages/xgboost/xgboost.pdf)  
•	discrim: [discrim Documentation](https://cran.r-project.org/web/packages/discrim/discrim.pdf)  
•	naivebayes: [naivebayes Documentation](https://cran.r-project.org/web/packages/naivebayes/naivebayes.pdf)  

*Author: Isaiah Chastain (100%)*
