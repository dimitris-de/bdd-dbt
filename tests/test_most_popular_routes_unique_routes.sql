with duplicates as (
    select
        station_from,
        station_to,
        count(*)
    from {{ ref('most_popular_routes') }}
    group by station_from, station_to
    having count(*) > 1
)
select *
from duplicates