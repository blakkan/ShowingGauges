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

    ActiveRecord::Base.transaction do

      # Find destination bin with matching sku and location

      src_sku_id = Sku.find_by( name: params[:sku]).id
      src_location_id = Location.find_by( name: params[:from]).id


      src_bin = Bin.where( "sku_id = ? and location_id = ?",
        src_sku_id, src_location_id ).first

      # Find destination bin with matching sku and location

      dest_sku_id = Sku.find_by( name: params[:sku]).id
      dest_location_id = Location.find_by( name: params[:to]).id

      dest_bin = Bin.where( "sku_id = ? and location_id = ?",
        dest_sku_id, dest_location_id ).first

      if dest_bin.nil?

        dest_bin = Bin.create( sku_id: dest_sku_id,
                       location_id: dest_location_id,
                        qty: 0 )
      end

      src_bin.decrement!(:qty, params[:quantity].to_i)
      dest_bin.increment!(:qty, params[:quantity].to_i)

      Transaction.create!(from_id: src_location_id, to_id: dest_location_id,
                  qty: params[:quantity].to_i,
                  sku_id: src_sku_id, user_id: session[:user_id])
    end

    render 'login/generic_ok'

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

      dest_sku_id = Sku.find_by( name: params[:sku]).id
      dest_location_id = Location.find_by( name: params[:to]).id

      dest_bin = Bin.where( "sku_id = ? and location_id = ?",
        dest_sku_id, dest_location_id ).first

      if dest_bin.nil?

        dest_bin = Bin.create( sku_id: dest_sku_id,
                     location_id: dest_location_id,
                      qty: 0 )
      end

      # quantity

      dest_bin.increment!(:qty, params[:quantity].to_i)

      Transaction.create!( to_id: dest_location_id,
                        qty: params[:quantity].to_i,
                  sku_id: dest_sku_id, user_id: session[:user_id])

    end


    render 'login/generic_ok'

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

      src_sku_id = Sku.find_by( name: params[:sku]).id
      src_location_id = Location.find_by( name: params[:from]).id

      src_bin = Bin.where( "sku_id = ? and location_id = ?",
        src_sku_id, src_location_id ).first

      src_bin.decrement!(:qty, params[:quantity].to_i)

      Transaction.create!( from_id: src_location_id,
                        qty: params[:quantity].to_i,
                  sku_id: src_sku_id, user_id: session[:user_id])

    end

    render 'login/generic_ok'

  end


end
