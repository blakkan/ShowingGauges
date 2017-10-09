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

    session[:location_list_to_sql_regexp] = "name LIKE " +
      params[:location_string]
      .tr("*", "%")
      .split(',')
      .map{|x| "'" + x + "'"}
      .join(' OR name LIKE ')

  end

  def shelf_item_found

    @the_display_list = []

    Location.where( session[:location_list_to_sql_regexp] )
      .order(name: "ASC")
      .each do |the_location|

          the_location.bins.each do |bin|
              @the_display_list << {loc: the_location.name, qty: bin.qty , sku: bin.sku.name }
          end

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
