-- ## Reduced Host Fact Array DDL (`query_7.sql`)

-- As shown in the fact data modeling day 3 lab, write a DDL statement to create a monthly `host_activity_reduced` table, containing the following fields:

-- - `host varchar`
-- - `metric_name varchar`
-- - `metric_array array(integer)`
-- - `month_start varchar`

create or replace table shababali.host_activity_reduced (
    host varchar,
    metric_name varchar,
    metric_array array(integer),
    month_start varchar
)
with(
    format = 'PARQUET',
    partitioning = array['month_start']
    )
