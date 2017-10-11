class AddFieldsToSkus < ActiveRecord::Migration[5.0]
  def change
    add_column :skus, :bu, :string
    add_column :skus, :description, :string
    add_column :skus, :category, :string
    add_column :skus, :cost, :decimal, :precision => 10, :scale => 2
  end
end
