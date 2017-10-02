class LoginController < ApplicationController

  def display_login_screen

  end

  def set_session_name
    session[:user_id] = User.find_by(name: params[:user_name]).id

    render 'welcome'

  end

end
