class CreateUsergroups < ActiveRecord::Migration[5.2]
  def change
    create_table :usergroups do |t|
      t.integer :create_user_id, null: false
      t.string :name, null: false
      #t.integer :user_ids, array: true
      t.timestamps
    end
  end
end
