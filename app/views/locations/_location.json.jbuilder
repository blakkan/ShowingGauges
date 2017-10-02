json.extract! location, :id, :name, :comment, :user, :created_at, :updated_at
json.url location_url(location, format: :json)
