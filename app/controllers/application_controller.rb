class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end

# new renderer (right form the api documentation

ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, type: Mime[:csv],
    disposition: "attachment; filename=#{filename}.csv"
end
