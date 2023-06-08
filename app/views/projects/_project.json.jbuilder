json.extract! project, :id, :name, :start_date, :scheduled_deadline, :location, :stage, :stage_status, :created_at, :updated_at
json.url project_url(project, format: :json)
