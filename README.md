# GCP Dataproc + Presto vs Hive

Trying out Dataproc+Presto, and comparing performance between Hive using CSV and [Parquet](https://parquet.apache.org/) formats.

## Usage

```
# Create the GCP resources
make create

# Set up the data
make steps

# Create tunnel for Presto
make tunnel

# Run the ghetto benchmarking, and look for the time measurements
make benchmark_all

# Delete the GCP resources when you are done
make delete
```

## Configurations

There are 4 configuration files in the [`configs`](configs) directory right now.  The configurations are pretty self-explanatory, so I am going to let the user take a shot at adding more data sets from the [Google Cloud Platform Marketplace](https://console.cloud.google.com/marketplace/browse?filter=solution-type:dataset).


## Non-scientific Single-run Measurements

This set of tests was created to get a ballpark performance comparison between Apache Hive and Presto on Google Dataproc using publicly-available data sets on Google BigQuery.  The time measures are what's returned by Hive and Presto using 3 `e2-standard-2` worker nodes and a single `e2-standard-2` master node, each with only 500GB of `pd-standard` storage.  The numbers are collected with a single run each, and validated that they are in the right ballpark with additional runs.  However, single-run numbers are being reported here cos it serves my purpose of getting relative performance numbers.

### Shakespeare Word Count Sample

This test uses the [sample Shakespeare word count](https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=samples&t=shakespeare&page=table) data set on Google BigQuery with the following metadata.

**Table Info**

| Spec                   | Value                                    |
|------------------------|------------------------------------------|
| Table ID               | bigquery-public-data:samples.shakespeare |
| Table size             | 6.13 MB                                  |
| Long-term storage size | 6.13 MB                                  |
| Number of rows         | 164,656                                  |
| Created                | Mar 14, 2016, 1:16:45 PM                 |
| Table expiration       | Never                                    |
| Last modified          | Mar 14, 2016, 1:16:45 PM                 |
| Data location          | US                                       |

**Query Times**

| Data Format | Query                                                                    | Hive    | Presto |
|-------------|--------------------------------------------------------------------------|---------|--------|
| CSV         | `SELECT COUNT(*) FROM samples_shakespeare_csv WHERE word_count > 50;`    | 17.855s | 1s     |
| Parquet     | `SELECT COUNT(*) FROM samples_shakespeare_parque WHERE word_count > 50;` | 18.724s | 1s     |


### New York Citibike Trips

This test uses the [New York Citibike Trips](https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=new_york_citibike&t=citibike_trips&page=table) available on Google BigQuery.  The following is its metadata.

**Table Info**

| Spec                   | Value                                                    |
|------------------------|----------------------------------------------------------|
| Table ID               | bigquery-public-data:new\_york\_citibike.citibike\_trips |
| Table size             | 7.47 GB                                                  |
| Long-term storage size | 7.47 GB                                                  |
| Number of rows         | 58,937,715                                               |
| Created                | Apr 12, 2017, 3:40:35 PM                                 |
| Table expiration       | Never                                                    |
| Last modified          | Sep 10, 2018, 9:29:21 PM                                 |
| Data location          | US                                                       |

**Query Times**

| Data Format | Query                                                                    | Hive     | Presto |
|-------------|--------------------------------------------------------------------------|----------|--------|
| CSV | `SELECT COUNT(*) FROM new_york_citibike_trips_csv WHERE tripduration > 20;` | 55.148s | 28s |
| Parquet | `SELECT COUNT(*) FROM new_york_citibike_trips_parquet WHERE tripduration > 20;` | 36.672s | 4s |


### Chicago Taxi Trips

This test uses the [Chicago Taxi Trips](https://console.cloud.google.com/marketplace/details/city-of-chicago-public-data/chicago-taxi-trips) available on Google BigQuery.  The following is the metadata for the data when this was run.

**Table Info**

| Spec             | Value                                                 |
|------------------|-------------------------------------------------------|
| Table ID         | bigquery-public-data:chicago\_taxi\_trips.taxi\_trips |
| Table size       | 69.58 GB                                              |
| Number of rows   | 192,029,239                                           |
| Created          | Apr 12, 2017, 3:35:35 PM                              |
| Table expiration | Never                                                 |
| Last modified    | Feb 6, 2020, 8:18:21 AM                               |
| Data location    | US                                                    |

**Query Times**

| Data Format | Query                                                                    | Hive     | Presto |
|-------------|--------------------------------------------------------------------------|----------|--------|
| CSV         | `SELECT COUNT(*) FROM chicago_taxi_trips_csv WHERE trip_miles > 50;`     | 188.878s | 159s   |
| Parquet     | `SELECT COUNT(*) FROM chicago_taxi_trips_parquet WHERE trip_miles > 50;` | 54.511s  | 8s     |


### Wikipedia Page Views

This test uses the [2020 Wikipedia Page Views](https://console.cloud.google.com/bigquery?p=bigquery-public-data&d=wikipedia&t=pageviews_2020&page=table) available on Google BigQuery, and the data set is as described by the metadata below.

**Table Info**

| Spec                 | Value                                          |
|----------------------|------------------------------------------------|
| Table ID             | bigquery-public-data:wikipedia.pageviews\_2020 |
| Table size           | 493.72 GB                                      |
| Number of rows       | 11,896,520,810                                 |
| Created              | Jan 21, 2020, 4:57:35 PM                       |
| Table expiration     | Never                                          |
| Last modified        | Mar 15, 2020, 10:01:35 AM                      |
| Data location        | US                                             |
| Table type           | Partitioned                                    |
| Partitioned by       | Day                                            |
| Partitioned on field | datehour                                       |
| Partition filter     | Required                                       |
| Clustered by         | wiki, title                                    |

**Query Times**

| Data Format | Query                                                                 | Hive     | Presto |
|-------------|-----------------------------------------------------------------------|----------|--------|
| CSV         | `SELECT COUNT(*) FROM wikipedia_page_views_csv WHERE views > 50;`     | 2243.669 | 1825s  |
| Parquet     | `SELECT COUNT(*) FROM wikipedia_page_views_parquet WHERE views > 50;` | 722.234s | 206s   |


References
----------

1.	https://cloud.google.com/dataproc/docs/tutorials/presto-dataproc
