-- ## User Devices Activity **Int** Datelist Implementation (`query_4.sql`)

-- Building on top of the previous question, convert the date list implementation into the base-2 integer datelist representation as shown in the fact data modeling day 2 lab.

-- Assume that you have access to a table called `user_devices_cumulated` with the output of the above query. To check your work, you can either load the data from your previous query (or the lab) into a `user_devices_cumulated` table, or you can generate the `user_devices_cumulated` table as a CTE in this query.

-- You can write this query in a single step, but note the three main transformations for this to work:

-- - unnest the dates, and convert them into powers of 2
-- - sum those powers of 2 in a group by on `user_id` and `browser_type`
-- - convert the sum to base 2

with
    today as (
        select * from shababali.user_devices_cumulated where date = DATE('2024-05-20')
    ),
    date_list_int as (
        select 
            user_id, browser_type, 
            CAST(
                SUM(
                    --if the active on that date, add 2^(index of date in list)
                    case
                        when CONTAINS(dates_active, sequence_date) 
                            then POW(2, 30 - DATE_DIFF('day', sequence_date, date))
                        else 
                            0
                    end
                ) as bigint
            ) as history_int
        from today
            -- gives list of all possible active dates that could be included in sum
            cross join UNNEST (SEQUENCE(DATE('2024-05-20'), DATE('2024-05-20'))) as t (sequence_date)
        group by
            user_id,
            browser_type
    )
select
    *,
    -- convert integer back to binary
    TO_BASE(history_int, 2) as history_in_binary
from
    date_list_int
