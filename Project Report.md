# Predicting Income Class from Census Data

## Authors  

*Isaiah Chastain, Derek Nelson, Lucas Dowlen, Ryan Naleway, and Dylan Smith*

## Report  

### **1. Problem Statement and Background**  

In this project, we will be analyzing census data from the 1994 United States Census found online in the UCI Machine Learning Repository.  The purpose of this analysis is to determine if a person’s income class may be predicted based off other factors shown in the dataset. The models built from our analysis will be tested on pre-partitioned test data from the same dataset to get a measure of accuracy (more on this in the “Results” section).  
*Authors: Isaiah Chastain (50%), Dylan Smith (50%)*  

### **2. Data and Exploratory Analysis**  

The dataset we have been given has the following columns:  age, workclass (their employment status/employer), fnlwgt (the sampling weight – how many people are represented by the other statistics described in the row of this instance), education, education-num (a numerical representation of this instance’s education level), marital-status, occupation, relationship, race, sex, capital-gain (monetary gain through sale of assets), capital-loss (monetary loss through sale of assets), hours-per-week (worked), native-country, and class (whether the person(s) described by this row makes less than or equal to $50K annually, or more than $50K annually). One important thing to note is that in the original dataset, the NA values were not filled with NA, they were filled with “ ?”. Our first step was to convert these question marks into NA’s using lapply and an ifelse branch. Secondly, we realized that all of our NA values were in columns that contained categorical values, not numerical. For this reason, and the fact that our dataset is very large, we chose to simply drop the NA values instead of imputing data into them.  The only data that we generated (or transformed, more so), was our class column. Instead of having the char datatype categories “<= $50K” and “>$50K”, we converted these values to FALSE and TRUE logical values respectively. This dataset has many outliers, however, for the most part these outliers are not errors – they are simply natural outcomes of capitalism.  This dataset does seem to max out at $99,999 for values that may possibly be greater than $99,999 in the “capital-gain” column.  
*Authors: Isaiah Chastain (50%), Dylan Smith (50%)*  

### **3. Appendix**  

Dataset: [UCI Adults Dataset](https://archive.ics.uci.edu/dataset/2/adult)  
Github Repo: [Project Repo](https://github.com/IsaiahStain05/CSC-3220-Project.git)
