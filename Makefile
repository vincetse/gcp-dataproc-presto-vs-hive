# https://cloud.google.com/dataproc/docs/tutorials/presto-dataproc
SHELL = /bin/bash

bucket_name = gcp-dataproc-presto-v2
region = us-central1
zone = $(region)-a
project = forever-project

# cluster config
cluster_name = gcp-dataproc-presto
nworkers = 3
master_machine_type = e2-standard-2
worker_machine_type = e2-standard-2

################################################################################
opts = --project=$(project) --region=$(region) --zone=$(zone)
c6s = gcloud dataproc clusters
hive = gcloud dataproc jobs submit hive \
				--cluster $(cluster_name) \
				--region=$(region)
presto = presto \
				--server $(cluster_name)-m:8080 \
				--socks-proxy localhost:1080 \
				--catalog hive \
				--schema default

################################################################################
create:
	$(eval init_script := gs://goog-dataproc-initialization-actions-$(region)/presto/presto.sh)
	gsutil mb -l US -p $(project) gs://$(bucket_name)
	$(c6s) create $(cluster_name) \
		$(opts) \
		--master-machine-type=$(master_machine_type) \
		--worker-machine-type=$(worker_machine_type) \
		--num-workers=$(nworkers) \
		--scopes=cloud-platform \
		--initialization-actions=$(init_script)

delete:
	-$(c6s) delete $(cluster_name) \
		--project=$(project) --region=$(region) --quiet
	-gsutil rm -r gs://$(bucket_name)

tunnel:
	gcloud compute ssh $(cluster_name)-m \
		--project=$(project) --zone=$(zone) \
		-- -D 1080 -N -f

shell:
	$(presto)

steps: step01 step02 step03 step04 step05 step06

################################################################################
# The ugly parts

step01:
	bq --location=us extract --destination_format=CSV \
	 --field_delimiter=',' --print_header=false \
	 "bigquery-public-data:chicago_taxi_trips.taxi_trips" \
	 gs://$(bucket_name)/chicago_taxi_trips/csv/shard-*.csv

define step02_query
			CREATE EXTERNAL TABLE chicago_taxi_trips_csv(
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
				dropoff_location  STRING)
			ROW FORMAT DELIMITED
			FIELDS TERMINATED BY ','
			STORED AS TEXTFILE
			location 'gs://$(bucket_name)/chicago_taxi_trips/csv/';
endef
export step02_query
step02:
	$(hive) \
		--execute "$$step02_query"

step03:
	$(hive) \
		--execute "SELECT COUNT(*) FROM chicago_taxi_trips_csv;"

define step04_query
			CREATE EXTERNAL TABLE chicago_taxi_trips_parquet(
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
				dropoff_location  STRING)
			STORED AS PARQUET
			location 'gs://$(bucket_name)/chicago_taxi_trips/parquet/';
endef
export step04_query
step04:
	$(hive) \
		--execute "$$step04_query"

step05:
	$(hive) \
		--execute \
			"INSERT OVERWRITE TABLE chicago_taxi_trips_parquet SELECT * FROM chicago_taxi_trips_csv;"

step06:
	$(hive) \
		--execute "SELECT COUNT(*) FROM chicago_taxi_trips_parquet;"


################################################################################
query_csv = "SELECT COUNT(*) FROM chicago_taxi_trips_csv WHERE trip_miles > 50;"
query_parquet = "SELECT COUNT(*) FROM chicago_taxi_trips_parquet WHERE trip_miles > 50;"

benchmark_all: hive_csv hive_parquet presto_csv presto_parquet

hive_csv:
	@echo "################################################################################"
	@echo "Hive + CSV table.  Get the time elapsed on the '1 row selected' line"
	$(hive) \
		--execute $(query_csv)

hive_parquet:
	@echo "################################################################################"
	@echo "Hive + Parquet table.  Get the time elapsed on the '1 row selected' line"
	$(hive) \
	$(hive) \
		--execute $(query_parquet)

presto_csv:
	@echo "################################################################################"
	@echo "Presto + CSV table.  Time elapsed is the first number on the row with countts"
	echo $(query_csv) |$(presto)

presto_parquet:
	@echo "################################################################################"
	@echo "Presto + Parquet table.  Time elapsed is the first number on the row with countts"
	echo $(query_parquet) | $(presto)
