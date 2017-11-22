#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :developer
#  provider :google_oauth2, '549167835186-fkmvas29tv88h8gqo8c3iur7goil6d21.apps.googleusercontent.com',
#                             'l2x3yuXn86eJgyKFxS9zRbvI', { prompt: 'consent' }

#  provider :open_id, :name => 'oid',
#      :identifier => 'https://accounts.google.com/o/oauth2/v2/auth'

#  provider :openid_connect, :name => 'openid_connect',
#    scope: [:openid, :email, :profile ],
#    response_type: :code,
#    discovery: false,
#    authorization_endpoint:"https://accounts.google.com/o/oauth2/v2/auth",
#    options: {
#        issuer: "https://accounts.google.com/.well-known/openid-configuration"
#    },
#    client_options: {
#     discovery: false,
#      authorization_endpoint:"https://accounts.google.com/o/oauth2/v2/auth",
#      port: 443,
#      scheme: "https",
#      host: "accounts.google.com",
#      identifier: '549167835186-fkmvas29tv88h8gqo8c3iur7goil6d21.apps.googleusercontent.com',
#      secret: 'l2x3yuXn86eJgyKFxS9zRbvI',
#      redirect_uri: "http://localhost:3000/auth/openid_connect/callback"
#    }
#  provider :yahoo
#  provider :open_id, name: 'yahoo_o', identifier: 'https://api.login.yahoo.com/oauth2/request_auth/'
#  provider :open_id, name: 'google_o', identifier: 'https://www.google.com/accounts/o8/id'
#end

#OpenID.fetcher.ca_file = "/etc/ssl/certs/ca-certificates.crt"
