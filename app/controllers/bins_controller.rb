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

        src_qty_now = -1  #so all can see our grevious error, start with a default clearly non-sensical value

        if params[:commit] == "Cancel"
          if params.key?(:comment)
            redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
              notice: "Action Cancelled"
          else
            redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}",
              notice: "Action Cancelled"

          end
          return

        elsif params[:commit] == "Add to Stock"
          return display_transfer_in_result

        elsif params[:commit] == "Remove from Stock"
          return display_transfer_out_result

        elsif params[:to] =~ /(Account)|(Work order)|(WO)/i
          if params.key?(:comment) and (params[:comment] =~ /\S/)
            return display_transfer_out_result

          else
            redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}",
              alert: "It appears you are trying to transfer to an account or work order, but with no comment.  Please indicate in the comment an account or work order number"
            return

          end


        else

          ActiveRecord::Base.transaction do

            # Find destination bin with matching sku and location
            begin
              src_sku_id = Sku.find_by!(name: params[:sku]).id
            rescue ActiveRecord::RecordNotFound => e
                @error_message = e.message
                #render template: 'login/generic_error'
                redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
                  alert: "Could not find SKU with that number"
                return
            end


            begin
              src_location_id = Location.find_by!(name: params[:from]).id
            rescue ActiveRecord::RecordNotFound => e
                #render template: 'login/generic_error'
                redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
                  alert: "Could not find that source location name"
                return
            end


            begin
              src_bin = Bin.find_by!(sku_id: src_sku_id, location_id: src_location_id)
            rescue ActiveRecord::RecordNotFound => e
                #render template: 'login/generic_error'
                redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
                  alert: "Could not find a quantity of requested SKU in requested location"
                return
            end
            # Find destination bin with matching sku and location

            begin
              dest_location_id = Location.find_by!(name: params[:to]).id
            rescue ActiveRecord::RecordNotFound => e
              #render template: 'login/generic_error'
              redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
                alert: "Could not find destination location"
              return
            end


            dest_bin = Bin.find_by(sku_id: src_sku_id, location_id: dest_location_id)

            if dest_bin.nil?

              begin

                ## Don't use decrement!, it skips validations
                src_bin.qty -= params[:quantity].to_i
                src_bin.save!

                dest_bin = Bin.create(sku_id: src_sku_id,
                                      location_id: dest_location_id,
                                      qty: params[:quantity].to_i)

              rescue ActiveRecord::RecordInvalid=> e
                #render template: 'login/generic_error'
                redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
                  alert: e.message
                return
              end

            # src_bin.decrement!(:qty, params[:quantity].to_i)

            else

              begin
                ## Don't use increment or decrement, they skip validations
                src_bin.qty -= params[:quantity].to_i
                src_bin.save!

                dest_bin.qty += params[:quantity].to_i
                dest_bin.save!
              rescue ActiveRecord::RecordInvalid => e

                #render template: 'login/generic_error'
                redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:quantity])}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}",
                  alert: e.message
                return


              end



            end

            if src_bin.qty < 1  #should only be zero at this point.
              src_bin.destroy!
              src_qty_now = 0
            else
              src_qty_now = src_bin.qty
            end

            Transaction.create!(from_id: src_location_id, to_id: dest_location_id,
                                qty: params[:quantity].to_i,
                                sku_id: src_sku_id, user_id: session[:user_id],
                                comment: params[:comment])
         end #end of transaction

      end #end of main action decision

      redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{src_qty_now.to_s}/#{URI.encode(params[:to])}/#{URI.encode(params[:comment])}", notice: "Success"
      end

    ##########################################################
    #
    # Increase quantity in a bin, or create a bin if
    # none exists
    #
    ##########################################################
  #$  def display_transfer_in_request_screen
  #$  end

    def display_transfer_in_result
        # view will pre-populate FROM string if in params[:from]

        # Need to update bins in a transaction; will have model
        # validation do various checks (e.g. attempt to go below zero)

        # Can't be a cancel request at this point, since that's already handled

        if params[:to].nil? or params[:to] !~ /\S/
          @error_message = "Must have a \"To Location \" to transfer new items into."
          redirect_to "/display_transfer_request_screen",
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
                                sku_id: dest_sku_id, user_id: session[:user_id],
                                comment: params[:comment])
        end  #end of transaction


          redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:to])}/#{qty_now.to_s}",
             notice: "Success"

      rescue ActiveRecord::RecordNotFound => e

        redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:to])}/0",
          alert: e.message


      end

    #########################################################
    #
    # Decrease quantity in a bin, and delete the bin
    # if it has gone to zero
    #
    #########################################################
  #$  def display_transfer_out_request_screen
  #$  end

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
                                sku_id: src_sku_id, user_id: session[:user_id],
                                comment: params[:comment])
        end

        params[:to] = '' unless params.key?(:to)

        redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{URI.encode(params[:to])}/#{qty_now.to_s}",
                    notice: "Success"


      rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e

        @error_message = e.message
        redirect_to "/display_transfer_request_screen/#{URI.encode(params[:sku])}/#{URI.encode(params[:from])}/#{qty_now.to_s}",
          alert: @error_message

      end

      #############################################################################################
      #
      #   This throws the screen for new sku requests.   It will have content
      #  for sku type, location, and an initial quantity.   (Could use partials for the
      #  manage sku and manage location, plus a simple quantity)
      #
      #############################################################################################
      def display_new_sku_request_screen
      end

      ##############################################################################################
      #
      #  This creates a new sku, a new bin, and a new location in one user step.
      #
      #   If the sku number exists exactly, will give a note and fail
      #
      #  If the location name exists exactly, will give a note and fail
      #
      ##############################################################################################
      def display_new_sku_result

        the_sku_type = nil
        dest_location = nil
        dest_bin = nil

        sku_initial_find = false
        loc_initial_find = false

        if (params[:quantity].to_i < 1)

          redirect_to "/display_new_sku_request_screen",
            alert: "Quantity must be 1 or greater.  Request cancelled. \n"
          return
        end

        # First check to see if the sku or location already exist
        ActiveRecord::Base.transaction do

          sku_initial_find = Sku.exists?(name: params[:sku_string])
          loc_initial_find = Location.exists?(name: params[:location_string])

        # Next, check to see if the skus or locations exist. Create as needed
          the_sku_type =
            Sku.create_with( #name: params[:sku_string],
             comment: params[:comment_string],
             minimum_stocking_level: params[:stock_level_string].to_i,
             is_retired: params.key?(:is_retired_string),
             user_id: session[:user_id],
             bu: params[:bu_string],
             description: params[:description_string],
             category: params[:category_string],
             cost: (params.key?(:cost_string) && params[:cost_string] =~ /\d/) ?
                    params[:cost_string].gsub(/[^0-9.]/, '').to_d : 0
              ).find_or_create_by!(name: params[:sku_string])

          dest_location =
            Location.create_with( #name: params[:location_string],
              comment: params[:location_comment_string],
              is_retired: params.key?(:location_is_retired_string),
              user_id: session[:user_id]
            ).find_or_create_by!(name: params[:location_string])
          # Finally, create new sku, location, and bin entry
          #From here, it's like a transfer_in

          dest_bin =
            Bin.create_with(#sku_id: the_sku_type.id,
                            #  location_id: dest_location.id,
                              qty: params[:quantity].to_i).
                              find_or_create_by!(sku_id: the_sku_type.id, location_id: dest_location.id)

          dest_bin.save!

          #Now log it in the journal
          Transaction.create!(to_id: dest_location.id,
                            qty: params[:quantity].to_i,
                            sku_id: the_sku_type.id, user_id: session[:user_id])

      end  #end of activerrecrod transaction

      # Now determine what to tell user
      notice_message = ""

      notice_message += "Items entered, but sku type already existed, so new sku details ignored. \n" if sku_initial_find
      notice_message += "Items entered, but location already existed, so new location details ignored. \n" if loc_initial_find

      if notice_message.length > 0
        redirect_to "/display_new_sku_request_screen",
        notice: notice_message

      else
       redirect_to "/display_new_sku_request_screen",
       notice: "Success"
     end

  rescue ActiveRecord::RecordNotFound => e

    redirect_to "/display_new_sku_request_screen",
    alert: "Couldn't find record"

  rescue ActiveRecord::RecordInvalid => e
    redirect_to "/display_new_sku_request_screen",
    alert: "SKU or Location error: #{e.message}"

  end #end of method
end
