require 'digest/md5'

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
      # If we find the name...
      #
      if (the_user = User.find_by(name: params[:user_name])) && !User.find_by(name: params[:user_name]).is_retired

        #
        # If the password is correct
        #
        if (the_user.encrypted_password == Digest::MD5.hexdigest(params[:user_password]) ||    #must have password correct
                the_user.encrypted_password.nil? || the_user.encrypted_password == '')         #or a blank password

          #
          # If we're trying to login
          #
          if params[:commit] == "Submit"

            session[:user_id] = the_user.id
            redirect_to '/display_find_skus_screen', notice: "Welcome back, #{params[:user_name]}"

          #
          # If we're trying to change password
          #
          elsif params[:commit] == 'Change Password'
              session[:user_id] = the_user.id
              redirect_to '/display_change_password_screen'
          end

        #
        # If the password was wrong
        #
        else
          session.delete(:user_id)
          redirect_back fallback_location: '/display_login_screen',
                      alert: 'Incorrect Password' # notice for info, alert for error

        end
      #
      # If we don't find the name
      #
      else
        session.delete(:user_id)
        redirect_back fallback_location: '/display_login_screen',
                    alert: 'No user by that name' # notice for info, alert for error
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

end
