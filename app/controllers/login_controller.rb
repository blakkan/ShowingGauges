class LoginController < ApplicationController

  def display_login_screen

  end

  def set_session_name


    if ( User.find_by(name: params[:user_name]) && !(User.find_by(name: params[:user_name]).is_retired) )

      session[:user_id] = User.find_by(name: params[:user_name]).id

      redirect_to '/display_find_skus_screen', notice: "Welcome back, #{params[:user_name]}"
      return

    else
      session.delete(:user_id)
      redirect_back fallback_location: "/display_login_screen",
        alert: "No user by that name"  #notice for info, alert for error
      return
    end

  end

end
