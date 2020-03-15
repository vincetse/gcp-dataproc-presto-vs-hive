# Input data set from Biquery
# https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=new_york_citibike&t=citibike_trips&page=table
bigquery_data_set = bigquery-public-data:new_york_citibike.citibike_trips

# The prefix for the data set in Google Storage
# You should use an unique prefix for each data set
bucket_prefix = new_york_citibike_trips

# Hive table name for CSV table
hive_csv_table_name = $(bucket_prefix)_csv

# Hive table name for Parquet table
hive_parquet_table_name = $(bucket_prefix)_parquet

# The Hive table schema for the data set
define hive_table_schema
				tripduration							INTEGER,
				starttime									TIMESTAMP,
				stoptime									TIMESTAMP,
				start_station_id					INTEGER,
				start_station_name				STRING,
				start_station_latitude		FLOAT,
				start_station_longtitude	FLOAT,
				stop_station_id						INTEGER,
				stop_station_name					STRING,
				stop_station_latitude			FLOAT,
				stop_station_longtitude		FLOAT,
				bikeid										INTEGER,
				usertype									STRING,
				birth_year								INTEGER,
				gender										STRING,
				customer_plan							STRING
endef

# The query for the CSV table
csv_query = "SELECT COUNT(*) FROM $(hive_csv_table_name) WHERE tripduration > 20;"

# The query for the Parquet table
parquet_query = "SELECT COUNT(*) FROM $(hive_parquet_table_name) WHERE tripduration > 20;"
