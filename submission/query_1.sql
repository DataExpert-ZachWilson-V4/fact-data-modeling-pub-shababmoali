-- ## De-dupe Query (`query_1.sql`)
--
-- Write a query to de-duplicate the `nba_game_details` table from the day 1 lab of the fact modeling week 2 so there are no duplicate values.
--
-- You should de-dupe based on the combination of `game_id`, `team_id` and `player_id`, since a player cannot have more than 1 entry per game.
--
-- Feel free to take the first value here.

-- Note: re: logging -- thrift (like avro or protobuff) is very useful for establishing a logging schema

with 
    nba_game_details_dedup as (
        select
            *, ROW_NUMBER() over (PARTITION BY game_id, team_id, player_id) as row_number
        from bootcamp.nba_game_details
    )
-- select all columns; keep only the first occurrence for duplicate records (rows)
select *
from nba_game_details_dedup
where row_number = 1
