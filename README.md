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

| Data Format | Query | Hive | Presto |
|-------------|-------|------|--------|
| CSV | `SELECT COUNT(*) FROM chicago_taxi_trips_csv WHERE trip_miles > 50;` | 188.878s | 159s |
| Parquet | `SELECT COUNT(*) FROM chicago_taxi_trips_parquet WHERE trip_miles > 50;` | 54.511s | 8s |

## References

1. https://cloud.google.com/dataproc/docs/tutorials/presto-dataproc
