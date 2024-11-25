select *
from {{ ref('average_ticket_prices') }}
where avg_price < 0