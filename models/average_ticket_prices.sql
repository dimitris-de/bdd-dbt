select
    station_from,
    station_to,
    round(avg(price), 2) as avg_price,
    count(*) as trip_count
from {{ ref('train_ticket_prices') }}
group by
    station_from, station_to
order by
    avg_price desc
