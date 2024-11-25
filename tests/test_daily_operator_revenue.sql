select *
from {{ ref('daily_operator_revenue') }}
where total_revenue < 0 or avg_ticket_price < 0