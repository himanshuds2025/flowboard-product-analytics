with source as (
    select * from `product-analysis-509809`.`saas_analytics`.`events`
)

select
    event_id,
    user_id,
    cast(timestamp as timestamp) as event_at,
    session_id,
    event_name,
    platform,
    device_type,
    workspace_id,
    experiment_id,
    variant,
    feature_name,
    object_type,
    object_id,
    parent_object_id,
    value_numeric,
    current_timestamp() as loaded_at
from source