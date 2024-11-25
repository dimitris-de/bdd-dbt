with ranked_routes as (
    select
        station_from,
        station_to,
        tickets_sold,
        rank() over (order by tickets_sold desc) as calc_rank
    from {{ ref('most_popular_routes') }}
)

select *
from ranked_routes as r1
join {{ ref('most_popular_routes') }} as r2
on r1.station_from = r2.station_from
   and r1.station_to = r2.station_to
where r1.calc_rank != r2.popularity_rank