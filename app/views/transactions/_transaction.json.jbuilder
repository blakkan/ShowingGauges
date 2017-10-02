json.extract! transaction, :id, :SKU, :qty, :from, :to, :who, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
