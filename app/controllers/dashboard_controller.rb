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

      my_rel2 = Bin.joins("LEFT JOIN skus ON skus.id = bins.sku_id").
        select('sku_id, skus.name, sum(bins.qty) as Quantity, skus.minimum_stocking_level as Reorder').
        group("sku_id", "skus.minimum_stocking_level", "skus.name").
        having("sum(bins.qty) < max(skus.minimum_stocking_level)")


      render :json => my_rel2.as_json

    end

end
