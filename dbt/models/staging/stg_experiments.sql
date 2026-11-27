with source as (
    select * from `product-analysis-509809`.`saas_analytics`.`experiments`
)

select
    experiment_id,
    experiment_name,
    user_id,
    variant,
    cast(assigned_at as timestamp) as assigned_at,
    current_timestamp() as loaded_at
from source