require 'csv'
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

      redirect_to "/display_transactions_request_screen",
        notice: "Operation Cancelled"
      return

    else
      # Scrub dates
      @the_start_date, @the_end_date = scrubbed_dates(params[:start_date_name],
        params[:end_date_name])

      if params[:commit] == 'Export results'
        new_dest = "/transactions_found.csv/#{URI.encode_www_form_component(@the_start_date)}/#{URI.encode_www_form_component(@the_end_date)}"
        redirect_to new_dest
        return
      end

    end

    # If we get here, we're going to display it in html/bootstrap_table

  end


  def transactions_found

    @the_display_list = transactions_in_date_range(params[:start_date_name],
      params[:end_date_name])

    ####render json: @the_display_list

###    respond_to do |format|
###      format.json { render ( { :json => @the_display_list } ) and return }
###      format.csv do
###         csv_text = CSV.generate do |csv|
###           csv << ["SKU", "Description", "From", "To", "Qty", "Comment", "Timestamp", "User"]
###           @the_display_list.each do |line|
###             csv << [ line[:sku_num], line[:description], line[:from],
###                      line[:to], line[:qty], line[:comment], line[:timestamp], line[:who] ]
###           end
###         end
###         render(csv: csv_text )and return
###      end
###    end

    if params[:spud] == "json"
      render json: @the_display_list
      return

    elsif params[:spud] == "csv"

      csv_text = CSV.generate do |csv|
        csv << ["SKU", "Description", "From", "To", "Qty", "Comment", "Timestamp", "User"]
        @the_display_list.each do |line|
          csv << [ line[:sku_num], line[:description], line[:from],
           line[:to], line[:qty], line[:comment], line[:timestamp], line[:who] ]
        end
      end

      render csv: csv_text
      return


    else
      ;
    end


  end


  private

    def scrubbed_dates(start_date_text, end_date_text)

      the_start_date = the_end_date = nil
      begin
        the_start_date = Date.parse(start_date_text)
      rescue ArgumentError, TypeError
        the_start_date = Date.parse("1901-01-01")
      end
      begin
        the_end_date = Date.parse(end_date_text)
      rescue ArgumentError, TypeError
        the_end_date = Date.parse("2101-01-01")
      end

      return [the_start_date, the_end_date]

    end


    ##############################################################
    #
    #  transactions_in_date_range
    #
    #    Given unscrubbed text format date ranges, this
    # scrubs the dates and retuns a list of hashes of all
    # transactions in the (scrubbed) date range.
    #
    ##############################################################
    def transactions_in_date_range(start_date_text, end_date_text)

      the_display_list = []


      the_start_date, the_end_date = scrubbed_dates(start_date_text,
                                                    end_date_text)

      #TODO replace all this with a join returning as_json



      Transaction.where(created_at: the_start_date.beginning_of_day..the_end_date.end_of_day).order(created_at: :desc).all.each do |transaction|

        the_display_list << {
          #FIXME we need a join here, not these lookups
          sku_num: ((transaction.sku_id.nil? || (not Sku.exists?(transaction.sku_id))) ? "NA" : Sku.find(transaction.sku_id).name),
          description: ((transaction.sku_id.nil? || (not Sku.exists?(transaction.sku_id))) ? "NA" : Sku.find(transaction.sku_id).description),
          from: ((transaction.from_id.nil? || (not Location.exists?(transaction.from_id))) ? "TRANS.IN" : Location.find(transaction.from_id).name),
          to: ((transaction.to_id.nil? || (not Location.exists?(transaction.to_id))) ? "TRANS.OUT" : Location.find(transaction.to_id).name),
          qty: transaction.qty,
          comment: transaction.comment,
          timestamp: transaction.created_at,
          who: ((transaction.user_id.nil? || (not User.exists?(transaction.user_id))) ? "NA" : User.find(transaction.user_id).name)}

      end

      return the_display_list

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
