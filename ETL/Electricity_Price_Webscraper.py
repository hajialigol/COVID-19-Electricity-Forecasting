import requests
import re
import ast
import pandas as pd
from bs4 import BeautifulSoup

# Get url of electricity prices
electricity_price_url = "https://hourlypricing.comed.com/api?type=5minutefeed&datestart=202007010100&dateend=202007020100"

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