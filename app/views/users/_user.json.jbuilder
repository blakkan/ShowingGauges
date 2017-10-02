json.extract! user, :id, :name, :encrypted_password, :is_retired, :capabilities, :created_at, :updated_at
json.url user_url(user, format: :json)
