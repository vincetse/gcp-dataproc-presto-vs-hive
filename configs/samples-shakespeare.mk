# Input data set from Biquery
# https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=samples&t=shakespeare&page=table
bigquery_data_set = bigquery-public-data:samples.shakespeare

# The prefix for the data set in Google Storage
# You should use an unique prefix for each data set
bucket_prefix = samples_shakespeare

# Hive table name for CSV table
hive_csv_table_name = $(bucket_prefix)_csv

# Hive table name for Parquet table
hive_parquet_table_name = $(bucket_prefix)_parquet

# The Hive table schema for the data set
define hive_table_schema
				word				STRING,
				word_count	INTEGER,
				corpus			STRING,
				corpus_date	INTEGER
endef

# The query for the CSV table
csv_query = "SELECT COUNT(*) FROM $(hive_csv_table_name) WHERE word_count > 50;"

# The query for the Parquet table
parquet_query = "SELECT COUNT(*) FROM $(hive_parquet_table_name) WHERE word_count > 50;"
