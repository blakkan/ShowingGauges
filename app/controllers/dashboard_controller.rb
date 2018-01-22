require 'csv'
class DashboardController < ApplicationController

    ############################################################
    #
    # display_dashboard
    #
    ############################################################
    def display_dashboard
    end

    def display_advanced_search_screen
    end

    def display_reorder_table
    end

    def data

      my_rel2 = Bin.joins("LEFT JOIN skus ON skus.id = bins.sku_id").
        select('sku_id, skus.name, sum(bins.qty) as quantity, skus.minimum_stocking_level as reorder').
        group("sku_id", "skus.minimum_stocking_level", "skus.name").
        having("sum(bins.qty) < max(skus.minimum_stocking_level)")

      my_json =  my_rel2.as_json

      respond_to do |format|
        format.json { render :json => my_json}
        format.csv do
           csv_text = CSV.generate do |csv|
             csv << ["SKU", "Quantity", "Reorder-point"]
             my_json.each do |line|
               csv << [ line['name'], line['quantity'], line['reorder'] ]
             end
           end
           render csv: csv_text
        end
      end

    end

end
