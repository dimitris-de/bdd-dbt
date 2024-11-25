select *
from {{ ref('most_popular_routes') }}
where tickets_sold < 0 or total_revenue < 0