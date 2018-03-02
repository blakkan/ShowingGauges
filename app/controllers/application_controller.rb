class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_login

  before_action :set_cache_stopper

end

# new renderer (right form the api documentation

ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, type: Mime[:csv],
    disposition: "attachment; filename=#{filename}.csv"
end

private
##################################################################
#
# For this application, don't want any cacheing, so enforce that
# by always including response headers to prevent it in browsers.
#
##################################################################
def set_cache_stopper
  response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
  response.headers["Pragma"] = "no-cache"
  response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
end

#################################################################
#
# Enforce login requirements, except for those few pages (i.e. login
# itself, and password change) which do not require login.
#
#################################################################
def require_login
  if session[:user_id]
    ;
  else
    redirect_to '/display_login_screen', alert: "You must login to access this"
  end
end

# Note for reference.. Sinatra/Rack uses this, which also specifies cacheing...
#return [ 200, { 'Content-Type' => 'text/csv; filename="response.csv"',
#                'Content-disposition' => 'attachment; filename="response.csv"',
#
