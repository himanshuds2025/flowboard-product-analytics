with source as (
    select * from `product-analysis-509809`.`saas_analytics`.`product_changes`
)

select
    change_id,
    change_name,
    change_type,
    cast(release_date as timestamp) as release_date,
    affected_feature,
    description,
    current_timestamp() as loaded_at
from source