with operator_daily_revenue as (
    select
        train_operator
        ,date
        ,sum(price)                                         as total_revenue
        ,avg(price)                                         as avg_ticket_price
        ,count(*)                                           as total_tickets_sold
    from {{ ref('train_ticket_prices') }}
)

select
    train_operator
    ,date
    ,total_revenue
    ,round(avg_ticket_price, 2)                             as avg_ticket_price
    ,total_tickets_sold
from operator_daily_revenue
order by
    train_operator, date