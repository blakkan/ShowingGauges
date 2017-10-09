class LoginController < ApplicationController

  def display_login_screen

  end

  def set_session_name

    if ( User.find_by(name: params[:user_name]) && !(User.find_by(name: params[:user_name]).is_retired) )

      session[:user_id] = User.find_by(name: params[:user_name]).id

      render 'login/welcome'
      return

    else
      session.delete(:user_id)
      render 'login/no_such_user'
      return
    end

  end

end
