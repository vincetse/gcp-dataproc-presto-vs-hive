# Input data set from Biquery
# https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=chicago_taxi_trips&t=taxi_trips&page=table
bigquery_data_set = bigquery-public-data:chicago_taxi_trips.taxi_trips

# The prefix for the data set in Google Storage
# You should use an unique prefix for each data set
bucket_prefix = chicago_taxi_trips

# Hive table name for CSV table
hive_csv_table_name = $(bucket_prefix)_csv

# Hive table name for Parquet table
hive_parquet_table_name = $(bucket_prefix)_parquet

# The Hive table schema for the data set
define hive_table_schema
				unique_key   STRING,
				taxi_id  STRING,
				trip_start_timestamp  TIMESTAMP,
				trip_end_timestamp  TIMESTAMP,
				trip_seconds  INT,
				trip_miles   FLOAT,
				pickup_census_tract  INT,
				dropoff_census_tract  INT,
				pickup_community_area  INT,
				dropoff_community_area  INT,
				fare  FLOAT,
				tips  FLOAT,
				tolls  FLOAT,
				extras  FLOAT,
				trip_total  FLOAT,
				payment_type  STRING,
				company  STRING,
				pickup_latitude  FLOAT,
				pickup_longitude  FLOAT,
				pickup_location  STRING,
				dropoff_latitude  FLOAT,
				dropoff_longitude  FLOAT,
				dropoff_location  STRING
endef

# The query for the CSV table
csv_query = "SELECT COUNT(*) FROM $(hive_csv_table_name) WHERE trip_miles > 50;"

# The query for the Parquet table
parquet_query = "SELECT COUNT(*) FROM $(hive_parquet_table_name) WHERE trip_miles > 50;"
