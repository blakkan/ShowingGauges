class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  ##############################################

  def display_find_shelf_items_screen

  end

  def display_shelf_items

    @a_location_pattern = params[:location_string]

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

  end

  def manage_location_result


    if params['commit'] =="Create"
      Location.create!(name: params[:location_string])
    else

      the_location = Location.find_by(name: params[:location_string])

      if params['commit'] == "Retire"
        the_location.update!(is_retired: true)
      end

    end

    render 'login/generic_ok'

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
