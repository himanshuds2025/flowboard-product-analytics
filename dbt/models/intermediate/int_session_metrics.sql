with sessions as(
select
  session_id,
  user_id,
  session_start,
  session_end,
  device_type,
  platform
  from {{ref('stg_sessions')}}
),

session_metrics as (
  select
  session_id,
  user_id,
  session_start,
  session_end,
  device_type,
  platform,
  date(session_start, 'UTC') as session_date_utc,
  extract(Hour from session_start at time zone 'UTC') as session_start_hour_utc,
  timestamp_diff(session_end, session_start, second) as session_duration_seconds
  from sessions
)

SELECT
    session_id,
    user_id,
    session_start,
    session_end,
    device_type,
    platform,
    session_date_utc,
    session_start_hour_utc,
    session_duration_seconds,

    session_duration_seconds / 60.0
        AS session_duration_minutes

FROM session_metrics