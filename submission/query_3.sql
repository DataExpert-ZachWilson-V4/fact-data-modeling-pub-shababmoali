-- ## User Devices Activity Datelist Implementation (`query_3.sql`)

-- Write the incremental query to populate the table you wrote the DDL for in the above question from the `web_events` and `devices` tables. 
-- This should look like the query to generate the cumulation table from the fact modeling day 2 lab.
insert into shababali.user_devices_cumulated
with
    -- prev cumulated data
    yesterday as (
        select * from shababali.user_devices_cumulated where date = DATE('2024-05-19')
    ),
    -- number of web events for new data by user_id and browser type
    today as (
        select
            web_e.user_id,
            d.browser_type,
            CAST(date_trunc('day', web_e.event_time) as DATE) as event_date,
            COUNT(1)
        from bootcamp.web_events as web_e left join bootcamp.devices as d
            on d.device_id = web_e.device_id
        where date_trunc('day', web_e.event_time) = DATE('2024-05-20')
        group by
            web_e.user_id,
            d.browser_type,
            CAST(date_trunc('day', web_e.event_time) as DATE)
    )
--append date if dates_active exists, else create single-item array with date
select
    COALESCE(y.user_id, t.user_id) as user_id,
    COALESCE(y.browser_type, t.browser_type) as browser_type,
    case
        when y.dates_active is not NULL
            then CONCAT(array[t.event_date], y.dates_active)
        else
            array[t.event_date]
    end as dates_active,
    DATE('2024-05-20') as date
from yesterday as y full outer join today as t 
    on y.user_id = t.user_id and y.browser_type = t.browser_type
