class CreateBins < ActiveRecord::Migration[5.0]
  def change
    create_table :bins do |t|
      t.integer :qty
      t.timestamps
    end

    add_reference :bins, :location, references: :locations
    add_reference :bins, :sku, references: :skus

  end
end
