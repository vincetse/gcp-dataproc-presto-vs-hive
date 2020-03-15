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

## Non-scientific Single-run Measurements

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

This test uses the [2020 Wikipedia Page Views](https://console.cloud.google.com/bigquery?project=forever-project&folder&organizationId=530642503887&p=bigquery-public-data&d=wikipedia&t=pageviews_2020&page=table) available on Google BigQuery, and the data set is as described by the metadata below.

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
