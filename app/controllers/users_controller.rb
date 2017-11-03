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


    if params[:commit] == "Cancel"

      redirect_back fallback_location: "/display_manage_user_request_screen",
        notice: "Operation Cancelled"


    elsif params[:commit] == "Refresh"

      new_place =  "/display_manage_user_request_screen" + (params.key?(:user_string) ? ("/" + params[:user_string]) : "")
      redirect_to new_place

    elsif params['commit'] == "Create"

        User.create!(name: params[:user_string],
          user_id: session[:user_id], #note this is the user id of the creator
          comment: params[:comment_string],
          is_retired: params.key?(:is_retired_string),
          capabilities:  params.key?(:is_admin_string) ? "admin" : ''
        )

        new_place =  "/display_manage_user_request_screen/" + params[:user_string]

        redirect_to new_place, notice: "Created #{params[:user_string]}"



    elsif params['commit'] == 'Update'


        the_user = User.find_by!(name: params[:user_string])

        the_user.update!(
          user_id: session[:user_id],
          comment: params[:comment_string],
          is_retired: params.key?(:is_retired_string),
          capabilities:  params.key?(:is_admin_string) ? "admin" : ''
        )

        # clear password if requested
        if params.key?(:reset_password_string)
          the_user.update!(
            encrypted_password: ''
          )
        end

        new_place =  "/display_manage_user_request_screen/" + params[:user_string]

        redirect_to new_place, notice: "Updated #{params[:user_string]}"


      elsif params['commit'] == 'List All Users'

        redirect_to "/display_user_catalog"


    end


  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e

    @error_message = e.message
    redirect_back fallback_location: "/display_manage_user_request_screen",
      alert: @error_message

  end


  def display_user_catalog

  end

  def all_users_as_json

    @the_display_list = []

    @the_display_list = User.select(
        "users.name as user, users.comment as comment, users.capabilities as capabilities").as_json

    render json: @the_display_list

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
