# Input data set from Biquery
# https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=wikipedia&t=pageviews_2020&page=table
bigquery_data_set = bigquery-public-data:wikipedia.pageviews_2020

# The prefix for the data set in Google Storage
# You should use an unique prefix for each data set
bucket_prefix = wikipedia_pageviews

# Hive table name for CSV table
hive_csv_table_name = $(bucket_prefix)_csv

# Hive table name for Parquet table
hive_parquet_table_name = $(bucket_prefix)_parquet

# The Hive table schema for the data set
define hive_table_schema
				datehour	TIMESTAMP,
				wiki	STRING,
				title	STRING,
				views	INT
endef

# The query for the CSV table
csv_query = "SELECT COUNT(*) FROM $(hive_csv_table_name) WHERE views > 50;"

# The query for the Parquet table
parquet_query = "SELECT COUNT(*) FROM $(hive_parquet_table_name) WHERE views > 50;"
