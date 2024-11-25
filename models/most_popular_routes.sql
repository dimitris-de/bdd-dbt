with route_sales as (
    select
        station_from
        ,station_to
        ,count(*)                                       as tickets_sold
        ,round(sum(price), 2)                           as total_revenue
    from {{ ref('train_ticket_prices') }}
    group by station_from, station_to
)

select
    station_from,
    ,station_to,
    ,tickets_sold,
    ,total_revenue,
    ,rank() over (order by tickets_sold desc)           as popularity_rank
from route_sales
order by popularity_rank