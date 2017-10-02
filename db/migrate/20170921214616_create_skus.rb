class CreateSkus < ActiveRecord::Migration[5.0]
  def change
    create_table :skus do |t|
      t.string :name
      t.string :comment
      t.references :users

      t.timestamps
    end
  end
end
