import requests
import datetime
import re
import ast
import pandas as pd
from bs4 import BeautifulSoup

# Get url of electricity prices
electricity_price_url = "https://hourlypricing.comed.com/api?type=5minutefeed&datestart=202003010100&dateend=202007020100"

# Request electricity price data
electricity_price_dict = requests.get(electricity_price_url).content

# Convert electricity price data from bytes to a dictionary
electricity_dict = ast.literal_eval(electricity_price_dict.decode("utf-8"))

# Extract data every five minutes
data = [list(five_minutes.values()) for five_minutes in electricity_dict]

# Create column names
columns = ['millisUTC', 'price']

# Create dataframe
price_df = pd.DataFrame(data, columns=columns)

# Convert columns to numeric type
price_df ['price'] = pd.to_numeric(price_df['price'])
price_df ['millisUTC'] = pd.to_numeric(price_df['millisUTC'])

# Convert milliseconds to date time
price_df['Datetime'] = price_df['millisUTC'].apply(lambda x: datetime.datetime.fromtimestamp(x/1000.0))

# Set index to be date time
price_df.set_index("Datetime", inplace=True)

# Drop milliseconds columns
price_df.drop(['millisUTC'], axis = 1, inplace=True)

# Save dataframe
file_name = 'Testing'
price_df.to_csv(file_name)