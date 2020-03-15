# https://cloud.google.com/dataproc/docs/tutorials/presto-dataproc
SHELL = /bin/bash

################################################################################
# Define the configuration that determines the data set.  Use the set you want
# to test.
#include configs/chicago-taxi-trips.mk
#include configs/wikipedia-page-views-2020.mk
#include configs/new-york-citibike-trips.mk
include configs/samples-shakespeare.mk

################################################################################
# The GCP configs
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
# A bunch of aliases that probably should be fine for most
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
	gsutil mb -l $(region) -p $(project) gs://$(bucket_name)
	$(c6s) create $(cluster_name) \
		$(opts) \
		--master-machine-type=$(master_machine_type) \
		--master-boot-disk-type=pd-standard \
		--master-boot-disk-size=500GB \
		--worker-machine-type=$(worker_machine_type) \
		--worker-boot-disk-type=pd-standard \
		--worker-boot-disk-size=500GB \
		--num-workers=$(nworkers) \
		--scopes=cloud-platform \
		--initialization-actions=$(init_script)

delete:
	-$(c6s) delete $(cluster_name) \
		--project=$(project) --region=$(region) --quiet
	-gsutil -m rm -r gs://$(bucket_name)

tunnel:
	gcloud compute ssh $(cluster_name)-m \
		--project=$(project) --zone=$(zone) \
		-- -D 1080 -N -f

shell:
	$(presto)

steps: step01 step02 step03 step04

################################################################################
# The ugly parts

step01:
	-gsutil -m rm -r gs://$(bucket_name)/$(bucket_prefix)
	bq --location=us extract --destination_format=CSV \
		--field_delimiter=',' --print_header=false \
		"$(bigquery_data_set)" \
		gs://$(bucket_name)/$(bucket_prefix)/csv/shard-*.csv

define step02_query
			DROP TABLE IF EXISTS $(hive_csv_table_name);
			CREATE EXTERNAL TABLE $(hive_csv_table_name)(
				$(hive_table_schema)
			)
			ROW FORMAT DELIMITED
			FIELDS TERMINATED BY ','
			STORED AS TEXTFILE
			location 'gs://$(bucket_name)/$(bucket_prefix)/csv/';
endef
export step02_query
step02:
	$(hive) \
		--execute "$$step02_query"

define step04_query
			DROP TABLE IF EXISTS $(hive_parquet_table_name);
			CREATE EXTERNAL TABLE $(hive_parquet_table_name)(
				$(hive_table_schema)
			)
			STORED AS PARQUET
			location 'gs://$(bucket_name)/$(bucket_prefix)/parquet/';
endef
export step04_query
step03:
	$(hive) \
		--execute "$$step04_query"

step04:
	$(hive) \
		--execute \
			"INSERT OVERWRITE TABLE $(hive_parquet_table_name) SELECT * FROM $(hive_csv_table_name);"


################################################################################
query_csv = "SELECT COUNT(*) FROM wikipedia_page_views_csv WHERE views > 50;"
query_parquet = "SELECT COUNT(*) FROM wikipedia_page_views_parquet WHERE views > 50;"

benchmark_all: hive_csv hive_parquet presto_csv presto_parquet

hive_csv:
	@echo "################################################################################"
	@echo "Hive + CSV table.  Get the time elapsed on the '1 row selected' line"
	@echo "################################################################################"
	$(hive) \
		--execute $(csv_query)

hive_parquet:
	@echo "################################################################################"
	@echo "Hive + Parquet table.  Get the time elapsed on the '1 row selected' line"
	@echo "################################################################################"
	$(hive) \
		--execute $(parquet_query)

presto_csv:
	@echo "################################################################################"
	@echo "Presto + CSV table.  Time elapsed is the first number on the row with countts"
	@echo "################################################################################"
	echo $(csv_query) |$(presto)

presto_parquet:
	@echo "################################################################################"
	@echo "Presto + Parquet table.  Time elapsed is the first number on the row with countts"
	@echo "################################################################################"
	echo $(parquet_query) | $(presto)
