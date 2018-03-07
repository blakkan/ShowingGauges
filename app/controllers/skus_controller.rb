class SkusController < ApplicationController
    before_action :set_sku, only: [:show, :edit, :update, :destroy]

    ##############################################

    def display_find_skus_screen; end

    def display_skus
        if params[:commit] == 'Cancel'
            redirect_to '/display_find_skus_screen',
                          notice: 'Operation Cancelled'
            nil
        else
            @a_sku_pattern = params[:sku_string]
      end
      end

    def sku_matching
        @the_display_list = []

        sku_list_to_sql_regexp = 'lower(skus.name) LIKE ' +
                                    URI.decode(params[:match_string])
                                    .downcase
                                    .tr('*', '%')
                                    .split(',')
                                    .map { |x| "'" + x.strip + "'" }
                                    .join(' OR skus.name LIKE ')

        @the_display_list = Bin.joins(:sku).where(sku_list_to_sql_regexp).joins(:location).select(
            'bins.sku_id as sku_id, bins.location_id as location_id, skus.name as sku_num, skus.bu as bu, skus.description as description, skus.category as category, ' \
            'skus.cost as cost, bins.qty as qty, locations.name as loc'
        ).as_json

        # Now decimal conversion to currency
        @the_display_list.map! do |x|
            x['extended'] = ActionController::Base.helpers.number_to_currency(x['cost'] * x['qty'])
            x['cost'] = ActionController::Base.helpers.number_to_currency(x['cost'])
            x
        end

        render json: @the_display_list
    end

    def display_manage_sku_request_screen
        if params.key?(:sku_string) && (the_sku = Sku.find_by(name: params[:sku_string]))

            @pre_pop_sku = the_sku.name
            @pre_pop_description = the_sku.description
            @pre_pop_comment = the_sku.comment
            @pre_pop_bu = the_sku.bu
            @pre_pop_category = the_sku.category
            @pre_pop_reorder_point = the_sku.minimum_stocking_level.to_s
            @pre_pop_cost = ActionController::Base.helpers.number_to_currency(the_sku.cost)
            @pre_pop_is_retired = the_sku.is_retired
        else
            @pre_pop_sku = nil
            @pre_pop_description = nil
            @pre_pop_comment = nil
            @pre_pop_category = nil
            @pre_pop_bu = nil
            @pre_pop_reorder_point = nil
            @pre_pop_cost = nil
            @pre_pop_is_retired = false
        end
        end

    def display_sku_catalog
    end

    def all_skus_as_json
        @the_display_list = []

        @the_display_list = Sku.joins(:user).select(
            'skus.name as sku_num, skus.bu as bu, skus.description as description, skus.category as category, ' \
            'skus.cost as cost, users.name as user_name'
        ).as_json

        # Now decimal conversion to currency
        @the_display_list.map! do |x|
            x['cost'] = ActionController::Base.helpers.number_to_currency(x['cost'])
            x
        end

        render json: @the_display_list
    end

    ###################################################################################
    #
    #
    #
    ###################################################################################
    def manage_sku_result
        if params[:commit] == 'Cancel'

          #  redirect_to '/display_manage_sku_request_screen',
          #                notice: 'Operation Cancelled')
            redirect_back fallback_location: :display_manage_sku_request_screen,
                          notice: 'Operation Cancelled'
        elsif params[:commit] == 'Refresh'

            new_place = '/display_manage_sku_request_screen' + (params.key?(:sku_string) && params[:sku_string] =~ /\S/ ? "/#{params[:sku_string]}" : '')
            redirect_to new_place

        elsif params['commit'] == 'Create'

            Sku.create!(name: params[:sku_string],
                        comment: params[:comment_string],
                        minimum_stocking_level: params[:stock_level_string].to_i,
                        is_retired: params.key?(:is_retired_string),
                        user_id: session[:user_id],
                        bu: params[:bu_string],
                        description: params[:description_string],
                        category: params[:category_string],
                        cost:
                          (params.key?(:cost_string) && params[:cost_string] =~ /\d/) ?
                           params[:cost_string].gsub(/[^0-9.]/, '').to_d : 0
                        )

            new_place = '/display_manage_sku_request_screen/' + params[:sku_string]

            redirect_to new_place, notice: "Created #{params[:sku_string]}"

        elsif params['commit'] == 'Update'

            the_sku = Sku.find_by!(name: params[:sku_string])

            the_sku.update!(
                comment: params[:comment_string],
                minimum_stocking_level: params[:stock_level_string].to_i,
                is_retired: params.key?(:is_retired_string),
                user_id: session[:user_id],
                bu: params[:bu_string],
                description: params[:description_string],
                category: params[:category_string],
                cost:
                  (params.key?(:cost_string) && params[:cost_string] =~ /\d/) ?
                   params[:cost_string].gsub(/[^0-9.]/, '').to_d :
                   0
            )

            new_place = '/display_manage_sku_request_screen/' + params[:sku_string]

            redirect_to new_place, notice: "Updated #{params[:sku_string]}"

        elsif params['commit'] == 'Delete'

            the_sku = Sku.find_by!(name: params[:sku_string])

            # If there are some bins with a quantity of this sku, can't do it
            if Bin.where(sku_id: the_sku.id).count != 0 ||
               Transaction.where(['sku_id = ?', the_sku.id]).count != 0
                redirect_to '/display_manage_sku_request_screen/' + params[:sku_string],
                              alert: "Cannot delete sku type #{params[:sku_string]} since there is inventory in some location or a transaction record"

            # otherwise, if there is no quanity, go ahead and delete
            else
                the_sku.destroy!
                redirect_to '/display_manage_sku_request_screen',
                              notice: "Deleted #{params[:sku_string]}"

          end

        elsif params['commit'] == 'List All SKU Types'

            redirect_to '/display_sku_catalog'

        end

      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid, Exception => e

            @error_message = e.message
            redirect_to '/display_manage_sku_request_screen',
                          alert: @error_message
        end

    def view_all; end

    ###############################################

    def display_bulk_import_request_screen
    end

    def bulk_import_result

      # Delete all but users, if re-initializing
        if params[:clear_tables_box]
          puts "Clearing all"
          Bin.delete_all
          Location.delete_all
          Transaction.delete_all
          Sku.delete_all
        end


        results_report_string = "Omitting these lines (including header)\n"

        # walk through the tab separated lines
        params[:bulk_input].gsub(/[\r]/, '').split(/\n/).each_with_index do |line, index|

            line.gsub!(/\"/, "")

            next if line.length == 0

            if ( index == 0 )# trim off the header line
              results_report_string += ("#{index.to_s} Header: " + line + "\n")
              next
            end

            if (  not line.split("\t").map(&:strip).length.between?(7,10) )
              results_report_string += ("#{index.to_s} Didn't have 7-10 items on line: " + line + "\n")
              next
            end

            bu, item_number, description, category, quantity, cost, extended, location, re_order_point = line.split("\t").map(&:strip)

            if re_order_point.nil? or re_order_point !~ /\d+/
              re_order_point = "0"
            end

            if location.nil? or location !~ /\S+/
              location = "UNKNOWN"
            end

            begin
              decimal_cost = BigDecimal.new(cost.gsub(/[\$,]/, ''))
              decimal_qty = BigDecimal.new(quantity)
              decimal_extended  = BigDecimal.new(extended.gsub(/[\$,]/, ''))
              decimal_re_order_point = BigDecimal.new(re_order_point)


  ##FIXME            if decimal_extended != (decimal_cost * decimal_qty)
  ##FIXME              results_report_string += ("#{index.to_s} Extended not equal cost * quantity " + line + "\n" )
  ##FIXME              next
  ##FIXME            end

            rescue Exception => e
              results_report_string += ("#{index.to_s} Exception during numberic conversion: #{e.message} " + line + "\n" )
              next
            end

            ActiveRecord::Base.transaction do


              # Create a physical location, if needed
              the_loc = Location.find_by(name: location) || Location.create!(name: location,
                                                                           user_id: session[:user_id])

              # Find or create a SKU
              the_sku = Sku.find_by(name: item_number) || Sku.create!(name: item_number,
                                                                    minimum_stocking_level: decimal_re_order_point, user_id: session[:user_id],
                                                                    bu: bu, description: description, category: category, cost: decimal_cost)

              # Find or create a BIN and add to it
              dest_bin = Bin.find_by(sku_id: the_sku.id, location_id: the_loc.id) ||
                         Bin.create!(sku_id: the_sku.id, location_id: the_loc.id, qty: 0)

              # Don't use increrment!, it bypasses validations
              # dest_bin.increment!(:qty, quantity.to_i)

              dest_bin.qty += quantity.to_i
              dest_bin.save!

            end #end of transaction

        end #end of loop on lines

        render plain: results_report_string
        return

      rescue ActiveRecord::RecordNotFound => e

        render 'login/generic_error'
        return

      end #end of definition (and implicit begin/rescue block)

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
