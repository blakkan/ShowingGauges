class SkusController < ApplicationController
  before_action :set_sku, only: [:show, :edit, :update, :destroy]

  # GET /skus
  # GET /skus.json
  def index
    @skus = Sku.all
  end

  # GET /skus/1
  # GET /skus/1.json
  def show
  end

  # GET /skus/new
  def new
    @sku = Sku.new
  end

  # GET /skus/1/edit
  def edit
  end

  # POST /skus
  # POST /skus.json
  def create
    @sku = Sku.new(sku_params)

    respond_to do |format|
      if @sku.save
        format.html { redirect_to @sku, notice: 'Sku was successfully created.' }
        format.json { render :show, status: :created, location: @sku }
      else
        format.html { render :new }
        format.json { render json: @sku.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /skus/1
  # PATCH/PUT /skus/1.json
  def update
    respond_to do |format|
      if @sku.update(sku_params)
        format.html { redirect_to @sku, notice: 'Sku was successfully updated.' }
        format.json { render :show, status: :ok, location: @sku }
      else
        format.html { render :edit }
        format.json { render json: @sku.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /skus/1
  # DELETE /skus/1.json
  def destroy
    @sku.destroy
    respond_to do |format|
      format.html { redirect_to skus_url, notice: 'Sku was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


##############################################

def display_find_skus_screen

end

def display_skus

#  @the_display_list = []
  session[:sku_string] = params[:sku_string]



#  Sku.where( session[:sku_list_to_sql_regexp] )
#        .order(name: "ASC")
#        .each do |the_sku|
#
#      the_sku.bins.each do |bin|
#          @the_display_list << {name: the_sku.name, quantity: bin.qty , location: bin.location.name }
#      end
#
#  end

end

def sku_found

  @the_display_list = []

  sku_list_to_sql_regexp = "name LIKE " +
    session[:sku_string]
    .tr("*", "%")
    .split(',')
    .map{|x| "'" + x + "'"}
    .join(' OR name LIKE ')

  Sku.where( sku_list_to_sql_regexp )
        .order(name: "ASC")
        .each do |the_sku|

      the_sku.bins.each do |bin|
          @the_display_list << {sku: the_sku.name, qty: bin.qty , loc: bin.location.name }
      end

  end

  render json: @the_display_list

end


def display_manage_sku_request_screen

end

def manage_sku_result

  if params['commit'] == "Create"
    Sku.create!(name: params[:sku_string])
  else

    the_sku = Sku.find_by(name: params[:sku_string])

    if params['commit'] == "Retire"
      the_sku.update!(is_retired: true)
    elsif params['commit'] == "Update stock level trigger"
      the_user.update!(minimum_stocking_level: params[:stock_level_string].to_i)
    end

  end

  render 'login/generic_ok'

end


###############################################




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sku
      @sku = Sku.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sku_params
      params.require(:sku).permit(:name, :comment, :created_by_id)
    end
end
