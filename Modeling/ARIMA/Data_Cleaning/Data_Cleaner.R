# libraries
require(dplyr)

# Desc:
  # This function returns two cleaned data sets for the "FINAL_PJM_DATA.xlsx" file.
# Inpt:
  # data_directory [str]: String representing full path to the aforementioned file.
  # file_name [str]: Name of the file.
  # covid-date [str]: String representing the date to split the cleaned data into.
# Oupt:
  # df_list [list]: List of cleaned data frames before and after COVID-19.
data_cleaner <- function(data_directory, file_name = "FINAL_PJM_DATA.xlsx",
                         covid_date = "2020-03-11", beginning_date = "2019-01-01",
                         remove = 'no'){
  
  # Set working directory to data directory
  setwd(data_directory)
  
  # Read data
  pjm_data <- readxl::read_xlsx(file_name)
  
  # Drop null columns
  cleaned_df <- within(pjm_data, rm("Net Generation (MW) (Imputed)",
                                    "Demand (MW) (Imputed)", "...15", "...16"))
  
  # Rename columns
  cleaned_df <- cleaned_df %>%
    rename(Day_Ahead_Hourly_Price = "Day-Ahead Hourly Price(kWh)",
           Real_Time_Hourly_Price = "Real-Time Hourly Price(kWh)",
           Data_Date = "Data Date", Hour_Number = "Hour Number",
           Demand_Forecast = "Demand Forecast (MW)", Demand_MW = "Demand (MW)",
           Net_Generation = "Net Generation (MW)", Total_Interchange = "Total Interchange (MW)",
           Sum_Valid_DIBAs = "Sum(Valid DIBAs) (MW)", Demand_Adjusted = "Demand (MW) (Adjusted)",
           Net_Generation_Adjusted = "Net Generation (MW) (Adjusted)",
           Energy_Consumption = "Energy Consumption (megawatthours)")
  
  # Change type of pricing and date columns
  cleaned_df$Day_Ahead_Hourly_Price <- as.numeric(gsub("¢", "", cleaned_df$Day_Ahead_Hourly_Price))
  cleaned_df$Real_Time_Hourly_Price <- as.numeric(gsub("¢", "", cleaned_df$Real_Time_Hourly_Price))
  cleaned_df$Data_Date <- as.Date(cleaned_df$Data_Date)
  
  # Add a year column
  cleaned_df$Year <- format(cleaned_df$Data_Date, "%Y")
  
  # Remove non-zero prices if the user desires
  if (tolower(remove) == 'yes'){
    cleaned_df <- cleaned_df %>%
      filter(Real_Time_Hourly_Price != 0)
  }
  
  # Separate data based on start date and COVID date
  pre_covid_df <- cleaned_df %>%
    filter(Data_Date >= beginning_date, Data_Date < covid_date)
  
  # Separate data based on COVID cutoff date
  covid_df <- cleaned_df %>%
    filter(Data_Date >= covid_date)
  
  # Create list of data frames with given names
  df_list <- list("pre-covid" = pre_covid_df, "covid" = covid_df)
  
  # Return data frames
  return(df_list)

  }
