--  CREATE TYPE season_stats AS (
--                          season Integer,
--                          pts REAL,
--                          ast REAL,
--                          reb REAL,
--                          weight INTEGER
--                        );
--
--  CREATE TABLE players (
--      player_name TEXT,
--      height TEXT,
--      college TEXT,
--      country TEXT,
--      draft_year TEXT,
--      draft_round TEXT,
--      draft_number TEXT,
--      seasons_stats season_stats[],
--      current_season INTEGER,
--      PRIMARY KEY (player_name, current_season)
--  );

-- keep cumulating the updates 
insert into players
with yesterday as (select *
                   from players
                   where current_season = 2000),
     today as (select *
               from player_seasons
               where season = 2001)

select COALESCE(y.player_name, t.player_name) as player_name,
        COALESCE(y.height, t.height) as height,
        COALESCE(y.college, t.college) as college,
        COALESCE(y.country, t.country) as country,
        COALESCE(y.draft_year, t.draft_year) as draft_year,
        COALESCE(y.draft_round, t.draft_round) as draft_round,
        COALESCE(y.draft_number, t.draft_number) as draft_number,
        case when y.seasons_stats is null
            then array[row (
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
                ):: season_stats]
        when t.season is not null then y.seasons_stats || array[row (
                t.season,
                t.gp,
                t.pts,
                t.reb,
                t.ast
                ):: season_stats]
        else y.seasons_stats end as season_stat,
    coalesce(t.season, y.current_season+1) as current_season
        from today t full outer join yesterday y
on t.player_name = y.player_name;

with unnested as (
select player_name, unnest(seasons_stats)::season_stats as season_stats
from players where current_season = 2001 and player_name = 'Michael Jordan'
) select player_name, (season_stats::season_stats).* from unnested
