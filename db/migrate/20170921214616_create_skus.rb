class CreateSkus < ActiveRecord::Migration[5.0]
  def change
    create_table :skus do |t|
      t.string :name
      t.string :comment
      t.integer :minimum_stocking_level, default: 0
      t.boolean :is_retired, default: false
      t.references :users

      t.timestamps
    end
  end
end
