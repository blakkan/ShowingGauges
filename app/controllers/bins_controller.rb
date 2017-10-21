class BinsController < ApplicationController

  ###########################################################
  #
  # Transfer from one bin to another
  #
  ###########################################################
  def display_transfer_request_screen

  end

  def display_transfer_result
    #view will pre-populate FROM string if in params[:from]

    # Need to update bins in a transaction; will have model
    # validation do various checks (e.g. attempt to go below zero)
    #view will pre-populate FROM string if in params[:from]

    # Need to update bins in a transaction; will have model
    # validation do various checks (e.g. attempt to go below zero)

    #short circuit over to transfer out
    if params[:commit] == "Remove"
      return display_transfer_out_result
    end


    ActiveRecord::Base.transaction do

      action_tracker = 'find sku id'

      # Find destination bin with matching sku and location
      begin
        src_sku_id = Sku.find_by!( name: params[:sku]).id
        action_tracker = 'find src location id'
        src_location_id = Location.find_by!( name: params[:from]).id

        action_tracker = 'find src bin ' + params[:from]
        src_bin = Bin.find_by!( sku_id: src_sku_id, location_id: src_location_id )

        # Find destination bin with matching sku and location
        action_tracker = 'find dest id'
        dest_sku_id = Sku.find_by!( name: params[:sku]).id
        action_tracker = 'find dest location id'
        dest_location_id = Location.find_by!( name: params[:to]).id

      rescue ActiveRecord::RecordNotFound => e

        @error_message = e.message + " while attempting " + action_tracker

        render template: "login/generic_error"
        return

      end

      dest_bin = Bin.find_by( sku_id: dest_sku_id, location_id: dest_location_id)

      if dest_bin.nil?

        dest_bin = Bin.create( sku_id: dest_sku_id,
                       location_id: dest_location_id,
                        qty: params[:quantity].to_i )
        src_bin.decrement!(:qty, params[:quantity].to_i)


      else

        src_bin.decrement!(:qty, params[:quantity].to_i)
        dest_bin.increment!(:qty, params[:quantity].to_i)

      end

      if src_bin.qty < 1
        src_bin.destroy!
      end

      Transaction.create!(from_id: src_location_id, to_id: dest_location_id,
                  qty: params[:quantity].to_i,
                  sku_id: src_sku_id, user_id: session[:user_id])
    end

    render template: 'login/generic_ok'

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
    #view will pre-populate FROM string if in params[:from]

    # Need to update bins in a transaction; will have model
    # validation do various checks (e.g. attempt to go below zero)

    ActiveRecord::Base.transaction do

      # find the bin in question, creating a destination
      # bin if necessary


      # Find destination bin with matching sku and location

      begin

        dest_sku_id = Sku.find_by!( name: params[:sku]).id
        dest_location_id = Location.find_by!( name: params[:to]).id

      rescue ActiveRecord::RecordNotFound => e

        @error_message = e.message

        render template: "login/generic_error"
        return

      end

      dest_bin = Bin.find_by( sku_id: dest_sku_id, location_id: dest_location_id )

      if dest_bin.nil?

        dest_bin = Bin.create( sku_id: dest_sku_id,
                     location_id: dest_location_id,
                      qty: params[:quantity].to_i )
      else

        dest_bin.increment!(:qty, params[:quantity].to_i)

      end


      Transaction.create!( to_id: dest_location_id,
                        qty: params[:quantity].to_i,
                  sku_id: dest_sku_id, user_id: session[:user_id])

    end


    render template: 'login/generic_ok'

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
    #view will pre-populate FROM string if in params[:from]

    # Need to update bins in a transaction; will have model
    # validation do various checks (e.g. attempt to go below zero)

    ActiveRecord::Base.transaction do

      # Find destination bin with matching sku and location

      begin

        src_sku_id = Sku.find_by!( name: params[:sku]).id
        src_location_id = Location.find_by!( name: params[:from]).id
        src_bin = Bin.find_by!( sku_id: src_sku_id, location_id: src_location_id )

      rescue ActiveRecord::RecordNotFound => e

        @error_message = e.message

        render template: "login/generic_error"
        return

      end


      src_bin.decrement!(:qty, params[:quantity].to_i)

      if src_bin.qty < 1
        src_bin.destroy!
      end

      Transaction.create!( from_id: src_location_id,
                        qty: params[:quantity].to_i,
                  sku_id: src_sku_id, user_id: session[:user_id])

    end

    render template: 'login/generic_ok'

  end


end
