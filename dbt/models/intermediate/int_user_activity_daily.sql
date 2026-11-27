with meaningful_events as (
  select 
  user_id,
  event_at,
  event_name
  from {{ ref('stg_events')}}
  where event_name in (
    'project_created',
    'task_created',
    'task_completed',
    'project_viewed',
    'comment_created',
    'search_performed',
    'invite_sent',
    'invite_accepted',
    'template_used',
    'mention_sent'
  )
and event_at is not null
and user_id is not null
)

select 
  user_id,
  date(event_at) as activity_date,
  count(*) as activity_event_count,
  COUNTIF(event_name = 'task_completed') AS task_completion_event_count,
  min(event_at) as first_activity_at,
  max(event_at) as last_activity_at

from meaningful_events
group by 1,2