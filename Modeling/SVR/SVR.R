# Remove all items in environment
rm(list = ls())

# libraries
library(e1071)
library(Metrics)

# Get data cleaning functions
source("~/GitHub Projects/COVID-19-Electricity-Forecasting/Modeling/Data_Cleaning/Data_Cleaner.R")
source("~/GitHub Projects/COVID-19-Electricity-Forecasting/Modeling/Data_Cleaning/Training_Testing_Split.R")

# Initialize data directory
data_directory <- ""

# Get cleaned data
dfs <- data_cleaner(data_directory, remove = 'yes')
pre_covid <- dfs$`pre-covid`
covid <- dfs$`covid`

# Generate training and testing data
train_test_list <- train_test_split(pre_covid_df = pre_covid, covid_df = covid, split_ratio = 0.75)
pre_covid_train <- train_test_list$pre_covid_train
pre_covid_test <- train_test_list$pre_covid_test
covid_train <- train_test_list$covid_train
covid_test <- train_test_list$covid_test


# Modeling ---------------------------------------------------------


# Create regression formula
formula <- Real_Time_Hourly_Price ~ (Hour_Number + Demand_Forecast + Demand_Adjusted + Net_Generation_Adjusted
                                     + Energy_Consumption)

# Create model on pre-COVID data
pc_svm_pc_data <- tune(svm, formula, data = pre_covid_train)
best_pc_svm <- pc_svm_pc_data$best.mode

# Create model on COVID data
covid_svm <- tune(svm, formula, data = covid_train)
best_covid_svm <- covid_svm$best.model


# Fitting Models ----------------------------------------------------------


# Fit pre-COVID model on pre-COVID data
pc_pc_predictions <- predict(best_pc_svm, pre_covid_test)
pc_pc_rmse <- rmse(actual = pre_covid_test$Real_Time_Hourly_Price, predicted = pc_pc_predictions)
pc_pc_mape <- mape(actual = pre_covid_test$Real_Time_Hourly_Price, predicted = pc_pc_predictions)

# Fit pre-COVID model on COVID data
pc_covid_predictions <- predict(best_pc_svm, covid_test)
pc_covid_rmse <- rmse(actual = covid_test$Real_Time_Hourly_Price, predicted = pc_covid_predictions)
pc_covid_mape <- mape(actual = covid_test$Real_Time_Hourly_Price, predicted = pc_covid_predictions)

# Fit COVID model on COVID data
covid_predictions <- predict(best_covid_svm, covid_test)
covid_rmse <- rmse(actual = covid_test$Real_Time_Hourly_Price, predicted = covid_predictions)
covid_mape <- mape(actual = covid_test$Real_Time_Hourly_Price, predicted = covid_predictions)
