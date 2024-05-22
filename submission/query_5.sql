-- ## Host Activity Datelist DDL (`query_5.sql`)

-- Write a DDL statement to create a `hosts_cumulated` table, as shown in the fact data modeling day 2 lab. 
-- Except for in the homework, you'll be doing it by `host`, not `user_id`.

-- The schema for this table should include:

-- - `host varchar`
-- - `host_activity_datelist array(date)`
-- - `date date`
create or replace table shababali.hosts_cumulated (
    host varchar,
    host_activity_datelist array(date),
    date date
)
with(
    format = 'PARQUET',
    partitioning = array['date']
    )
