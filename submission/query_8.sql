-- ## Reduced Host Fact Array Implementation (`query_8.sql`)

-- As shown in fact data modeling day 3 lab, write a query to incrementally populate the `host_activity_reduced` table from a `daily_web_metrics` table. 
-- Assume `daily_web_metrics` exists in your query. Don't worry about handling the overwrites or deletes for overlapping data.

-- Remember to leverage a full outer join, and to properly handle imputing empty values in the array for windows where a host gets a visit in the middle of the array time window.

insert into shababali.host_activity_reduced
with
    --prev loaded data
    yesterday as (
        select * from shababali.host_activity_reduced where month_start = '2022-05-01'
    ),
    --new data
    today as (
        select * from shababali.daily_web_metrics where date = DATE('2022-05-03')
    )
    --append metric_value (possibly null) to metric_array if it exists, 
    -- if not exists, then append nulls equal to the number of days passed, and append new metric_value
select
    COALESCE(t.host, y.host) AS host,
    COALESCE(t.metric_name, y.metric_name) AS metric_name,
    CONCAT(
        COALESCE(
            y.metric_array,
            REPEAT(
                null,
                CAST(DATE_DIFF('day', DATE('2023-08-01'), t.date) as integer)
            )
        ),
        ARRAY[t.metric_value]
    ) as metric_array,
    '2023-08-01' as month_start
from today t full outer join yesterday y 
    on t.host = y.host and t.metric_name = y.metric_name
