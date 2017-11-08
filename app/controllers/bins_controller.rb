class BinsController < ApplicationController
    ###########################################################
    #
    # Transfer from one bin to another
    #
    ###########################################################
    def display_transfer_request_screen
    end

    def display_transfer_result
        # view will pre-populate FROM string if in params[:from]

        # Need to update bins in a transaction; will have model
        # validation do various checks (e.g. attempt to go below zero)
        # view will pre-populate FROM string if in params[:from]

        # Need to update bins in a transaction; will have model
        # validation do various checks (e.g. attempt to go below zero)

        # short circuit over to transfer out

        if params[:commit] == "Cancel"

          redirect_back fallback_location: "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/0",
            notice: "Action Cancelled"
          return

        elsif params[:commit] == "Add to Stock"
          return display_transfer_in_result

        elsif params[:commit] == "Remove from Stock"
          return display_transfer_out_result

        else

          qty_now = 0

          ActiveRecord::Base.transaction do

            action_tracker = 'find sku id'

            # Find destination bin with matching sku and location

            src_sku_id = Sku.find_by!(name: params[:sku]).id
            action_tracker = 'find src location id'
            src_location_id = Location.find_by!(name: params[:from]).id

            action_tracker = 'find src bin ' + params[:from]
            src_bin = Bin.find_by!(sku_id: src_sku_id, location_id: src_location_id)

            # Find destination bin with matching sku and location
            action_tracker = 'find dest id'
            dest_sku_id = Sku.find_by!(name: params[:sku]).id
            action_tracker = 'find dest location id'
            dest_location_id = Location.find_by!(name: params[:to]).id

            dest_bin = Bin.find_by(sku_id: dest_sku_id, location_id: dest_location_id)

            if dest_bin.nil?

                dest_bin = Bin.create(sku_id: dest_sku_id,
                                      location_id: dest_location_id,
                                      qty: params[:quantity].to_i)
                ## Don't use decrement!, it skips validations
                src_bin.qty -= params[:quantity].to_i
                src_bin.save!
            # src_bin.decrement!(:qty, params[:quantity].to_i)

            else

                ## Don't use increment or decrement, they skip validations
                src_bin.qty -= params[:quantity].to_i
                src_bin.save!
                # src_bin.decrement!(:qty, params[:quantity].to_i)
                dest_bin.qty += params[:quantity].to_i
                dest_bin.save!
                # dest_bin.increment!(:qty, params[:quantity].to_i)
                qty_now = dest_bin.qty
            end

            src_bin.destroy! if src_bin.qty < 1

            Transaction.create!(from_id: src_location_id, to_id: dest_location_id,
                                qty: params[:quantity].to_i,
                                sku_id: src_sku_id, user_id: session[:user_id],
                                comment: params[:comment])
        end

      end

      redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{qty_now.to_s}",
        notice: "Success"

      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
          @error_message = e.message
          #render template: 'login/generic_error'
          redirect_back fallback_location: "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/0",
            alert: @error_message
      end

    ##########################################################
    #
    # Increase quantity in a bin, or create a bin if
    # none exists
    #
    ##########################################################
    def display_transfer_in_request_screen
    end

    def display_transfer_in_result
        # view will pre-populate FROM string if in params[:from]

        # Need to update bins in a transaction; will have model
        # validation do various checks (e.g. attempt to go below zero)

        # Can't be a cancel request at this point, since that's already handled

        if params[:to].nil? or params[:to] !~ /\S/
          @error_message = "Must have a \"To Location \" to transfer new items into."
          redirect_back fallback_location: "/display_transfer_request_screen",
           alert: @error_message
          return
        end


        qty_now = 0

        ActiveRecord::Base.transaction do
            # find the bin in question, creating a destination
            # bin if necessary

            # Find destination bin with matching sku and location
            dest_sku_id = Sku.find_by!(name: params[:sku]).id
            dest_location_id = Location.find_by!(name: params[:to]).id

            dest_bin = Bin.find_by(sku_id: dest_sku_id, location_id: dest_location_id)

            if dest_bin.nil?

                dest_bin = Bin.create(sku_id: dest_sku_id,
                                      location_id: dest_location_id,
                                      qty: params[:quantity].to_i)
            else

                ## Don't use increment!, it bypasses validations
                # dest_bin.increment!(:qty, params[:quantity].to_i)
                dest_bin.qty += params[:quantity].to_i
                dest_bin.save!

                qty_now = dest_bin.qty

            end

            Transaction.create!(to_id: dest_location_id,
                                qty: params[:quantity].to_i,
                                sku_id: dest_sku_id, user_id: session[:user_id])
        end  #end of transaction


          redirect_back fallback_location: "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:to])}/#{qty_now.to_s}",
             notice: "Success"

      rescue ActiveRecord::RecordNotFound => e

        redirect_back fallback_location: "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:to])}/0",
          alert: e.message


      end

    #########################################################
    #
    # Decrease quantity in a bin, and delete the bin
    # if it has gone to zero
    #
    #########################################################
    def display_transfer_out_request_screen
    end

    def display_transfer_out_result
        # view will pre-populate FROM string if in params[:from]

        # Need to update bins in a transaction; will have model
        # validation do various checks (e.g. attempt to go below zero)

        # Can't be a cancel request since that's already handled

        qty_now = 0

        ActiveRecord::Base.transaction do
            # Find destination bin with matching sku and location

            src_sku_id = Sku.find_by!(name: params[:sku]).id
            src_location_id = Location.find_by!(name: params[:from]).id
            src_bin = Bin.find_by!(sku_id: src_sku_id, location_id: src_location_id)

            ## don't use decrement!, it bypasses validations
            qty_now = src_bin.qty -= params[:quantity].to_i
            src_bin.save!
            # src_bin.decrement!(:qty, params[:quantity].to_i)

            src_bin.destroy! if src_bin.qty < 1

            Transaction.create!(from_id: src_location_id,
                                qty: params[:quantity].to_i,
                                sku_id: src_sku_id, user_id: session[:user_id])
        end

        redirect_back fallback_location: "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{qty_now.to_s}",
                    notice: "Success"


      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e

        @error_message = e.message
        redirect_back fallback_location: "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{qty_now.to_s}",
          alert: @error_message

      end
end
