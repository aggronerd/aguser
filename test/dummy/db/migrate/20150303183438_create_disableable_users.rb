class CreateDisableableUsers < ActiveRecord::Migration
  def change
    create_table :disableable_users do |t|
      t.string :user_name
      t.string :hashed_password
      t.string :salt
      t.boolean :disabled, default: 0
    end
  end
end
