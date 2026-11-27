with source as (
    select * from `product-analysis-509809`.`saas_analytics`.`sessions`
)

select
    session_id,
    user_id,
    cast(session_start as timestamp) as session_start,
    cast(session_end as timestamp) as session_end,
    device_type,
    platform,
    current_timestamp() as loaded_at
from source