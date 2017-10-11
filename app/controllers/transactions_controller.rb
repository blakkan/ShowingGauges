class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]

  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.all
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to @transaction, notice: 'Transaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url, notice: 'Transaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  ############################################################
  #
  #  Display history in page
  #
  ############################################################

  def display_transactions_request_screen

  end


  def display_all_transactions


  end


  def transaction_found

    @the_display_list = []

    Transaction.order(created_at: :desc).all.each do |transaction|

      @the_display_list << {
        sku: ((transaction.sku_id.nil? || (not Sku.exists?(transaction.sku_id))) ? "NA" : Sku.find(transaction.sku_id).name),
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
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:SKU, :qty, :from, :to, :who)
    end
end
