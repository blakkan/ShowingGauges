class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]



  ############################################################
  #
  #  Display history in page
  #
  ############################################################

  def display_transactions_request_screen

  end


  def display_all_transactions


    if params[:commit] == "Cancel"

      redirect_back fallback_location: "/display_transactions_request_screen",
        notice: "Operation Cancelled"
      return

    else
      # Scrub dates
      @the_start_date, @the_end_date = scrubbed_dates()

    end

  end


  def transaction_found

    @the_display_list = []


    the_start_date, the_end_date = scrubbed_dates()

    #TODO replace all this with a join returning as_json



    Transaction.where(created_at: the_start_date.beginning_of_day..the_end_date.beginning_of_day).order(created_at: :desc).all.each do |transaction|

      @the_display_list << {
        sku_num: ((transaction.sku_id.nil? || (not Sku.exists?(transaction.sku_id))) ? "NA" : Sku.find(transaction.sku_id).name),
        description: ((transaction.sku_id.nil? || (not Sku.exists?(transaction.sku_id))) ? "NA" : Sku.find(transaction.sku_id).description),
        from: ((transaction.from_id.nil? || (not Location.exists?(transaction.from_id))) ? "NA" : Location.find(transaction.from_id).name),
        to: ((transaction.to_id.nil? || (not Location.exists?(transaction.to_id))) ? "NA" : Location.find(transaction.to_id).name),
        qty: transaction.qty,
        comment: transaction.comment,
        timestamp: transaction.created_at,
        who: ((transaction.user_id.nil? || (not User.exists?(transaction.user_id))) ? "NA" : User.find(transaction.user_id).name)}

    end


    render json: @the_display_list

  end

  private

    def scrubbed_dates
      the_start_date = the_end_date = nil
      begin
        the_start_date = Date.parse(params[:start_date_name])
      rescue ArgumentError, TypeError
        the_start_date = Date.parse("1901-01-01")
      end
      begin
        the_end_date = Date.parse(params[:end_date_name])
      rescue ArgumentError, TypeError
        the_end_date = Date.parse("2101-01-01")
      end

      return the_start_date, the_end_date

    end


    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:SKU, :qty, :from, :to, :who)
    end
end
