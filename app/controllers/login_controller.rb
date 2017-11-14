require 'digest/md5'
require 'net/http'

class LoginController < ApplicationController
    #
    # Draws the login screen
    #
    def display_login_screen
    end

    #
    # draws the login result (and sets the session[:user_id]
    #
    def set_session_name

          #
          # If we're trying to login
          #
          if params[:commit] == "Submit"
            #
            # If we find the name...
            #
            if (the_user = User.find_by(name: params[:user_name])) && !User.find_by(name: params[:user_name]).is_retired

              #
              # If the password is correct
              #
              if (the_user.encrypted_password == Digest::MD5.hexdigest(params[:user_password] || '') ||    #must have password correct
                      the_user.encrypted_password.nil? || the_user.encrypted_password == '')         #or a blank password

                      session[:user_id] = the_user.id
                      redirect_to '/display_find_skus_screen', notice: "Welcome back, #{params[:user_name]}"
              else
                session[:user_id] = nil
                redirect_to '/display_find_skus_screen', alert: "No Matching User/password #{params[:user_name]}"

              end

          #
          # If we're trying to change password
          #
          elsif params[:commit] == 'Change Password'

            #
            # If we find the name...
            #
            if (the_user = User.find_by(name: params[:user_name])) && !User.find_by(name: params[:user_name]).is_retired

              #
              # If the password is correct
              #
              if (the_user.encrypted_password == Digest::MD5.hexdigest(params[:user_password] || '') ||    #must have password correct
                      the_user.encrypted_password.nil? || the_user.encrypted_password == '')         #or a blank password

                session[:user_id] = the_user.id
                redirect_to '/display_change_password_screen'
              else

                session[:user_id] = nil
                redirect_to '/display_find_skus_screen', alert: "No Matching User/password , #{params[:user_name]}"

              end

            else
              session[:user_id] = nil
              redirect_to '/display_find_skus_screen', alert: "No Matching User/password #{params[:user_name]}"

            end

          #
          # openid
          #
        elsif params[:commit] == 'openid_connect'

          #
          # Try a google login (or others, later)
          session[:open_id_security_token] = SecureRandom.hex(40)
          # First, use the discovery document (at a well-known URL) to get the
          # authorization address
          response_discovery = Net::HTTP.get_response(URI.parse('https://accounts.google.com/.well-known/openid-configuration'))

          #TODO check here that we got the endpoint

          auth_endpoint = JSON.parse(response_discovery.body)['authorization_endpoint']

          #
          # Now construct the URL and send it (with the callback URL as
          # one of the parameters...  This will be bounced back to us in
          # the redirect request
          #
          callback_uri = "http://" + request.host + ':' + request.port.to_s + '/third_party_auth'

          ura_string = auth_endpoint + '?redirect_uri=' + callback_uri + '&' +
          "state=#{session[:open_id_security_token]}&" +
          <<~EOF
            client_id=549167835186-fkmvas29tv88h8gqo8c3iur7goil6d21.apps.googleusercontent.com&
            response_type=code&
            scope=openid%20email%20profile
          EOF

          uri_text = ura_string.gsub(/\n/,'')
          puts "about to redirect"

          redirect_to uri_text


        else
          redirect_to '/display_login_screen', Alert: "Didn't recognize login attempt"

        end

      end

    end

    #
    # Draws the change password screen
    #

    def display_change_password_screen
    end

    #
    # Changes the password and shows the results
    #
    def change_password_result

      # first check that new passwords match
      if params[:user_password] != params[:user_password2]
          redirect_back fallback_location: '/display_change_password_screen',
                      alert: 'Failed: Passwords did not match' # notice for info, alert for error

      else
          User.find(session[:user_id]).update_attribute(
            :encrypted_password, Digest::MD5.hexdigest(params[:user_password]))
          redirect_to '/', notice: 'Password Changed'
      end

    end

    #
    # For third party authentication callback
    #
    def third_party_auth

      puts "entered 3rd parth auth"

      callback_uri = "http://" + request.host + ':' + request.port.to_s + '/third_party_auth'

      if params[:code] && (params[:state] == session[:open_id_security_token])

       # one time use
        session[:open_id_security_token] = nil


       response1 = Net::HTTP.post_form(URI.parse('https://www.googleapis.com/oauth2/v4/token'),
        { code: params[:code],
          client_id: "549167835186-fkmvas29tv88h8gqo8c3iur7goil6d21.apps.googleusercontent.com",
          client_secret: "l2x3yuXn86eJgyKFxS9zRbvI",
          redirect_uri: callback_uri,
          grant_type: "authorization_code"
        })


        payload_claims = JSON.parse(Base64.decode64(JSON.parse(response1.body)['id_token'].to_s.split(/\./)[1].to_s))

        # Now we look up the user (but don't check a local password)

        #
        # If we find the name...
        #
        if (the_user = User.find_by(google_email: payload_claims['email'])) && !(the_user.is_retired)

          session[:user_id] = the_user.id
          session[:open_id_security_token] = nil
          redirect_to '/display_find_skus_screen', notice: "Welcome back, #{the_user.name} (#{payload_claims['email']})"

        else
          session[:user_id] = nil
          session[:open_id_security_token] = nil
          redirect_to '/display_login_screen', alert: "Didn't find permitted login"
        end #end of check on name

      else
        session[:user_id] = nil
        session[:open_id_security_token] = nil
        redirect_to '/display_login_screen', alert: "Security token mismatch"
      end #end of check on security token

    end #of auth callback function

end
