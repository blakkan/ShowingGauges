class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|

      t.integer :qty

      t.timestamps
    end

    add_reference :transactions, :from, references: :locations
    add_reference :transactions, :to, references: :locations
    add_reference :transactions, :sku, references: :skus
    add_reference :transactions, :user, references: :users

  end
end
