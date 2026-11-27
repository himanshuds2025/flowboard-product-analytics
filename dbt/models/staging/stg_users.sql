with source as (
    select * from `product-analysis-509809`.`saas_analytics`.`users`
)

select
    user_id,
    workspace_id,
    cast(signup_timestamp as timestamp) as signup_timestamp,
    acquisition_channel,
    country,
    device_type,
    platform,
    industry,
    company_size,
    role,
    signup_plan,
    current_timestamp() as loaded_at
from source