# libraries
require(caTools)

# Desc:
  # This function generates training and testing sets for given data frames.
# Inpt:
  # df1 [df]: First data frame to generate training and testing sets from.
  # df2 [df]: Second data frame to generate training and testing sets from.
  # split_ratio [double]: Ratio representing percent of data to keep in training set.
# Oupt:
  # df_list [list]: list of training and testing sets for both data frames.
train_test_split <- function(pre_covid_df, covid_df, split_ratio = 0.75){

  # Generate logical vectors to determine for randomly splitting data frame
  pre_covid_sample <- caTools::sample.split(pre_covid_df, SplitRatio = split_ratio)
  covid_sample <- caTools::sample.split(covid_df, SplitRatio = split_ratio)
  
  # Create training sets
  pre_covid_train <- subset(pre_covid_df, pre_covid_sample == TRUE)
  covid_train <- subset(covid_df, covid_sample == TRUE)
  
  # Create testing sets
  pre_covid_test <- subset(pre_covid_df, pre_covid_sample == FALSE)
  covid_test <- subset(covid_df, covid_sample == FALSE)
  
  # Generate list to return appropriate data
  train_test_list <- list("pre_covid_train" = pre_covid_train, "covid_train" = covid_train,
                          "pre_covid_test" = pre_covid_test, "covid_test" = covid_test)
  
  # Return list of data frames
  return(train_test_list)
  
}