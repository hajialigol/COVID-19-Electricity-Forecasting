# Remove all items in environment
rm(list = ls())

# libraries
library(forecast)
library(MLmetrics)

# Get data cleaning functions
source("~/GitHub Projects/COVID-19-Electricity-Forecasting/Modeling/ARIMA/Data_Cleaning/Data_Cleaner.R")
source("~/GitHub Projects/COVID-19-Electricity-Forecasting/Modeling/ARIMA/Data_Cleaning/Training_Testing_Split.R")

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

# Pre-COVID Model ---------------------------------------------------------

# Convert output into time series object
pre_covid_ts_train <- ts(pre_covid_train$Real_Time_Hourly_Price, frequency = 365*24, start = c(2019, 1))
pre_covid_ts_test <- ts(pre_covid_test$Real_Time_Hourly_Price, frequency = 365*24, start = c(2019, 1))
covid_ts_train <- ts(covid_train$Real_Time_Hourly_Price, frequency = 365*24, start = c(2020, 3))
covid_ts_test <- ts(covid_test$Real_Time_Hourly_Price, frequency = 365*24, start = c(2020, 3))

# Create arima model
pre_covid_arima <- auto.arima(pre_covid_ts_train)

# Use pre-COVID model
pc_model_covid <- Arima(covid_ts_train, order = c(0, 1, 2))

# Forecast next day
pre_covid_forecast <- forecast(pre_covid_arima, h = 24*30*3)

# Forecast using pre-COVID model on COVID data
pc_forecast_covid <- forecast(pc_model_covid, h = 24*30*3)

# Plot the forecasts
plot(pre_covid_forecast, ylab = "Hourly Energy Price", xlab = 'Years',
     main = "Pre-COVID Model Forecast on Pre-COVID Data")
plot(pc_forecast_covid, ylab = "Hourly Energy Price", xlab = 'Years',
     main = "Pre-COVID Model Forecast on COVID Data")


# COVID Model -------------------------------------------------------------
covid_model <- auto.arima(covid_ts_train)

# Forecast following 3 months
covid_forecast <- forecast(covid_model, h = 24*30*3)

# Plot forecast
plot(covid_forecast, ylab = "Hourly Energy Price", xlab = 'Years',
     main = "COVID Model Forecast on COVID Data")


# Model Summaries ---------------------------------------------------------

# Pre-COVID model on pre-COVID training data 
accuracy(pre_covid_arima)

# Pre-COVID model on pre-COVID testing data
pre_covid_test_model <- Arima(pre_covid_ts_test, model = pre_covid_arima)
accuracy(pre_covid_test_model)

# Pre-COVID model on COVID training data
accuracy(pc_model_covid)

# Pre-COVID model on COVID testing data
pc_test_model <- Arima(covid_ts_test, model = pc_model_covid)
accuracy(pc_test_model)

# COVID model on COVID training data
accuracy(covid_model)

# COVID model on COVID testing data
covid_test_model <- Arima(covid_ts_test, model = covid_model)
accuracy(covid_test_model)
