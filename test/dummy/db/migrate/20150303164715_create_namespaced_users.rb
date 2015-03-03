class CreateNamespacedUsers < ActiveRecord::Migration
  def change
    create_table :namespaced_users do |t|
      t.string :user_name
      t.string :hashed_password
      t.string :salt
      t.integer :namespace, default: 0
    end
  end
end
