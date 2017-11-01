class LocationsController < ApplicationController
  #before_action :set_location, only: [:show, :edit, :update, :destroy]


  ##############################################

  def display_find_shelf_items_screen

  end

  def display_shelf_items

    if params[:commit] == "Cancel"
      redirect_back fallback_location: "/display_find_shelf_items_screen",
        notice: "Operation Cancelled"
      return
    else
      @a_location_pattern = params[:location_string]
    end
  end

  def shelf_item_matching

    @the_display_list = []

    location_list_to_sql_regexp = "locations.name LIKE " +
      URI.decode(params[:match_string])
      .tr("*", "%")
      .split(',')
      .map{|x| "'" + x.strip + "'"}
      .join(' OR locations.name LIKE ')



      @the_display_list = Bin.joins(:location).where(location_list_to_sql_regexp).joins(:sku).select(
        "bins.sku_id as sku_id, bins.location_id as location_id, skus.name as sku_num, skus.bu as bu, skus.description as description, skus.category as category, " +
        "skus.cost as cost, bins.qty as qty, locations.name as loc").as_json

      # Now decimal conversion to currency
      @the_display_list.map! do |x|
        x['extended'] =  ActionController::Base.helpers.number_to_currency(x['cost'] * x['qty'])
        x['cost'] = ActionController::Base.helpers.number_to_currency(x['cost'])
        x
      end

      render json: @the_display_list

  end


  def display_manage_location_request_screen

    if params.key?(:location_string_from_url)
      begin
        the_location = Location.find_by!(name: params[:location_string_from_url])

        @pre_pop_location = the_location.name
        @pre_pop_comment = the_location.comment
        @pre_pop_is_retired = the_location.is_retired
      rescue ActiveRecord::RecordNotFound => e
        @error_message = e.message
        redirect_back fallback_location: "/display_manage_location_request_screen",
          alert: @error_message
        return
      end
    else
      @pre_pop_location = nil
      @pre_pop_comment = nil
      @pre_pop_is_retired = false
    end


  end



  def manage_location_result


    if params[:commit] == "Cancel"

      redirect_back fallback_location: "/display_manage_location_request_screen",
        notice: "Operation Cancelled"
      return

    elsif params[:commit] == "Refresh"

      new_place =  "/display_manage_location_request_screen/" + params[:location_string]

      redirect_to new_place
      return

    elsif params['commit'] == "Create"

      Location.create!(name: params[:location_string],
        comment: params[:comment_string],
        is_retired: params.key?(:is_retired_string),
        user_id: session[:user_id]
      )

      new_place =  "/display_manage_location_request_screen/" + params[:location_string]

      redirect_to new_place, notice: "Created #{params[:location_string]}"
      return

    elsif params['commit'] == 'Update'

        the_location = Location.find_by!(name: params[:location_string])

        the_location.update!(
          comment: params[:comment_string],
          is_retired: params.key?(:is_retired_string),
          user_id: session[:user_id]

          )

        new_place =  "/display_manage_location_request_screen/" + params[:location_string]

        redirect_to new_place, notice: "Updated #{params[:location_string]}"
        return

      elsif params['commit'] == 'Delete'


          the_loc = Location.find_by!(name: params[:location_string])

          # If there are some bins with a quantity of this sku, can't do it
          if (Bin.where(location_id: the_loc.id).count != 0 ||
              Transaction.where(["from_id = ? or to_id = ?", the_sku.id, the_sku.id ] ).count != 0 )
            redirect_back fallback_location: "/display_manage_location_request_screen/" + params[:location_string],
            alert: "Cannot delete location #{params[:location_string]} since there is inventory in it or a transaction record"
            return
          # otherwise, if there is no quanity, go ahead and delete
          else
            the_loc.destroy!
            redirect_back fallback_location: "/display_manage_location_request_screen",
              notice: "Deleted #{params[:location_string]}"

          return

        end

      elsif params['commit'] == 'List All Locations'

        redirect_to "/display_location_catalog"
        return


    end

    redirect_back fallback_location: "/display_manage_location_request_screen",
      notice: "Location #{params[:location_string]} updated"
    return

  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e

    @error_message = e.message
    redirect_back fallback_location: "/display_manage_location_request_screen",
      alert: @error_message
    return

  end

  def display_location_catalog

  end

  def all_locations_as_json

    @the_display_list = []

    @the_display_list = Location.select(
        "locations.name as loc, comment").as_json

    render json: @the_display_list

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:name, :comment, :created_by_id, :User)
    end
end
