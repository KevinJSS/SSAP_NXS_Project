json.extract! minute, :id, :meeting_title, :meeting_date, :start_time, :end_time, :meeting_objectives, :discussed_topics, :pending_topics, :agreements, :meeting_notes, :created_at, :updated_at
json.url minute_url(minute, format: :json)
