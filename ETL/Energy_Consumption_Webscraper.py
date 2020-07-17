import pandas as pd
import requests
import datetime
import re
from bs4 import BeautifulSoup

# Url of energy consumption data from EIA
energy_consumption_url = "https://www.eia.gov/opendata/qb.php?sdid=EBA.PJM-ALL.D.H"

# Return consumption data wrapped around html tags
energy_consumption_content = requests.get(energy_consumption_url).content

# Convert data into BeautifulSoup object for data extraction
consumption_soup = BeautifulSoup(energy_consumption_content)

# Find body of data
body = consumption_soup.find("body")

# Find table tag
outer = body.div
outer = outer.find('section')
outer = outer.find('div', class_ = 'l-outer-wrapper')
outer = outer.find('div', class_ = 'l-inner-wrapper')
outer = outer.find('div', class_ = 'pagecontent mr_temp2')
main_col = outer.find('div', class_ = 'main_col')
table_tags = main_col.find('table', class_ = 'basic_table')

# Find columns
columns_html = table_tags.find('thead').find('tr')
column_names = columns_html.text.strip().split('\n')

# Find table data
table = table_tags.find('tbody')

# Add table data to list
observations = []
for record in table.find_all('tr'):
    # Remove newline characters left and right of string
    record = record.text.lstrip().rstrip()
    record = record.split('\n') 
    observations.append(record)
    
# Convert list to dataframe    
consumption_dataframe = pd.DataFrame(observations, columns = column_names)

# Current date
current_date = str(datetime.datetime.now())

# Save dataframe to specified directory
consumption_dataframe.to_excel("Energy_Consumption" + current_date)

# Current date
now = datetime.datetime.now()
year = str(now.year)
month = str(now.month)
day = str(now.day)
hour = str(now.hour)

# Create filename based on date
file_name = r'Energy_Consumption_on_" + month +  "/" + day + "/" + year + "_" + hour + ":00.csv'

# Save dataframe to specified directory
consumption_dataframe.to_csv(file_name)