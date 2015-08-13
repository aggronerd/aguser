class CreateUserNameOptionals < ActiveRecord::Migration
  def change
    create_table :user_name_optionals do |t|
      t.string :user_name
      t.string :hashed_password
      t.string :salt
      t.string :some_data
      t.timestamps null: false
    end
  end
end
