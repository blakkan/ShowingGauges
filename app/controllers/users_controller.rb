require 'json'
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]



  def display_manage_user_request_screen

    if params.key?(:user_string_from_url) && ( the_user = User.find_by(name: params[:user_string_from_url]) )

      @pre_pop_user = the_user.name
      @pre_pop_comment = the_user.comment
      @pre_pop_is_retired = the_user.is_retired
      @pre_pop_is_admin = the_user.capabilities =~ /admin/
    else
      @pre_pop_user = nil
      @pre_pop_comment = nil
      @pre_pop_is_retired = false
      @pre_pop_is_admin = false
    end

  end


  def manage_user_result


    if params[:commit] == "Refresh"

      new_place =  "/display_manage_user_request_screen/" + params[:user_string]

      redirect_to new_place
      return

    elsif params['commit'] == "Create"

        User.create!(name: params[:user_string],
          comment: params[:comment_string],
          is_retired: params.key?(:is_retired_string),
          capabilities:  params.key?(:is_admin_string) ? "admin" : ''
        )

    elsif params['commit'] == 'Update'

      begin

        the_user = User.find_by!(name: params[:user_string])

        the_user.update!(
          comment: params[:comment_string],
          is_retired: params.key?(:is_retired_string),
          capabilities:  params.key?(:is_admin_string) ? "admin" : ''
        )

        # clear password if requested
        if params.key?(:reset_password_string)
          the_user.update!(
            encrypted_password_string: ''
          )
        end

      rescue ActiveRecord::RecordNotFound => e
            @error_message = e.message
            render login/generic_error and return
      end

    end

    render 'login/generic_ok'

  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :encrypted_password, :is_retired, :capabilities)
    end
end
