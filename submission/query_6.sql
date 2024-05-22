-- ## Host Activity Datelist Implementation (`query_6.sql`)

-- As shown in the fact data modeling day 2 lab, Write a query to incrementally populate the `hosts_cumulated` table from the `web_events` table.

insert into shabab.hosts_cumulated
-- prev CTE from `hosts_cumulated`
with yesterday as (
    select * from shabab.hosts_cumulated where date = DATE('2022-05-01')
),
-- curr CTE from `bootcamp.web_events` 
today as (
    select 
        host,
        CAST(date_trunc('day', event_time) as DATE) AS event_date, 
        COUNT(1)
    from bootcamp.web_events
    where CAST(date_trunc('day', event_time) as DATE) = DATE('2022-05-02')
    group by host, CAST(date_trunc('day', event_time) as DATE)
)
select
    COALESCE(t.host, y.host) as host,
    --append host_activity_datelist if it exists, else create single-item array with date
    case
        when y.host_activity_datelist is not NULL 
            then array[t.event_date] || y.host_activity_datelist
        else
            array[t.event_date]
    end as host_activity_datelist,
    DATE('2021-05-02') as date
from today t full outer join yesterday y 
    on t.host = y.host
