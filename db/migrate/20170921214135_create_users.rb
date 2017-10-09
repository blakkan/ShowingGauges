class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :comment
      t.string :encrypted_password
      t.boolean :is_retired, default: false
      t.string :capabilities

      t.timestamps
    end
  end
end
