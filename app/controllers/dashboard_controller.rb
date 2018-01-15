class DashboardController < ApplicationController

    ############################################################
    #
    # display_dashboard
    #
    ############################################################
    def display_dashboard
    end

    def display_reorder_table
    end

    def data


      my_data = [
        [ "80-1234", 7 , 10],
        [ "80-1235", 71, 100 ],
        [ "80-1236",  72, 100 ],
        [ "80-1237",  73, 100 ],
        [ "80-9238",  74, 100 ],
        [ "80-1234", 19, 20 ]  ]

      my_data =  Bin.joins(:sku).
        select("skus.name as 'SKU', sum(bins.qty) as 'Quantity', skus.minimum_stocking_level as 'Reorder'").
        group("bins.sku_id").
        having("sum(bins.qty) < skus.minimum_stocking_level")

      p my_data
      render :json => my_data.as_json

    end

end
