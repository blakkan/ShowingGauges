class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :comment
      t.boolean :is_retired, default: false
      t.references :user

      t.timestamps
    end
  end
end
