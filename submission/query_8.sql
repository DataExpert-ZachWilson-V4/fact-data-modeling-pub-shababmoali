-- ## Reduced Host Fact Array Implementation (`query_8.sql`)

-- As shown in fact data modeling day 3 lab, write a query to incrementally populate the `host_activity_reduced` table from a `daily_web_metrics` table. 
-- Assume `daily_web_metrics` exists in your query. Don't worry about handling the overwrites or deletes for overlapping data.

-- Remember to leverage a full outer join, and to properly handle imputing empty values in the array for windows where a host gets a visit in the middle of the array time window.


-- create or replace table shabab.daily_web_metrics (
--     host varchar,
--     metric_name varchar,
--     user_id integer,
--     metric_value integer,
--     date date
-- )
-- with(
--     format = 'PARQUET',
--     partitioning = array['date']
--     )


-- insert into shabab.daily_web_metrics
-- select
--     host,
--     'visited_signup' AS metric_name,
--     user_id,
--     COUNT(
--         case
--             when url = '/signup' then 1 else NULL
--         end
--         ) as metric_value,
--     CAST(event_time as DATE) as DATE
-- from bootcamp.web_events
-- group by host, user_id, CAST(event_time as DATE)


insert into shabab.host_activity_reduced
with
    --prev loaded data
    yesterday as (
        select * from shabab.host_activity_reduced where month_start = '2023-08-01'
    ),
    --new data
    today as (
        select * from shabab.daily_web_metrics where date = DATE('2023-08-03')
    )
    --append metric_value (possibly null) to metric_array if it exists,
    -- if not exists, then append nulls equal to the number of days passed, and append new metric_value
select
    COALESCE(y.host, t.host) as host,
    COALESCE(y.metric_name, t.metric_name) AS metric_name,
    CONCAT(
        COALESCE(
            y.metric_array,
            REPEAT(
                NULL,
                CAST(DATE_DIFF('day', DATE('2023-08-01'), t.date) as integer)
            )
        ),
        array[t.metric_value]
    ) as metric_array,
    '2023-08-01' as month_start
from yesterday y full outer join today t
    on y.host = t.host and y.metric_name = t.metric_name
