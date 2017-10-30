class AddFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    # user reference back to use- this is a reference to the creator of this user
    add_reference :users, :user, references: :users
  end
end
